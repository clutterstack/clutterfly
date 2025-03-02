defmodule Clutterfly.FlySchemas.FlyMachineConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :auto_destroy, :boolean
    embeds_many :checks, Clutterfly.FlySchemas.FlyMachineCheck
    field :disable_machine_autostart, :boolean
    embeds_one :dns, Clutterfly.FlySchemas.FlyDNSConfig
    field :env, {:map, :string}
    embeds_many :files, Clutterfly.FlySchemas.FlyFile
    embeds_one :guest, Clutterfly.FlySchemas.FlyMachineGuest
    field :image, :string
    embeds_one :init, Clutterfly.FlySchemas.FlyMachineInit
    field :metadata, {:map, :string}
    embeds_one :metrics, Clutterfly.FlySchemas.FlyMachineMetrics
    embeds_many :mounts, Clutterfly.FlySchemas.FlyMachineMount
    embeds_many :processes, Clutterfly.FlySchemas.FlyMachineProcess
    embeds_one :restart, Clutterfly.FlySchemas.FlyMachineRestart
    field :schedule, :string
    embeds_many :services, Clutterfly.FlySchemas.FlyMachineService
    field :size, :string
    field :standbys, {:array, :string}
    embeds_many :statics, Clutterfly.FlySchemas.FlyStatic
    embeds_one :stop_config, Clutterfly.FlySchemas.FlyStopConfig
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:auto_destroy, :disable_machine_autostart, :image, :schedule, :size, :standbys])
        |> cast_embed(:dns, with: &Clutterfly.FlySchemas.FlyDNSConfig.changeset/2)
    |> cast_embed(:files, with: &Clutterfly.FlySchemas.FlyFile.changeset/2)
    |> cast_embed(:guest, with: &Clutterfly.FlySchemas.FlyMachineGuest.changeset/2)
    |> cast_embed(:init, with: &Clutterfly.FlySchemas.FlyMachineInit.changeset/2)
    |> cast_embed(:metrics, with: &Clutterfly.FlySchemas.FlyMachineMetrics.changeset/2)
    |> cast_embed(:mounts, with: &Clutterfly.FlySchemas.FlyMachineMount.changeset/2)
    |> cast_embed(:processes, with: &Clutterfly.FlySchemas.FlyMachineProcess.changeset/2)
    |> cast_embed(:restart, with: &Clutterfly.FlySchemas.FlyMachineRestart.changeset/2)
    |> cast_embed(:services, with: &Clutterfly.FlySchemas.FlyMachineService.changeset/2)
    |> cast_embed(:statics, with: &Clutterfly.FlySchemas.FlyStatic.changeset/2)
    |> cast_embed(:stop_config, with: &Clutterfly.FlySchemas.FlyStopConfig.changeset/2)
  end
end
