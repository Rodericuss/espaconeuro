defmodule EspacoNeuroWeb.Admin.ServiceLive.Index do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Serviços
        <:actions>
          <.button variant="primary" navigate={~p"/admin/servicos/new"}>
            <.icon name="hero-plus" /> Novo Serviço
          </.button>
        </:actions>
      </.header>

      <.table
        id="services"
        rows={@streams.services}
        row_click={fn {_id, service} -> JS.navigate(~p"/admin/servicos/#{service}") end}
      >
        <:col :let={{_id, service}} label="Título">{service.title}</:col>
        <:col :let={{_id, service}} label="Modalidade">{service.modality}</:col>
        <:col :let={{_id, service}} label="Preço">{format_price(service)}</:col>
        <:col :let={{_id, service}} label="Posição">{service.position}</:col>
        <:col :let={{_id, service}} label="Publicado">
          {if service.published, do: "Sim", else: "Não"}
        </:col>
        <:action :let={{_id, service}}>
          <.link navigate={~p"/admin/servicos/#{service}/edit"}>Editar</.link>
        </:action>
        <:action :let={{id, service}}>
          <.link
            phx-click={JS.push("delete", value: %{id: service.id}) |> hide("##{id}")}
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
end
