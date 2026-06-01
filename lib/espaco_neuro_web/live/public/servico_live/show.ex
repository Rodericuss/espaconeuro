defmodule EspacoNeuroWeb.ServicoLive.Show do
  use EspacoNeuroWeb, :live_view

  import EspacoNeuroWeb.SiteComponents

  alias EspacoNeuro.Catalog

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    service = Catalog.get_service_by_slug!(slug)

    {:ok,
     socket
     |> assign(:page_title, service.title)
     |> assign(:service, service)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.site_navbar />

    <section class="page-head">
      <div class="wrap">
        <a href={~p"/servicos"} class="back-link">← Serviços</a>
        <div class="svc-detail-header">
          <.service_icon icon={@service.icon} />
          <div>
            <h1>{@service.title}</h1>
            <div class="page-head-meta">
              <span class="attend">{format_modality(@service.modality)}</span>
              <span class="price-tag">{format_price(@service)}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="wrap detail-content">
        <div class="svc-detail-body">
          <div class="svc-detail-icon">
            <.service_icon icon={@service.icon} />
          </div>
          <div class="detail-body">
            <p>{@service.description}</p>
          </div>
        </div>
      </div>
    </section>

    <section :if={@service.professionals != []} class="section" style="background:var(--bg-alt);">
      <div class="wrap">
        <div class="section-head">
          <h2>Profissionais deste serviço</h2>
        </div>
        <div class="team-grid">
          <.professional_card :for={pro <- @service.professionals} professional={pro} />
        </div>
      </div>
    </section>

    <.cta_section />
    <.site_footer />
    """
  end
end
