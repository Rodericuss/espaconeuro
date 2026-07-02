defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Index do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-header">
        <h1>Profissionais</h1>
        <a href={~p"/admin/profissionais/new"} class="btn btn-primary">+ Novo Profissional</a>
      </div>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Nome</th>
              <th>Categoria</th>
              <th>Profissão</th>
              <th>Posição</th>
              <th>Status</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody id="professionals" phx-update="stream">
            <tr :for={{dom_id, pro} <- @streams.professionals} id={dom_id}>
              <td style="font-weight:500;">{pro.name}</td>
              <td>{format_category(pro.category)}</td>
              <td>{pro.profession}</td>
              <td>{pro.position}</td>
              <td>
                <span class={"admin-status #{if pro.published, do: "published", else: "draft"}"}>
                  {if pro.published, do: "Publicado", else: "Rascunho"}
                </span>
              </td>
              <td>
                <div class="actions">
                  <a href={~p"/admin/profissionais/#{pro}/edit"} class="edit-link">Editar</a>
                  <a
                    href="#"
                    phx-click={JS.push("delete", value: %{id: pro.id}) |> hide("##{dom_id}")}
                    data-confirm="Tem certeza?"
                    class="delete-link"
                  >
                    Excluir
                  </a>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
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

  defp format_category(:neuro), do: "Neuropsicologia"
  defp format_category(:psi), do: "Psicologia"
  defp format_category(:pedago), do: "Pedagogia"
  defp format_category(_), do: "—"
end
