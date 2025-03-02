defmodule Clutterfly.FlySchemas.FlyMachineProcess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :cmd, {:array, :string}
    field :entrypoint, {:array, :string}
    field :env, {:map, :string}
    embeds_many :env_from, Clutterfly.FlySchemas.FlyEnvFrom
    field :exec, {:array, :string}
    field :ignore_app_secrets, :boolean
    embeds_many :secrets, Clutterfly.FlySchemas.FlyMachineSecret
    field :user, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:cmd, :entrypoint, :exec, :ignore_app_secrets, :user])
        |> cast_embed(:env_from, with: &Clutterfly.FlySchemas.FlyEnvFrom.changeset/2)
    |> cast_embed(:secrets, with: &Clutterfly.FlySchemas.FlyMachineSecret.changeset/2)
  end
end
