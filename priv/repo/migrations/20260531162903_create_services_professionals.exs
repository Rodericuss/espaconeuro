defmodule EspacoNeuro.Repo.Migrations.CreateServicesProfessionals do
  use Ecto.Migration

  def change do
    create table(:services_professionals, primary_key: false) do
      add :service_id, references(:services, on_delete: :delete_all), null: false
      add :professional_id, references(:professionals, on_delete: :delete_all), null: false
    end

    create unique_index(:services_professionals, [:service_id, :professional_id])
    create index(:services_professionals, [:professional_id])
  end
end
