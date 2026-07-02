defmodule EspacoNeuroWeb.Admin.ServiceLive.Index do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-header">
        <h1>Serviços</h1>
        <a href={~p"/admin/servicos/new"} class="btn btn-primary">+ Novo Serviço</a>
      </div>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Título</th>
              <th>Modalidade</th>
              <th>Preço</th>
              <th>Posição</th>
              <th>Status</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody id="services" phx-update="stream">
            <tr :for={{dom_id, service} <- @streams.services} id={dom_id}>
              <td style="font-weight:500;">{service.title}</td>
              <td>{format_modality(service.modality)}</td>
              <td>{format_price(service)}</td>
              <td>{service.position}</td>
              <td>
                <span class={"admin-status #{if service.published, do: "published", else: "draft"}"}>
                  {if service.published, do: "Publicado", else: "Rascunho"}
                </span>
              </td>
              <td>
                <div class="actions">
                  <a href={~p"/admin/servicos/#{service}/edit"} class="edit-link">Editar</a>
                  <a
                    href="#"
                    phx-click={JS.push("delete", value: %{id: service.id}) |> hide("##{dom_id}")}
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
     |> assign(:page_title, "Serviços")
     |> stream(:services, Catalog.list_services())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    service = Catalog.get_service!(id)
    {:ok, _} = Catalog.delete_service(service)

    {:noreply, stream_delete(socket, :services, service)}
  end

  defp format_price(%{price_kind: :on_request}), do: "Sob consulta"
  defp format_price(%{price_kind: :fixed, price_cents: cents}), do: "R$ #{format_cents(cents)}"

  defp format_price(%{price_kind: :from, price_cents: cents}),
    do: "A partir de R$ #{format_cents(cents)}"

  defp format_cents(nil), do: "—"
  defp format_cents(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)

  defp format_modality(:presencial), do: "Presencial"
  defp format_modality(:online), do: "Online"
  defp format_modality(:ambos), do: "Presencial e Online"
  defp format_modality(_), do: "—"
end
