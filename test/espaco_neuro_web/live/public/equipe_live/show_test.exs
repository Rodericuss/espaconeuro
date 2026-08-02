defmodule EspacoNeuroWeb.EquipeLive.ShowTest do
  use EspacoNeuroWeb.ConnCase, async: true

  import EspacoNeuro.CatalogFixtures
  import Phoenix.LiveViewTest

  test "presents the profile text in a readable card with separate paragraphs", %{conn: conn} do
    professional =
      professional_fixture(%{
        description: "Primeiro parágrafo da biografia.\n\nSegundo parágrafo da biografia."
      })

    {:ok, view, _html} = live(conn, ~p"/equipe/#{professional.slug}")

    assert has_element?(view, "#professional-profile-card")
    assert has_element?(view, "#professional-biography p + p")
    assert has_element?(view, ".professional-profile-meta-grid")
  end
end
