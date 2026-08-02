defmodule EspacoNeuro.Repo.Migrations.ChangeProfessionalHeadlineToText do
  use Ecto.Migration

  def change do
    alter table(:professionals) do
      modify :headline, :text, from: :string
    end
  end
end
