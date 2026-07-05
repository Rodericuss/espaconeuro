defmodule EspacoNeuro.Catalog.Professional do
  use Ecto.Schema
  import Ecto.Changeset

  alias EspacoNeuro.Catalog.Service

  schema "professionals" do
    field :name, :string
    field :slug, :string
    field :category, Ecto.Enum, values: [:psi, :neuro, :pedago]
    field :profession, :string
    field :crp, :string
    field :headline, :string
    field :summary, :string
    field :description, :string
    field :approach, :string
    field :specialties, {:array, :string}, default: []
    field :modalities, {:array, :string}, default: []
    field :whatsapp, :string
    field :email, :string
    field :photo_path, :string
    field :position, :integer, default: 0
    field :published, :boolean, default: true

    many_to_many :services, Service, join_through: "services_professionals"

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name, :category, :profession, :headline, :description]
  @optional_fields [
    :slug,
    :crp,
    :summary,
    :approach,
    :specialties,
    :modalities,
    :whatsapp,
    :email,
    :photo_path,
    :position,
    :published
  ]

  def changeset(professional, attrs) do
    professional
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> generate_slug()
    |> unique_constraint(:slug)
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name -> put_change(changeset, :slug, Slug.slugify(name))
    end
  end
end
