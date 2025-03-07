defmodule Clutterfly.Client do

  import Clutterfly.Validation

  require Logger

  @moduledoc """
  Functions to validate bodies and make API calls via the FlyMachines library.
  The default config (see config.exs) for that lib uses a FLY_API_TOKEN
  environment variable  -- for local dev do
  `export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)`
  to get a deploy token for one app.
  """


  @doc """
  Functions to validate and execute API calls, using the FlyMachines pkg as the core
  API client

  Every API call has its own clause, in order to match up the FlyMachines fn with
  the Ecto schema the body should be validated against.

  Wouldn't need these if validation were wrapped into the FlyMachines
  functions. But I don't want to do that right now:

    1. My validation is based on a janky translation of the Machines
  JSON OpenAPI spec so I prefer to keep it separate.

    2. I don't want to reimplement the nice API client lib

  Alternatively could use a map to match validation schemas with commands--I think
  that would be slower and use more RAM, though those may not be significant
  concerns (certainly not for my own use). Refactoring for abstraction would
  make it significantly harder to read though.
  """

 # API calls with just appname path param

  # Set default empty body if omitted
  def validate_and_run(operation, [args]) when is_atom(operation) do
    validate_and_run(operation, [args], %{})
  end

  def validate_and_run(:machine_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateMachineRequest),
         {:ok, response} <- FlyMachines.machine_create(appname, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:volume_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateVolumeRequest),
         {:ok, response} <- FlyMachines.volume_create(appname, req_body) do
      {:ok, response.body}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_update, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.UpdateMachineRequest),
         {:ok, response} <- FlyMachines.machine_update(appname, machine_id, req_body) do
      {:ok, response.body}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_stop, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.StopMachineRequest),
         {:ok, response} <- FlyMachines.machine_stop(appname, machine_id, req_body) do
      {:ok, response.body}
    else
      {:error, response} -> {:error, response}
    end
  end

  # Catch-all
  def validate_and_run(operation, _args, _body) do
    {:error, {:unknown_operation, operation}}
  end

  # defp compose_errmsg()

end
