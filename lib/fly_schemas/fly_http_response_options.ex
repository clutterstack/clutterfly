defmodule Clutterfly.FlySchemas.FlyHTTPResponseOptions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :headers, {:map, :map}
    field :pristine, :boolean
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:pristine])

  end
end
