defmodule EspacoNeuro.Catalog.Service do
  use Ecto.Schema
  import Ecto.Changeset

  alias EspacoNeuro.Catalog.Professional

  schema "services" do
    field :title, :string
    field :slug, :string
    field :summary, :string
    field :description, :string
    field :icon, :string
    field :modality, Ecto.Enum, values: [:presencial, :online, :ambos]
    field :price_cents, :integer
    field :price_kind, Ecto.Enum, values: [:fixed, :from, :on_request], default: :on_request
    field :position, :integer, default: 0
    field :published, :boolean, default: true

    many_to_many :professionals, Professional,
      join_through: "services_professionals",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @required_fields [:title, :description, :icon, :modality, :price_kind]
  @optional_fields [:slug, :summary, :price_cents, :position, :published]

  def changeset(service, attrs) do
    service
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title -> put_change(changeset, :slug, Slug.slugify(title))
    end
  end
end
