defmodule Clutterfly.Client do

  alias Clutterfly.Validation

  require Logger

  @moduledoc """
  Functions to validate bodies and make API calls via the FlyMachines library.
  The default config (see config.exs) for that lib uses a FLY_API_TOKEN
  environment variable  -- for local dev do
  `export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)`
  to get a deploy token for one app.
  """


  @doc """
  Functions to validate and execute API calls
  Wouldn't need all these clauses if validation were wrapped into the FlyMachines
  functions. But
    1. my validation is based on a janky translation of the Machines
  JSON OpenAPI spec so it's better to keep it separate.
    2. I don't want to reimplement the nice API client lib
  Therefore we need either a map or pattern matching to match up the API call with the Ecto schema to validate bodies against.
  """

 # API calls that only need the appname

  # Set default empty body if omitted
  def validate_and_run(operation, [args]) when is_atom(operation) do
    validate_and_run(operation, [args], %{})
  end

  # Specific calls
  def validate_and_run(:machine_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateMachineRequest),
         {:ok, response} <- FlyMachines.machine_create(appname, req_body) do
      {:ok, response.body}
    end
  end

  def validate_and_run(:volume_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateVolumeRequest),
         {:ok, response} <- FlyMachines.volume_create(appname, req_body) do
      {:ok, response.body}
    end
  end

  def validate_and_run(:machine_update, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.UpdateMachineRequest),
         {:ok, response} <- FlyMachines.machine_update(appname, machine_id, req_body) do
      {:ok, response.body}
    end
  end

  def validate_and_run(:machine_stop, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.StopMachineRequest),
         {:ok, response} <- FlyMachines.machine_stop(appname, machine_id, req_body) do
      {:ok, response.body}
    end
  end

  def validate_and_run(operation, _args, _body) do
    {:error, {:unknown_operation, operation}}
  end

end
