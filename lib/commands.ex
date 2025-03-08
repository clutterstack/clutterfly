defmodule Clutterfly.Commands do
  import Clutterfly.Validate
  alias Clutterfly.FlySchemas

  require Logger

  # Convenience functions for common operations
  # TODO: these should generally do more than call the API.
  # API calls are provided by the fly_machines package
  # Validating and calling is already handled by validate_and_run()
  # So here is a place to build in things like waits or even deployment
  # Like flyctl commands but with personalised opinions

  @doc """
  List apps in personal org
  """
  def list_apps do
    FlyMachines.app_list("personal")
  end

  @doc """
  List Machines in app
  """
  def list_machines(app) do
    FlyMachines.machine_list(app)
  end

  @doc """
  Run a new Machine
  """
  def create_machine(appname, body) do
    case validate_and_run(:machine_create, [appname], body) do
      {:ok, %{:status => _status, :body => body}} -> validate_body(body, FlySchemas.Machine)
      {:error, %{:status => status, :body => %{"error" => errmsg}}} -> {:error, "#{status}: #{errmsg}"}
      {:ok, _somethingelse} -> {:error, "Unexpected response from FlyMachines function"}
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
  def update_volume(appname, volume_id, body), do: validate_and_run(:volume_update, [appname, volume_id], body)

  @doc """
  Try running with a preset config:
  """
    def run_preset_machine(appname \\ "where", image \\ "registry.fly.io/where:debian-nano") do
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
      create_machine(appname, mach_params)
    end

    @doc """
    Run with a minimal preset config

    Return when it's "started"
    """
    def run_min_config(appname \\ "where", image \\ "registry.fly.io/where:debian-nano") do
      mach_params = %{
        config: %{
          image: image
        }
      }
      create_machine(appname, mach_params)
    end

    @doc """
    Force-destroy all Machines in the app
    """
    # def force_destroy_machines(appname) do
    #   # get Machines in app

    #   #
    # end

    # FlyMachines.machine_wait(appname, "machine-id", params: [state: "stopped"])

end
