defmodule EspacoNeuroWeb.ProfessionalLive.Index do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Professionals
        <:actions>
          <.button variant="primary" navigate={~p"/professionals/new"}>
            <.icon name="hero-plus" /> New Professional
          </.button>
        </:actions>
      </.header>

      <.table
        id="professionals"
        rows={@streams.professionals}
        row_click={fn {_id, professional} -> JS.navigate(~p"/professionals/#{professional}") end}
      >
        <:col :let={{_id, professional}} label="Name">{professional.name}</:col>
        <:col :let={{_id, professional}} label="Slug">{professional.slug}</:col>
        <:col :let={{_id, professional}} label="Category">{professional.category}</:col>
        <:col :let={{_id, professional}} label="Profession">{professional.profession}</:col>
        <:col :let={{_id, professional}} label="Crp">{professional.crp}</:col>
        <:col :let={{_id, professional}} label="Headline">{professional.headline}</:col>
        <:col :let={{_id, professional}} label="Summary">{professional.summary}</:col>
        <:col :let={{_id, professional}} label="Description">{professional.description}</:col>
        <:col :let={{_id, professional}} label="Approach">{professional.approach}</:col>
        <:col :let={{_id, professional}} label="Specialties">{professional.specialties}</:col>
        <:col :let={{_id, professional}} label="Modalities">{professional.modalities}</:col>
        <:col :let={{_id, professional}} label="Whatsapp">{professional.whatsapp}</:col>
        <:col :let={{_id, professional}} label="Email">{professional.email}</:col>
        <:col :let={{_id, professional}} label="Photo path">{professional.photo_path}</:col>
        <:col :let={{_id, professional}} label="Position">{professional.position}</:col>
        <:col :let={{_id, professional}} label="Published">{professional.published}</:col>
        <:action :let={{_id, professional}}>
          <div class="sr-only">
            <.link navigate={~p"/professionals/#{professional}"}>Show</.link>
          </div>
          <.link navigate={~p"/professionals/#{professional}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, professional}}>
          <.link
            phx-click={JS.push("delete", value: %{id: professional.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
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
     |> assign(:page_title, "Listing Professionals")
     |> stream(:professionals, list_professionals())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    professional = Catalog.get_professional!(id)
    {:ok, _} = Catalog.delete_professional(professional)

    {:noreply, stream_delete(socket, :professionals, professional)}
  end

  defp list_professionals() do
    Catalog.list_professionals()
  end
end
