defmodule Mix.Tasks.MachInfo do
  use Mix.Task
  @impl Mix.Task

  Logger.configure(level: :info)
  require Logger
  alias Clutterfly.FlyAPI

  @moduledoc """
  Count the Machines in a given app

  Takes the same options as Clutterfly.Commands.count_machines (`region` and `state`).
  Usage:
  mix count "my_app" --include-deleted
  """

  @spacing 4

  @args_types strict: [include_deleted: :boolean,
    image: :boolean,
    region: :string,
    state: :string,
    mode: :string
    ]

  def run([app_name | opts]) when is_binary(app_name) do
    # Just because of previous log-level shenanigans
    Logger.configure(level: :info)
    :logger.add_handler_filter(:default, :track_changes, {
      fn _log, level, _meta ->
        IO.puts "Logger level changed to: #{level}"
        :ignore
      end, nil})
    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:req)

    {parsed, _args, _invalid} = OptionParser.parse(opts, @args_types)

    # Sort opts
    api_opts = [
      region: Keyword.get(parsed, :region),
      state: Keyword.get(parsed, :state),
      include_deleted: Keyword.get(opts, :include_deleted)
      ]

    display_opts = [
      mode: process_display_opts(parsed)
      ]

    # Prepare a client struct
    # It's a read-only command so use whatever token is in $FLY_API_TOKEN
    client = case parsed[:client] do
      %client{} ->
        Logger.debug("Got a client from opts")
        Keyword.get(parsed, client)
      nil ->
        Logger.debug("No client specified; setting one.")
        FlyAPI.new()
    end

    # Make the API request
    {micro, response} = :timer.tc(fn ->
      Clutterfly.FlyAPI.list_machines(client, app_name, api_opts ++ [summary: true])
    end)
    IO.puts("Retrieved in #{micro / 1000}ms")

    case response do
      {:ok, %{status: 200, body: machines}} ->
          # Count the Machines
          num_machines = machines |> Enum.count()
          IO.puts ""
          IO.puts("App #{app_name} has #{num_machines} Machines.")
          if num_machines > 0 do
            # Get some tidbits about each Machine
            summary_info = compile_info(machines, display_opts)
            display_summaries(summary_info)
          end

      _ -> IO.inspect(response, label: "Other response")
    end
  end

  def run([app_name | _opts]) do
    IO.puts("app_name must be a string; got #{inspect app_name}")
  end

  defp compile_info(machines, display_opts) do
    # IO.puts("in compile_info, display_opts is #{inspect display_opts}")
    case display_opts[:mode] do
      "scale" -> machines
                |> Enum.map(fn m -> [id: m["id"], cpu_kind: get_cpu_kind(m), cpus: get_cpus(m), memory_mb: get_ram(m)] end)
      #|> dbg

      "default" -> machines
                |> Enum.map(fn m -> [id: m["id"], region: m["region"], state: m["state"], image: m["incomplete_config"]["image"]] end)

    end

    # @scale_cols [:id, :cpu_kind, :cpus, :memory_mb]
  end

  def display_summaries(machine_summaries) do
    first_summary = List.first(machine_summaries)
    Logger.debug("Table fits in terminal? #{fits_terminal?(first_summary)}")

    IO.puts ""

    case fits_terminal?(first_summary) do

      true ->
        {col_widths, padded_headers} = pad_headers(first_summary)
        IO.puts IO.iodata_to_binary(padded_headers)
        machine_summaries
        |> Enum.map(fn machine ->
            padded_vals = Enum.zip_with(machine, col_widths, fn {_key, val}, w_col ->
              num_pad = w_col - String.length(val)
              IO.iodata_to_binary([val, String.duplicate(" ", num_pad)])
            end)
            Enum.reduce(padded_vals, "", fn val, acc -> IO.iodata_to_binary([acc, val]) end)
            |> IO.puts
          end)

      false ->
        IO.puts ""
        machine_summaries
        |> Enum.map(fn machine ->
            IO.puts("Machine #{machine[:id]}")
            Enum.map(Enum.drop(machine, 1), fn {key, val} -> IO.puts("  #{key}: #{val}") end)
            IO.puts ""
          end)

    end


    # if cols_after > 0 do
    # IO.puts ""
    # IO.puts IO.iodata_to_binary([Enum.at(padded_headers, 0), Enum.drop(padded_headers, cols_before)])
    # summary = List.first(machine_summaries) # would still need to adapt this to do more Machines than the first
    # second_batch_values = Enum.take(summary, 1) ++ Enum.drop(summary, cols_before)
    # second_batch_values
    #   |> Enum.reduce("", fn {_key, val}, acc -> IO.iodata_to_binary([acc, val, String.duplicate(" ", @spacing)]) end)
    #   |> IO.puts

    # end

  end

  defp process_display_opts(parsed) do
    known = ["default", "scale"]
    input = Keyword.get(parsed, :mode, "default")
    if input in known do
      input
    else
      "default"
    end
  end

  defp get_cpu_kind(m) do
    m["incomplete_config"]["guest"]["cpu_kind"]
  end

  defp get_cpus(m) do
    m["incomplete_config"]["guest"]["cpus"] |> to_string
  end

  defp get_ram(m) do
    m["incomplete_config"]["guest"]["memory_mb"] |> to_string
  end

  # Use this when you know :io.columns returns #{:ok, number}
  # TODO: take into account when label is longer than value + spacing
  # Logic for this is downstream of fit decision atm
  defp fits_terminal?(mach_info) do
    {:ok, term_width} = :io.columns

    table_width = mach_info
    |> Enum.map(fn {_key, val} -> String.length(val) + @spacing end)
    |> Enum.sum

    if table_width > term_width do
      false
    else
      true
    end
  end

  def pad_headers(mach_info) do

    stuff = mach_info
    |> Enum.map(fn {key, val} -> {Atom.to_string(key) |> String.upcase, val} end)

    # widths = stuff
    # |> Enum.map(fn {key, val} ->
    #     {String.length(key), String.length(val)}
    #   end)
    # |> dbg

    col_widths = stuff
    |> Enum.map(fn {key, val} -> max(String.length(key) + 1, String.length(val) + @spacing) end)

    # col_widths = Enum.map(widths, fn {x, y} -> max(x + @spacing, y + 1) end)

    # Add spaces to column headers to they'll line up with the col values
    padded_headers =  Enum.zip_with(stuff, col_widths, fn {key, _val}, y ->
          num_pad = y - String.length(key)
          IO.iodata_to_binary([key, String.duplicate(" ", num_pad)])
        end)

    {col_widths, padded_headers}

    # The following was for breaking the output into separate rows, but on a narrow
    # terminal it didn't look great so blah
    # Get the current width of the terminal
    # {:ok, term_width} = :io.columns

    # # Get the terminal column where each display column ends
    # stops = val_widths |> Enum.scan(&(&1 + &2))

    # # Split when the next column wouldn't fit in the terminal
    # # Outputs a tuple
    # {stops_first, stops_last} = stops
    #     |> Enum.split_while(fn x -> x < term_width end) # e.g. {[14, 22], [89]}}
    # cols_before = length(stops_first)
    # cols_after = length(stops_last)

    # # Return stuff
    # {padded_headers, cols_before, cols_after}
  end

end
