defmodule EspacoNeuroWeb.ServicoLive.Index do
  use EspacoNeuroWeb, :live_view

  import EspacoNeuroWeb.SiteComponents

  alias EspacoNeuro.Catalog

  @impl true
  def mount(_params, _session, socket) do
    services = Catalog.list_published_services()

    {:ok,
     socket
     |> assign(:page_title, "Serviços")
     |> assign(:services, services)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.site_navbar current="servicos" />

    <section class="page-head">
      <div class="wrap">
        <span class="eyebrow on-dark">O que oferecemos</span>
        <h1>Nossos Serviços</h1>
        <p class="page-head-sub">Avaliação, intervenção e acompanhamento para todas as idades.</p>
      </div>
    </section>

    <section class="section">
      <div class="wrap">
        <div class="svc-grid">
          <.service_card :for={service <- @services} service={service} />
        </div>
      </div>
    </section>

    <.cta_section />
    <.site_footer />
    """
  end
end
