defmodule Clutterfly.Commands do
  import Clutterfly.Validate
  alias Clutterfly.FlyAPI

  require Logger

  # Convenience functions for common operations
  # TODO: these should generally do more than call the API.
  # API calls are provided by the fly_machines package
  # Validating and calling is already handled by validate_and_run()
  # So here is a place to build in things like waits or even deployment
  # Like flyctl commands but with personalised opinions

  @client FlyAPI.new(app_name: "where")


  @doc """
  Count Machines in the app

  ## Options
  * region
  * state
  * include_deleted
  * TODO?: filter by metadata etc

  Clutterfly.FlyAPI.list_machines(client, "my-app", region: "yyz", state: "stopped", summary: true, include_deleted: true)
  """
  def count_machines(app_name, opts \\ []) do
    # It's a read-only command so use whatever token is in $FLY_API_TOKEN
    client = case opts[:client] do
      %client{} ->
        Logger.debug("Got a client from opts")
        Keyword.get(opts, client)
      nil ->
        Logger.debug("No client specified; setting one.")
        FlyAPI.new()
    end
    # Options
    options = [
    region: Keyword.get(opts, :region),
    state: Keyword.get(opts, :state),
    include_deleted: Keyword.get(opts, :include_deleted)
    ]
    # Get the Machines (summary mode)
    # Count the Machines
    case Clutterfly.FlyAPI.list_machines(client, app_name, options ++ [summary: true])
    do
      {:ok, %{status: 200, body: machines}} ->
          num = machines |> Enum.count()
          {:ok, num}
      {:ok, response } -> {:ok, response}
      {_, response} -> {:error, response}
    end
  end


  @doc """
  Get info about Machines in the app

  ## Options
  * region
  * state
  * include_deleted
  * TODO?: filter by metadata etc

  Clutterfly.FlyAPI.list_machines(client, "my-app", region: "yyz", state: "stopped", summary: true, include_deleted: true)
  """
  def see_machines(app_name, opts \\ []) do
    # It's a read-only command so use whatever token is in $FLY_API_TOKEN
    client = case opts[:client] do
      %client{} ->
        Logger.debug("Got a client from opts")
        Keyword.get(opts, client)
      nil ->
        Logger.debug("No client specified; setting one.")
        FlyAPI.new()
    end
    # Options
    options = [
    region: Keyword.get(opts, :region),
    state: Keyword.get(opts, :state),
    include_deleted: Keyword.get(opts, :include_deleted)
    ]
    # Get the Machines (summary mode)
    case Clutterfly.FlyAPI.list_machines(client, app_name, options ++ [summary: true])
    do
      {:ok, %{status: 200, body: machines}} ->
          # Count the Machines
          num_machines = machines |> Enum.count()
          if num_machines > 0 do
            # Get some tidbits about each Machine
            raw_infos = Enum.map(machines, fn machine -> %{id: machine["id"], state: machine["state"], image: machine["incomplete_config"] && machine["incomplete_config"]["image"] || nil} end)
            # infos = Enum.map(machines, fn machine -> )
            {:ok, %{num_machines: num_machines, info: raw_infos}}
          end
      {:ok, response } -> {:ok, response}
      {_, response} -> {:error, response}
    end
  end



  @doc """
  Change the Machine's config (causes a restart)
  """
  def update_machine(appname, machine_id, body), do: validate_and_run(:machine_update, [appname, machine_id], body)

  @doc """
  Create a new volume
  """
  def create_volume(appname, body), do: validate_and_run(:volume_create, [appname], body)
  @doc """
  Update a volume
  """
  def update_volume(appname, volume_id, body) do
    validate_and_run(:volume_update, [appname, volume_id], body)
  end


  @doc """
  Try running with a preset config:
  """
  def run_preset_machine(image \\ "registry.fly.io/where:debian-nano") do
    client = @client
    with {:ok, app_name} <- get_appname(client) do
      mach_params = %{
        config: %{
          image: image,
          auto_destroy: true,
          guest: %{
            cpu_kind: "shared",
            cpus: 1,
            memory_mb: 256
          }
        }
      }
      FlyAPI.create_machine(client, app_name, mach_params)
    end
  end

  @doc """
  Run a new Machine with a minimal preset config
  """
  def run_min_config(image \\ "registry.fly.io/where:debian-nano") do
    client = @client
    with {:ok, app_name} <- get_appname(client) do
      mach_params = %{
        config: %{
          image: image
        }
      }
      with {:ok, %{status: 200, body: %{"id" => mach_id}}}
       <- FlyAPI.create_machine(client, app_name, mach_params)
        do
          Logger.info("Created Machine #{mach_id}")

        end

    end
  end

  @doc """
  Force-destroy all Machines in the app.

  Options (all the opts from the list_machines endpoint, except
  `summary`, which is `true`):

  * `include_deleted` - Include deleted machines
  * `region` - Filter by region
  * `state` - Comma separated list of states to filter (created, started, stopped, suspended)

  """
  def nuke_all_machines(appname, opts \\ []) do
    client = FlyAPI.new()
    options = opts ++ [summary: true]
    # get Machines in app
    with {:ok, %Req.Response{} = response} <- FlyAPI.list_machines(client, appname, options)
      do
        # Every object in the response body is a Machine summary.
        response.body
        |> Enum.map(fn machine -> nuke_one_machine(appname, machine["id"], machine["instance_id"]) end)
      end
    end

  @doc """
  Stop and destroy one Machine.  Needs the instance_id in order to wait for it to be stopped.
  """
  def nuke_one_machine(appname, mach_id, instance_id) do
    client = @client
    with {:ok, _} <- FlyAPI.cordon_machine(client, appname, mach_id),
    {:ok, %Req.Response{status: 200}} <- FlyAPI.stop_machine(client, appname, mach_id) do
      case FlyAPI.wait_for_machine(client, appname, mach_id, instance_id: instance_id, state: "stopped") do
        {:ok, %{status: 200, body: %{"ok" => true}}} ->
          Logger.info("Machine #{mach_id} is stopped")
          case FlyAPI.destroy_machine(client, appname, mach_id) do
            {:ok, %{status: 200, body: %{"ok" => true}}} ->
              Logger.info("Machine #{mach_id} is destroyed")
              {:ok, %{status: 200, machine_id: mach_id}}
          end
        {:error, %{status: 404}} ->
          Logger.info("Machine #{mach_id} not found; ")
        response ->
          Logger.info("Response from wait request: #{inspect response}")
          response
      end
    end
  end
  {:error, %{message: "not_found: machine not found", status: 404}}

  #Get the app name from the client struct. Errors if there isn't one.
  defp get_appname(client) do
    client.app_name && {:ok, client.app_name} ||
    {:error, "Client struct doesn't provide an app name. Use Clutterfly.FlyAPI.new() to set one, or use a version of your command that accepts app_name as a parameter."}
  end

end
