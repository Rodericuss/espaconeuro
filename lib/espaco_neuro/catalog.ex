defmodule EspacoNeuro.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias EspacoNeuro.Repo

  alias EspacoNeuro.Catalog.{Service, Professional}

  # --- Services ---

  def list_services do
    Service |> order_by(:position) |> Repo.all() |> Repo.preload(:professionals)
  end

  def list_published_services do
    Service
    |> where(published: true)
    |> order_by(:position)
    |> Repo.all()
    |> Repo.preload(:professionals)
  end

  def get_service!(id), do: Repo.get!(Service, id) |> Repo.preload(:professionals)

  def get_service_by_slug!(slug) do
    Service
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(:professionals)
  end

  def create_service(attrs, professional_ids \\ []) do
    professionals = load_professionals(professional_ids)

    result =
      %Service{}
      |> Service.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:professionals, professionals)
      |> Repo.insert()

    with {:ok, service} <- result do
      {:ok, Repo.preload(service, :professionals, force: true)}
    end
  end

  def update_service(%Service{} = service, attrs, professional_ids \\ []) do
    professionals = load_professionals(professional_ids)

    result =
      service
      |> Repo.preload(:professionals)
      |> Service.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:professionals, professionals)
      |> Repo.update()

    with {:ok, service} <- result do
      {:ok, Repo.preload(service, :professionals, force: true)}
    end
  end

  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end

  def change_service(%Service{} = service, attrs \\ %{}) do
    Service.changeset(service, attrs)
  end

  # --- Professionals ---

  def list_professionals do
    Professional |> order_by(:position) |> Repo.all()
  end

  def list_published_professionals do
    Professional |> where(published: true) |> order_by(:position) |> Repo.all()
  end

  def list_published_professionals_by_category(category) do
    Professional
    |> where(published: true, category: ^category)
    |> order_by(:position)
    |> Repo.all()
  end

  def get_professional!(id), do: Repo.get!(Professional, id)

  def get_professional_by_slug!(slug) do
    Professional
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(:services)
  end

  def create_professional(attrs) do
    %Professional{}
    |> Professional.changeset(attrs)
    |> Repo.insert()
  end

  def update_professional(%Professional{} = professional, attrs) do
    professional
    |> Professional.changeset(attrs)
    |> Repo.update()
  end

  def delete_professional(%Professional{} = professional) do
    Repo.delete(professional)
  end

  def change_professional(%Professional{} = professional, attrs \\ %{}) do
    Professional.changeset(professional, attrs)
  end

  # --- Helpers ---

  defp load_professionals(ids) when is_list(ids) do
    ids
    |> Enum.reject(&(&1 == "" or is_nil(&1)))
    |> case do
      [] -> []
      ids -> Repo.all(from p in Professional, where: p.id in ^ids)
    end
  end
end
