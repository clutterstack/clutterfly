defmodule Clutterfly.FlySchemas.ListAppsResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :apps, Clutterfly.FlySchemas.ListApp
    field :total_apps, :integer
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:total_apps])
        |> cast_embed(:apps, with: &Clutterfly.FlySchemas.ListApp.changeset/2)
  end
end
