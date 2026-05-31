defmodule EspacoNeuro.Repo do
  use Ecto.Repo,
    otp_app: :espaco_neuro,
    adapter: Ecto.Adapters.Postgres
end
