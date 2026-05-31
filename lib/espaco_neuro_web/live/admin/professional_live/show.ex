defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Show do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@professional.name}
        <:actions>
          <.button navigate={~p"/admin/profissionais"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/profissionais/#{@professional}/edit"}>
            <.icon name="hero-pencil-square" /> Editar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Categoria">{@professional.category}</:item>
        <:item title="Profissão">{@professional.profession}</:item>
        <:item title="CRP">{@professional.crp}</:item>
        <:item title="Headline">{@professional.headline}</:item>
        <:item title="Abordagem">{@professional.approach}</:item>
        <:item title="Especialidades">{Enum.join(@professional.specialties || [], ", ")}</:item>
        <:item title="Modalidades">{Enum.join(@professional.modalities || [], ", ")}</:item>
        <:item title="WhatsApp">{@professional.whatsapp}</:item>
        <:item title="E-mail">{@professional.email}</:item>
        <:item title="Publicado">{if @professional.published, do: "Sim", else: "Não"}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    professional = Catalog.get_professional!(id)

    {:ok,
     socket
     |> assign(:page_title, professional.name)
     |> assign(:professional, professional)}
  end
end
