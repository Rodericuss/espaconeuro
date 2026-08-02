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
     |> assign(:professional, professional)
     |> assign(:description_paragraphs, description_paragraphs(professional.description))}
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
            <span :if={@professional.crp} class="pro-crp">{@professional.crp}</span>
            <div class="pro-title">{@professional.headline}</div>
          </div>
        </div>
      </div>
    </section>

    <section class="section professional-profile-section">
      <div class="wrap professional-profile-shell">
        <article id="professional-profile-card" class="professional-profile-card">
          <div id="professional-biography" class="professional-profile-intro">
            <span class="professional-profile-kicker">Conheça a profissional</span>
            <h2>Sobre {@professional.name}</h2>
            <div class="professional-profile-copy">
              <p :for={paragraph <- @description_paragraphs}>{paragraph}</p>
            </div>
          </div>

          <div class="professional-profile-meta-grid">
            <section :if={@professional.approach} class="professional-profile-meta-card">
              <h3>Abordagem</h3>
              <p>{@professional.approach}</p>
            </section>

            <section
              :if={@professional.modalities != []}
              class="professional-profile-meta-card"
            >
              <h3>Modalidades de atendimento</h3>
              <div class="pro-foot">
                <span :for={mod <- @professional.modalities || []} class="attend">{mod}</span>
              </div>
            </section>

            <section
              :if={@professional.specialties != []}
              class="professional-profile-meta-card professional-profile-meta-card-wide"
            >
              <h3>Especialidades</h3>
              <div class="spec-list">
                <span :for={spec <- @professional.specialties || []} class="spec">{spec}</span>
              </div>
            </section>
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
        </article>
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

  defp description_paragraphs(description) do
    description
    |> String.split(~r/\R{2,}/)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
