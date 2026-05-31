defmodule EspacoNeuroWeb.EquipeLive.Show do
  use EspacoNeuroWeb, :live_view

  import EspacoNeuroWeb.SiteComponents

  alias EspacoNeuro.Catalog

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    professional = Catalog.get_professional_by_slug!(slug)

    {:ok,
     socket
     |> assign(:page_title, professional.name)
     |> assign(:professional, professional)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.site_navbar current="equipe" />

    <section class="page-head">
      <div class="wrap">
        <a href={~p"/equipe"} class="back-link">← Equipe</a>
        <div class="pro-detail-header">
          <div class="pro-detail-photo-wrap">
            <img
              :if={@professional.photo_path}
              src={@professional.photo_path}
              alt={@professional.name}
              class="pro-detail-photo"
            />
            <div :if={!@professional.photo_path} class="pro-detail-photo pro-photo-placeholder"></div>
          </div>
          <div class="pro-detail-info">
            <span class="pro-prof">{@professional.profession}</span>
            <h1>{@professional.name}</h1>
            <span class="pro-crp">{@professional.crp}</span>
            <div class="pro-title">{@professional.headline}</div>
          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="wrap detail-content">
        <div class="detail-body">
          <p>{@professional.description}</p>

          <div :if={@professional.approach} class="detail-meta">
            <h3>Abordagem</h3>
            <p>{@professional.approach}</p>
          </div>

          <div :if={@professional.specialties != []} class="detail-meta">
            <h3>Especialidades</h3>
            <div class="spec-list">
              <span :for={spec <- @professional.specialties || []} class="spec">{spec}</span>
            </div>
          </div>

          <div :if={@professional.modalities != []} class="detail-meta">
            <h3>Modalidades de atendimento</h3>
            <div class="pro-foot">
              <span :for={mod <- @professional.modalities || []} class="attend">{mod}</span>
            </div>
          </div>

          <div class="detail-contact">
            <a
              :if={@professional.whatsapp}
              href={"https://wa.me/#{@professional.whatsapp}"}
              class="btn btn-primary"
              target="_blank"
            >
              Agendar pelo WhatsApp
            </a>
            <a
              :if={@professional.email}
              href={"mailto:#{@professional.email}"}
              class="btn btn-ghost-dark"
            >
              Enviar e-mail
            </a>
          </div>
        </div>
      </div>
    </section>

    <section :if={@professional.services != []} class="section" style="background:var(--bg-alt);">
      <div class="wrap">
        <div class="section-head">
          <h2>Serviços atendidos</h2>
        </div>
        <div class="svc-grid">
          <.service_card :for={service <- @professional.services} service={service} />
        </div>
      </div>
    </section>

    <.cta_section />
    <.site_footer />
    """
  end
end
