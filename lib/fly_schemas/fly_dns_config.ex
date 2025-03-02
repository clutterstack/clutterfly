defmodule Clutterfly.FlySchemas.FlyDNSConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :dns_forward_rules, Clutterfly.FlySchemas.FlyDnsForwardRule
    field :hostname, :string
    field :hostname_fqdn, :string
    field :nameservers, {:array, :string}
    embeds_many :options, Clutterfly.FlySchemas.FlyDnsOption
    field :searches, {:array, :string}
    field :skip_registration, :boolean
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:hostname, :hostname_fqdn, :nameservers, :searches, :skip_registration])
        |> cast_embed(:dns_forward_rules, with: &Clutterfly.FlySchemas.FlyDnsForwardRule.changeset/2)
    |> cast_embed(:options, with: &Clutterfly.FlySchemas.FlyDnsOption.changeset/2)
  end
end
