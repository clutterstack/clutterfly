defmodule Clutterfly.FlySchemas.App do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    embeds_one :organization, Clutterfly.FlySchemas.Organization
    field :status, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:id, :name, :status])
        |> cast_embed(:organization, with: &Clutterfly.FlySchemas.Organization.changeset/2)
  end
end
