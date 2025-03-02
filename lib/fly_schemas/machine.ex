defmodule Clutterfly.FlySchemas.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :checks, Clutterfly.FlySchemas.CheckStatus
    embeds_one :config, Clutterfly.FlySchemas.FlyMachineConfig
    field :created_at, :string
    embeds_many :events, Clutterfly.FlySchemas.MachineEvent
    field :host_status, :string
    field :id, :string
    embeds_one :image_ref, Clutterfly.FlySchemas.ImageRef
    embeds_one :incomplete_config, Clutterfly.FlySchemas.FlyMachineConfig
    field :instance_id, :string
    field :name, :string
    field :nonce, :string
    field :private_ip, :string
    field :region, :string
    field :state, :string
    field :updated_at, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:created_at, :host_status, :id, :instance_id, :name, :nonce, :private_ip, :region, :state, :updated_at])
        |> cast_embed(:checks, with: &Clutterfly.FlySchemas.CheckStatus.changeset/2)
    |> cast_embed(:config, with: &Clutterfly.FlySchemas.FlyMachineConfig.changeset/2)
    |> cast_embed(:events, with: &Clutterfly.FlySchemas.MachineEvent.changeset/2)
    |> cast_embed(:image_ref, with: &Clutterfly.FlySchemas.ImageRef.changeset/2)
    |> cast_embed(:incomplete_config, with: &Clutterfly.FlySchemas.FlyMachineConfig.changeset/2)
  end
end
