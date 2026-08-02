defmodule EspacoNeuro.Repo.Migrations.ChangeProfessionalSummaryToText do
  use Ecto.Migration

  def change do
    alter table(:professionals) do
      modify :summary, :text, from: :string
    end
  end
end
