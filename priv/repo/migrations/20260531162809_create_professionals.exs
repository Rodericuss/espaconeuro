defmodule EspacoNeuro.Repo.Migrations.CreateProfessionals do
  use Ecto.Migration

  def change do
    create table(:professionals) do
      add :name, :string
      add :slug, :string
      add :category, :string
      add :profession, :string
      add :crp, :string
      add :headline, :string
      add :summary, :string
      add :description, :text
      add :approach, :string
      add :specialties, {:array, :string}
      add :modalities, {:array, :string}
      add :whatsapp, :string
      add :email, :string
      add :photo_path, :string
      add :position, :integer, default: 0
      add :published, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:professionals, [:slug])
  end
end
