defmodule Clutterfly.Validate do

  require Logger

  @moduledoc """
  Functions to validate bodies and make API calls via the FlyMachines library.
  The default config (see config.exs) for that lib uses a FLY_API_TOKEN
  environment variable  -- for local dev do
  `export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)`
  to get a deploy token for one app.
  """


  # Validates parameters using the provided schema module
  def validate_body(params, schema_module) do
    changeset = schema_module.changeset(struct(schema_module), params)

    if changeset.valid? do
      Logger.info("Validated a #{inspect(schema_module)} struct")
      # Return the original params if they're valid
      {:ok, params}
    else
      errors = format_changeset_errors(changeset)
      Logger.error("Invalid params for #{inspect(schema_module)}: #{inspect(errors)}")
      {:error, {:inreq_body, errors}}
    end
  end

  # Formats changeset errors into a human-readable format
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

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

  # App operations
  def validate_and_run(:app_create, [], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateAppRequest),
         {:ok, response} <- FlyMachines.app_create(req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  # Machine operations
  def validate_and_run(:machine_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateMachineRequest),
         {:ok, response} <- FlyMachines.machine_create(appname, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_update, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.UpdateMachineRequest),
         {:ok, response} <- FlyMachines.machine_update(appname, machine_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_stop, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.StopRequest),
         {:ok, response} <- FlyMachines.machine_stop(appname, machine_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_start, [appname, machine_id], _body) do
    FlyMachines.machine_start(appname, machine_id)
  end

  def validate_and_run(:machine_restart, [appname, machine_id], _body) do
    FlyMachines.machine_restart(appname, machine_id)
  end

  def validate_and_run(:machine_signal, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.SignalRequest),
         {:ok, response} <- FlyMachines.machine_signal(appname, machine_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_cordon, [appname, machine_id], _body) do
    FlyMachines.machine_cordon(appname, machine_id)
  end

  def validate_and_run(:machine_uncordon, [appname, machine_id], _body) do
    FlyMachines.machine_uncordon(appname, machine_id)
  end

  def validate_and_run(:machine_lease_acquire, [appname, machine_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateLeaseRequest),
         {:ok, response} <- FlyMachines.machine_lease_acquire(appname, machine_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:machine_lease_release, [appname, machine_id, lease_nonce], _body) do
    FlyMachines.machine_lease_release(appname, machine_id, lease_nonce)
  end



  # Volume operations
  def validate_and_run(:volume_create, [appname], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.CreateVolumeRequest),
         {:ok, response} <- FlyMachines.volume_create(appname, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:volume_update, [appname, volume_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.UpdateVolumeRequest),
         {:ok, response} <- FlyMachines.volume_update(appname, volume_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end

  def validate_and_run(:volume_extend, [appname, volume_id], body) do
    with {:ok, req_body} <- validate_body(body, Clutterfly.FlySchemas.ExtendVolumeRequest),
         {:ok, response} <- FlyMachines.volume_extend(appname, volume_id, req_body) do
      {:ok, response}
    else
      {:error, response} -> {:error, response}
    end
  end


  # Operations that don't require body validation
  # Might prefer not to even have these

#   def validate_and_run(:volume_delete, [appname, volume_id]) do
#     FlyMachines.volume_delete(appname, volume_id)
#   end

#   def validate_and_run(:app_list, [org_slug]) do
#     FlyMachines.app_list(org_slug)
#   end

#   def validate_and_run(:app_retrieve, [appname]) do
#     FlyMachines.app_retrieve(appname)
#   end

#   def validate_and_run(:app_delete, [appname]) do
#     FlyMachines.app_delete(appname)
#   end

#   def validate_and_run(:machine_list, [appname]) do
#     FlyMachines.machine_list(appname)
#   end

#   def validate_and_run(:machine_retrieve, [appname, machine_id]) do
#     FlyMachines.machine_retrieve(appname, machine_id)
#   end

#   def validate_and_run(:machine_delete, [appname, machine_id]) do
#     FlyMachines.machine_delete(appname, machine_id)
#   end

#   def validate_and_run(:machine_ps, [appname, machine_id]) do
#     FlyMachines.machine_ps(appname, machine_id)
#   end

#   def validate_and_run(:machine_event_list, [appname, machine_id]) do
#     FlyMachines.machine_event_list(appname, machine_id)
#   end

#   def validate_and_run(:machine_versions_list, [appname, machine_id]) do
#     FlyMachines.machine_versions_list(appname, machine_id)
#   end

#   def validate_and_run(:machine_metadata_retrieve, [appname, machine_id]) do
#     FlyMachines.machine_metadata_retrieve(appname, machine_id)
#   end

#   def validate_and_run(:machine_metadata_delete, [appname, machine_id, key]) do
#     FlyMachines.machine_metadata_delete(appname, machine_id, key)
#   end

#   def validate_and_run(:volume_list, [appname]) do
#     FlyMachines.volume_list(appname)
#   end

#   def validate_and_run(:volume_retrieve, [appname, volume_id]) do
#     FlyMachines.volume_retrieve(appname, volume_id)
#   end

#   def validate_and_run(:volume_snapshots_list, [appname, volume_id]) do
#     FlyMachines.volume_snapshots_list(appname, volume_id)
#   end

# def validate_and_run(:machine_wait, [appname, machine_id], params) do
## Note we have query params in place of a body
#   FlyMachines.machine_wait(appname, machine_id, params)
# end

  # Catch-all
  def validate_and_run(operation, _args, _body) do
    {:error, {:unknown_operation, operation}}
  end
end
