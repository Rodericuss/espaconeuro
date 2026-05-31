defmodule EspacoNeuroWeb.ServiceLive.Show do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Service {@service.id}
        <:subtitle>This is a service record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/services"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/services/#{@service}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit service
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@service.title}</:item>
        <:item title="Slug">{@service.slug}</:item>
        <:item title="Summary">{@service.summary}</:item>
        <:item title="Description">{@service.description}</:item>
        <:item title="Icon">{@service.icon}</:item>
        <:item title="Modality">{@service.modality}</:item>
        <:item title="Price cents">{@service.price_cents}</:item>
        <:item title="Price kind">{@service.price_kind}</:item>
        <:item title="Position">{@service.position}</:item>
        <:item title="Published">{@service.published}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Service")
     |> assign(:service, Catalog.get_service!(id))}
  end
end
