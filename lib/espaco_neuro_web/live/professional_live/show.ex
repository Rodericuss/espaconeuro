defmodule EspacoNeuroWeb.ProfessionalLive.Show do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Professional {@professional.id}
        <:subtitle>This is a professional record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/professionals"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/professionals/#{@professional}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit professional
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@professional.name}</:item>
        <:item title="Slug">{@professional.slug}</:item>
        <:item title="Category">{@professional.category}</:item>
        <:item title="Profession">{@professional.profession}</:item>
        <:item title="Crp">{@professional.crp}</:item>
        <:item title="Headline">{@professional.headline}</:item>
        <:item title="Summary">{@professional.summary}</:item>
        <:item title="Description">{@professional.description}</:item>
        <:item title="Approach">{@professional.approach}</:item>
        <:item title="Specialties">{@professional.specialties}</:item>
        <:item title="Modalities">{@professional.modalities}</:item>
        <:item title="Whatsapp">{@professional.whatsapp}</:item>
        <:item title="Email">{@professional.email}</:item>
        <:item title="Photo path">{@professional.photo_path}</:item>
        <:item title="Position">{@professional.position}</:item>
        <:item title="Published">{@professional.published}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Professional")
     |> assign(:professional, Catalog.get_professional!(id))}
  end
end
