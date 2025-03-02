defmodule Clutterfly.FlySchemas.MachineVersion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one :user_config, Clutterfly.FlySchemas.FlyMachineConfig
    field :version, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:version])
        |> cast_embed(:user_config, with: &Clutterfly.FlySchemas.FlyMachineConfig.changeset/2)
  end
end
