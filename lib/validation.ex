defmodule Clutterfly.Validation do

  require Logger

   # Validates parameters using the provided schema module
   def validate_body(params, schema_module) do
    changeset = schema_module.changeset(struct(schema_module), params)

    if changeset.valid? do
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
end
