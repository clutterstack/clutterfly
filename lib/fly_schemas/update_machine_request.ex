defmodule Clutterfly.FlySchemas.UpdateMachineRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one :config, Clutterfly.FlySchemas.FlyMachineConfig
    field :current_version, :string
    field :lease_ttl, :integer
    field :lsvd, :boolean
    field :name, :string
    field :region, :string
    field :skip_launch, :boolean
    field :skip_service_registration, :boolean
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:current_version, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration])
        |> cast_embed(:config, with: &Clutterfly.FlySchemas.FlyMachineConfig.changeset/2)
  end
end
