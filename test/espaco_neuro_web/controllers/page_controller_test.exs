defmodule EspacoNeuroWeb.PageControllerTest do
  use EspacoNeuroWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET / renders home page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Espaço Neuro"
    assert html =~ "Agendar consulta"
  end

  test "GET /servicos renders services page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/servicos")
    assert html =~ "Nossos Serviços"
  end

  test "GET /equipe renders team page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/equipe")
    assert html =~ "Nossa Equipe"
  end
end
