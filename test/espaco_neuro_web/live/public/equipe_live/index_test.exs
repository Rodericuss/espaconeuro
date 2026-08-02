defmodule EspacoNeuroWeb.EquipeLive.IndexTest do
  use EspacoNeuroWeb.ConnCase, async: true

  import EspacoNeuro.CatalogFixtures
  import Phoenix.LiveViewTest

  test "makes the complete professional card navigate to the profile", %{conn: conn} do
    professional = professional_fixture()
    {:ok, view, _html} = live(conn, ~p"/equipe")

    assert has_element?(view, "#professional-card-#{professional.id}")

    assert has_element?(
             view,
             "#professional-card-link-#{professional.id}[href='/equipe/#{professional.slug}']"
           )
  end

  test "keeps the complete headline for responsive visual fitting", %{conn: conn} do
    complete_text = String.duplicate("á", 180) <> " trecho final preservado"
    professional = professional_fixture(%{headline: complete_text})

    {:ok, view, _html} = live(conn, ~p"/equipe")

    assert has_element?(
             view,
             "#professional-card-text-#{professional.id}[data-base-lines='1']",
             complete_text
           )
  end

  test "keeps the complete description in the card for responsive visual clamping", %{conn: conn} do
    complete_description = String.duplicate("d", 150) <> " descrição preservada"

    professional =
      professional_fixture(%{
        headline: "Texto teal do card",
        summary: complete_description
      })

    {:ok, view, _html} = live(conn, ~p"/equipe")

    assert has_element?(
             view,
             "#professional-card-text-#{professional.id}",
             "Texto teal do card"
           )

    assert has_element?(
             view,
             "#professional-card-summary-#{professional.id}[data-base-lines='4']",
             complete_description
           )

    assert has_element?(
             view,
             "#team-grid[phx-hook='ProfessionalCardTextFit'][phx-update='stream']"
           )
  end

  test "uses character budgets and indicates only hidden specialties", %{conn: conn} do
    specialties = [
      String.duplicate("A", 40),
      String.duplicate("B", 40),
      String.duplicate("C", 40),
      "Especialidade oculta"
    ]

    modalities = [
      String.duplicate("D", 8),
      String.duplicate("E", 8),
      String.duplicate("F", 8),
      "Modalidade oculta"
    ]

    professional =
      professional_fixture(%{specialties: specialties, modalities: modalities})

    {:ok, view, _html} = live(conn, ~p"/equipe")

    specialties_selector = "#professional-specialties-#{professional.id}"
    modalities_selector = "#professional-modalities-#{professional.id}"

    assert has_element?(view, "#{specialties_selector} .spec", Enum.at(specialties, 0))
    assert has_element?(view, "#{specialties_selector} .spec", Enum.at(specialties, 1))
    refute has_element?(view, "#{specialties_selector} .spec", Enum.at(specialties, 2))

    assert has_element?(
             view,
             "#{specialties_selector} .spec-more[data-hidden-count='2']",
             "E mais"
           )

    assert has_element?(view, "#{modalities_selector} .attend", Enum.at(modalities, 0))
    assert has_element?(view, "#{modalities_selector} .attend", Enum.at(modalities, 1))
    refute has_element?(view, "#{modalities_selector} .attend", Enum.at(modalities, 2))
    refute has_element?(view, "#{modalities_selector} .attend-more")
    refute has_element?(view, "#{modalities_selector} .attend", "E mais")
  end
end
