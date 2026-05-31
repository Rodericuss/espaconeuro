defmodule EspacoNeuro.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EspacoNeuro.Catalog` context.
  """

  def unique_service_title, do: "Service #{System.unique_integer([:positive])}"
  def unique_professional_name, do: "Professional #{System.unique_integer([:positive])}"

  def service_fixture(attrs \\ %{}) do
    {:ok, service} =
      attrs
      |> Enum.into(%{
        title: unique_service_title(),
        description: "some description",
        icon: "brain",
        modality: :presencial,
        price_cents: 35000,
        price_kind: :fixed,
        published: true,
        summary: "some summary"
      })
      |> EspacoNeuro.Catalog.create_service()

    service
  end

  def professional_fixture(attrs \\ %{}) do
    {:ok, professional} =
      attrs
      |> Enum.into(%{
        name: unique_professional_name(),
        category: :psi,
        profession: "Psicóloga",
        crp: "06/123456",
        headline: "some headline",
        description: "some description",
        approach: "TCC",
        specialties: ["TDAH", "Ansiedade"],
        modalities: ["Presencial", "Online"],
        whatsapp: "5511999990000",
        email: "pro@example.com",
        published: true
      })
      |> EspacoNeuro.Catalog.create_professional()

    professional
  end
end
