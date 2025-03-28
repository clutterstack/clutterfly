defmodule Clutterfly.FlySchemas.FlyMachineCheck do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one :grace_period, Clutterfly.FlySchemas.FlyDuration
    embeds_many :headers, Clutterfly.FlySchemas.FlyMachineHTTPHeader
    embeds_one :interval, Clutterfly.FlySchemas.FlyDuration
    field :kind, :string
    field :method, :string
    field :path, :string
    field :port, :integer
    field :protocol, :string
    embeds_one :timeout, Clutterfly.FlySchemas.FlyDuration
    field :tls_server_name, :string
    field :tls_skip_verify, :boolean
    field :type, :string
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:kind, :method, :path, :port, :protocol, :tls_server_name, :tls_skip_verify, :type])
        |> cast_embed(:grace_period, with: &Clutterfly.FlySchemas.FlyDuration.changeset/2)
    |> cast_embed(:headers, with: &Clutterfly.FlySchemas.FlyMachineHTTPHeader.changeset/2)
    |> cast_embed(:interval, with: &Clutterfly.FlySchemas.FlyDuration.changeset/2)
    |> cast_embed(:timeout, with: &Clutterfly.FlySchemas.FlyDuration.changeset/2)
  end
end
