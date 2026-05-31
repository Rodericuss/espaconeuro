defmodule EspacoNeuro.CatalogTest do
  use EspacoNeuro.DataCase

  alias EspacoNeuro.Catalog

  describe "services" do
    alias EspacoNeuro.Catalog.Service

    import EspacoNeuro.CatalogFixtures

    @invalid_attrs %{title: nil, description: nil, icon: nil, modality: nil, price_kind: nil}

    test "list_services/0 returns all services" do
      service = service_fixture()
      assert Catalog.list_services() == [service]
    end

    test "get_service!/1 returns the service with given id" do
      service = service_fixture()
      assert Catalog.get_service!(service.id) == service
    end

    test "create_service/1 with valid data creates a service" do
      valid_attrs = %{
        title: "Avaliação neuropsicológica",
        description: "some description",
        icon: "brain",
        modality: :presencial,
        price_cents: 35000,
        price_kind: :fixed
      }

      assert {:ok, %Service{} = service} = Catalog.create_service(valid_attrs)
      assert service.title == "Avaliação neuropsicológica"
      assert service.slug == "avaliacao-neuropsicologica"
      assert service.modality == :presencial
      assert service.price_cents == 35000
      assert service.price_kind == :fixed
      assert service.published == true
    end

    test "create_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_service(@invalid_attrs)
    end

    test "update_service/2 with valid data updates the service" do
      service = service_fixture()
      update_attrs = %{title: "Updated Title", price_cents: 50000, published: false}

      assert {:ok, %Service{} = service} = Catalog.update_service(service, update_attrs)
      assert service.title == "Updated Title"
      assert service.slug == "updated-title"
      assert service.price_cents == 50000
      assert service.published == false
    end

    test "update_service/2 with invalid data returns error changeset" do
      service = service_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_service(service, @invalid_attrs)
      assert service == Catalog.get_service!(service.id)
    end

    test "delete_service/1 deletes the service" do
      service = service_fixture()
      assert {:ok, %Service{}} = Catalog.delete_service(service)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_service!(service.id) end
    end

    test "change_service/1 returns a service changeset" do
      service = service_fixture()
      assert %Ecto.Changeset{} = Catalog.change_service(service)
    end

    test "create_service with professionals links them via m2m" do
      pro = professional_fixture()

      attrs = %{
        title: "Service with Pro",
        description: "desc",
        icon: "brain",
        modality: :online,
        price_kind: :on_request
      }

      assert {:ok, %Service{} = service} = Catalog.create_service(attrs, [pro.id])
      service = Catalog.get_service_by_slug!(service.slug)
      assert length(service.professionals) == 1
      assert hd(service.professionals).id == pro.id
    end
  end

  describe "professionals" do
    alias EspacoNeuro.Catalog.Professional

    import EspacoNeuro.CatalogFixtures

    @invalid_attrs %{
      name: nil,
      category: nil,
      profession: nil,
      crp: nil,
      headline: nil,
      description: nil
    }

    test "list_professionals/0 returns all professionals" do
      professional = professional_fixture()
      assert Catalog.list_professionals() == [professional]
    end

    test "get_professional!/1 returns the professional with given id" do
      professional = professional_fixture()
      assert Catalog.get_professional!(professional.id) == professional
    end

    test "create_professional/1 with valid data creates a professional" do
      valid_attrs = %{
        name: "Dra. Helena Marques",
        category: :neuro,
        profession: "Neuropsicóloga",
        crp: "06/123456",
        headline: "Avaliação e reabilitação cognitiva",
        description: "Bio completa"
      }

      assert {:ok, %Professional{} = professional} = Catalog.create_professional(valid_attrs)
      assert professional.name == "Dra. Helena Marques"
      assert professional.slug == "dra-helena-marques"
      assert professional.category == :neuro
      assert professional.published == true
    end

    test "create_professional/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_professional(@invalid_attrs)
    end

    test "update_professional/2 with valid data updates the professional" do
      professional = professional_fixture()
      update_attrs = %{name: "Updated Name", category: :pedago}

      assert {:ok, %Professional{} = professional} =
               Catalog.update_professional(professional, update_attrs)

      assert professional.name == "Updated Name"
      assert professional.slug == "updated-name"
      assert professional.category == :pedago
    end

    test "update_professional/2 with invalid data returns error changeset" do
      professional = professional_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Catalog.update_professional(professional, @invalid_attrs)

      assert professional == Catalog.get_professional!(professional.id)
    end

    test "delete_professional/1 deletes the professional" do
      professional = professional_fixture()
      assert {:ok, %Professional{}} = Catalog.delete_professional(professional)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_professional!(professional.id) end
    end

    test "change_professional/1 returns a professional changeset" do
      professional = professional_fixture()
      assert %Ecto.Changeset{} = Catalog.change_professional(professional)
    end
  end
end
