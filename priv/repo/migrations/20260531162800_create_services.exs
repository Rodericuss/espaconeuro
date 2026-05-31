defmodule EspacoNeuro.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :title, :string
      add :slug, :string
      add :summary, :string
      add :description, :text
      add :icon, :string
      add :modality, :string
      add :price_cents, :integer
      add :price_kind, :string
      add :position, :integer, default: 0
      add :published, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:services, [:slug])
  end
end
