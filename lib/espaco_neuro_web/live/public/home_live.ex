defmodule EspacoNeuroWeb.HomeLive do
  use EspacoNeuroWeb, :live_view

  import EspacoNeuroWeb.SiteComponents

  alias EspacoNeuro.Catalog

  @impl true
  def mount(_params, _session, socket) do
    services = Catalog.list_published_services()
    professionals = Catalog.list_published_professionals() |> Enum.take(3)

    {:ok,
     socket
     |> assign(:page_title, "Início")
     |> assign(:services, services)
     |> assign(:professionals, professionals)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.site_navbar current="home" />

    <section class="hero">
      <div class="wrap hero-grid">
        <div class="hero-copy">
          <span class="eyebrow on-dark">Clínica de neuropsicologia</span>
          <h1>Cuidado que respeita o <b>seu tempo</b> e o seu espaço.</h1>
          <p class="lead">
            Avaliação e acompanhamento neuropsicológico humano, claro e baseado em evidências — para todas as idades, presencial ou online.
          </p>
          <div class="hero-btns">
            <a href="#contato" class="btn btn-primary">Agendar consulta</a>
            <a href={~p"/equipe"} class="btn btn-ghost-dark">Conhecer a equipe</a>
          </div>
          <div class="hero-trust">
            <div class="ti">
              <span class="num">+500</span><span class="lab">Pacientes atendidos</span>
            </div>
            <div class="ti"><span class="num">9</span><span class="lab">Profissionais</span></div>
            <div class="ti"><span class="num">3</span><span class="lab">Áreas de atuação</span></div>
          </div>
        </div>
        <div class="hero-visual">
          <div class="hero-photo"></div>
        </div>
      </div>
    </section>

    <section class="section trust-strip">
      <div class="wrap">
        <div class="trust-grid">
          <div class="trust-item">
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z" /><path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z" />
            </svg>
            <span>Neuropsicologia</span>
          </div>
          <div class="trust-item">
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M20.42 4.58a5.4 5.4 0 0 0-7.65 0L12 5.35l-.77-.77a5.4 5.4 0 0 0-7.65 7.65l.77.77L12 20.66l7.65-7.66.77-.77a5.4 5.4 0 0 0 0-7.65z" />
            </svg>
            <span>Psicologia</span>
          </div>
          <div class="trust-item">
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" /><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
            </svg>
            <span>Neuropsicopedagogia</span>
          </div>
        </div>
      </div>
    </section>

    <section class="section" id="servicos">
      <div class="wrap">
        <div class="section-head">
          <span class="eyebrow">Nossos serviços</span>
          <h2>Como podemos ajudar</h2>
        </div>
        <div class="svc-grid">
          <.service_card :for={service <- @services} service={service} />
        </div>
        <div style="text-align:center;margin-top:40px;">
          <a href={~p"/servicos"} class="btn btn-navy">Ver todos os serviços</a>
        </div>
      </div>
    </section>

    <section class="section approach" id="abordagem">
      <div class="wrap approach-grid">
        <div class="approach-photo"></div>
        <div>
          <span class="eyebrow">Nossa abordagem</span>
          <h2>Baseada em evidências, centrada em você</h2>
          <p style="color:var(--text-muted);margin:16px 0 28px;">
            Acreditamos que cada pessoa é única. Por isso, nosso atendimento combina rigor científico com sensibilidade humana.
          </p>
          <ul class="feat-list">
            <li>
              <div class="fi">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                >
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
              </div>
              <div>
                <h4>Avaliação completa</h4>
                <p>Protocolos validados cientificamente para cada faixa etária.</p>
              </div>
            </li>
            <li>
              <div class="fi">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                >
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
              </div>
              <div>
                <h4>Devolutiva clara</h4>
                <p>Laudos acessíveis, com orientações práticas para a família e a escola.</p>
              </div>
            </li>
            <li>
              <div class="fi">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2.5"
                >
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
              </div>
              <div>
                <h4>Acompanhamento contínuo</h4>
                <p>Planos de intervenção que evoluem com você.</p>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section class="section" style="background:var(--bg-alt);">
      <div class="wrap">
        <div class="section-head">
          <span class="eyebrow">Nossa equipe</span>
          <h2>Profissionais dedicados ao seu bem-estar</h2>
        </div>
        <div class="tt-grid">
          <div :for={pro <- @professionals} class="tt-card">
            <div class="tt-photo-wrap">
              <div class="tt-photo"></div>
            </div>
            <h4>{pro.name}</h4>
            <span class="tt-role">{pro.profession}</span>
          </div>
        </div>
        <div style="text-align:center;margin-top:40px;">
          <a href={~p"/equipe"} class="btn btn-navy">Conhecer toda a equipe</a>
        </div>
      </div>
    </section>

    <.cta_section />
    <.site_footer />
    """
  end
end
