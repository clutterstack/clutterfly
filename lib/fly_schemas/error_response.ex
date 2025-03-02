defmodule Clutterfly.FlySchemas.ErrorResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :details, :map
    field :error, :string
    embeds_one :status, Clutterfly.FlySchemas.MainStatusCode
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:error])
        |> cast_embed(:status, with: &Clutterfly.FlySchemas.MainStatusCode.changeset/2)
  end
end
