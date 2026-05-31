defmodule EspacoNeuroWeb.PageController do
  use EspacoNeuroWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
