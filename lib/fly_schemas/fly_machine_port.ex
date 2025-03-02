defmodule Clutterfly.FlySchemas.FlyMachinePort do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :end_port, :integer
    field :force_https, :boolean
    field :handlers, {:array, :string}
    embeds_one :http_options, Clutterfly.FlySchemas.FlyHTTPOptions
    field :port, :integer
    embeds_one :proxy_proto_options, Clutterfly.FlySchemas.FlyProxyProtoOptions
    field :start_port, :integer
    embeds_one :tls_options, Clutterfly.FlySchemas.FlyTLSOptions
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:end_port, :force_https, :handlers, :port, :start_port])
        |> cast_embed(:http_options, with: &Clutterfly.FlySchemas.FlyHTTPOptions.changeset/2)
    |> cast_embed(:proxy_proto_options, with: &Clutterfly.FlySchemas.FlyProxyProtoOptions.changeset/2)
    |> cast_embed(:tls_options, with: &Clutterfly.FlySchemas.FlyTLSOptions.changeset/2)
  end
end
