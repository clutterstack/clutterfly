defmodule Clutterfly.FlySchemas.FlyStopConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :signal, :string
    embeds_one :timeout, Clutterfly.FlySchemas.FlyDuration
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:signal])
        |> cast_embed(:timeout, with: &Clutterfly.FlySchemas.FlyDuration.changeset/2)
  end
end
