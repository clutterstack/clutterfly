defmodule Clutterfly.FlySchemas.FlyHTTPOptions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :compress, :boolean
    field :h2_backend, :boolean
    field :headers_read_timeout, :integer
    field :idle_timeout, :integer
    embeds_one :response, Clutterfly.FlySchemas.FlyHTTPResponseOptions
  end

  def changeset(schema, attrs) do
    schema
        |> cast(attrs, [:compress, :h2_backend, :headers_read_timeout, :idle_timeout])
        |> cast_embed(:response, with: &Clutterfly.FlySchemas.FlyHTTPResponseOptions.changeset/2)
  end
end
