defmodule EspacoNeuroWeb.PageControllerTest do
  use EspacoNeuroWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET / renders home page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(
             view,
             "#site-header-logo[src='/images/logo-light.png'][alt='Espaço Neuro']"
           )

    assert has_element?(
             view,
             "#site-footer-logo[src='/images/logo-light.png'][alt='Espaço Neuro']"
           )

    assert has_element?(view, "a", "Agendar consulta")
  end

  test "GET / exposes the new symbol as the browser icon", %{conn: conn} do
    conn = get(conn, ~p"/")

    document =
      conn
      |> html_response(200)
      |> LazyHTML.from_document()

    assert [_favicon] =
             document
             |> LazyHTML.query(
               "link#site-favicon[rel='icon'][href='/images/site-icon.png'][sizes='512x512']"
             )
             |> LazyHTML.to_tree()

    assert [_touch_icon] =
             document
             |> LazyHTML.query("link[rel='apple-touch-icon'][href='/images/site-icon.png']")
             |> LazyHTML.to_tree()
  end

  test "GET /servicos renders services page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/servicos")
    assert has_element?(view, "h1", "Nossos Serviços")
  end

  test "GET /equipe renders team page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/equipe")
    assert has_element?(view, "h1", "Nossa Equipe")
  end
end
