defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Index do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Profissionais
        <:actions>
          <.button variant="primary" navigate={~p"/admin/profissionais/new"}>
            <.icon name="hero-plus" /> Novo Profissional
          </.button>
        </:actions>
      </.header>

      <.table
        id="professionals"
        rows={@streams.professionals}
        row_click={fn {_id, pro} -> JS.navigate(~p"/admin/profissionais/#{pro}") end}
      >
        <:col :let={{_id, pro}} label="Nome">{pro.name}</:col>
        <:col :let={{_id, pro}} label="Categoria">{pro.category}</:col>
        <:col :let={{_id, pro}} label="Profissão">{pro.profession}</:col>
        <:col :let={{_id, pro}} label="Posição">{pro.position}</:col>
        <:col :let={{_id, pro}} label="Publicado">{if pro.published, do: "Sim", else: "Não"}</:col>
        <:action :let={{_id, pro}}>
          <.link navigate={~p"/admin/profissionais/#{pro}/edit"}>Editar</.link>
        </:action>
        <:action :let={{id, pro}}>
          <.link
            phx-click={JS.push("delete", value: %{id: pro.id}) |> hide("##{id}")}
            data-confirm="Tem certeza?"
          >
            Excluir
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Profissionais")
     |> stream(:professionals, Catalog.list_professionals())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    professional = Catalog.get_professional!(id)
    {:ok, _} = Catalog.delete_professional(professional)

    {:noreply, stream_delete(socket, :professionals, professional)}
  end
end
