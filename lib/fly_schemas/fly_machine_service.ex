defmodule Clutterfly.FlySchemas.FlyMachineService do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :autostart, :boolean
    field :autostop, :string
    embeds_many :checks, Clutterfly.FlySchemas.FlyMachineCheck
    embeds_one :concurrency, Clutterfly.FlySchemas.FlyMachineServiceConcurrency
    field :force_instance_description, :string
    field :force_instance_key, :string
    field :internal_port, :integer
    field :min_machines_running, :integer
    embeds_many :ports, Clutterfly.FlySchemas.FlyMachinePort
    field :protocol, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:autostart, :autostop, :force_instance_description, :force_instance_key, :internal_port, :min_machines_running, :protocol])
        |> cast_embed(:checks, with: &Clutterfly.FlySchemas.FlyMachineCheck.changeset/2)
    |> cast_embed(:concurrency, with: &Clutterfly.FlySchemas.FlyMachineServiceConcurrency.changeset/2)
    |> cast_embed(:ports, with: &Clutterfly.FlySchemas.FlyMachinePort.changeset/2)
  end
end
