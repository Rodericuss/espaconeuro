defmodule EspacoNeuroWeb.Admin.ServiceLive.Show do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@service.title}
        <:actions>
          <.button navigate={~p"/admin/servicos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/servicos/#{@service}/edit"}>
            <.icon name="hero-pencil-square" /> Editar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@service.slug}</:item>
        <:item title="Modalidade">{@service.modality}</:item>
        <:item title="Preço">{format_price(@service)}</:item>
        <:item title="Publicado">{if @service.published, do: "Sim", else: "Não"}</:item>
        <:item title="Profissionais">
          {Enum.map_join(@service.professionals, ", ", & &1.name)}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    service = Catalog.get_service!(id)

    {:ok,
     socket
     |> assign(:page_title, service.title)
     |> assign(:service, service)}
  end

  defp format_price(%{price_kind: :on_request}), do: "Sob consulta"
  defp format_price(%{price_kind: :fixed, price_cents: cents}), do: "R$ #{format_cents(cents)}"

  defp format_price(%{price_kind: :from, price_cents: cents}),
    do: "A partir de R$ #{format_cents(cents)}"

  defp format_cents(nil), do: "—"
  defp format_cents(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)
end
