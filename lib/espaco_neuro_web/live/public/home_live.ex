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

    <section class="site-hero">
      <div class="wrap hero-grid">
        <div class="hero-copy">
          <span class="eyebrow on-dark">CLÍNICA ESPECIALIZADA EM NEUROPSICOLOGIA </span>
          <h1>
            Entendendo antes de <b>tratar</b> <br /> Cuidando depois de <b>compreender</b>
          </h1>
          <p class="lead">
            Avaliações neuropsicológicas completas e acompanhamento terapêutico para crianças, adolescentes, adultos e idosos, com atendimento baseado em evidências científicas, ética e cuidado individualizado.
          </p>
          <div class="hero-btns">
            <a href="#contato" class="btn btn-primary">Agendar avaliação</a>
            <a href={~p"/servicos"} class="btn btn-ghost-dark">Conhecer nossos serviços</a>
          </div>
          <div class="hero-trust">
            <div class="ti">
              <span class="num">+10.000</span><span class="lab">Pacientes atendidos</span>
            </div>
          </div>
        </div>
        <div class="hero-visual">
          <img src={~p"/images/heroimageduo.jpeg"} alt="Espaço Neuro" class="hero-img" />
          <div class="hero-badge">
            <div class="ic">
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><polyline points="22 4 12 14.01 9 11.01" />
              </svg>
            </div>
            <div class="tx">
              <strong>Experiência clínica</strong>
              <span>Equipe com +30 anos de trajetória profissional</span>
            </div>
          </div>
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
          <span class="eyebrow">Cuidado especializado em todas as etapas</span>
          <h2>Em que podemos ajudar você</h2>
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
        <img src={~p"/images/secondimagefit.jpeg"} alt="Nossa abordagem" class="approach-photo" />
        <div>
          <span class="eyebrow">Nossa abordagem</span>
          <h2>Ciência, ética e cuidado em cada etapa do atendimento.</h2>
          <p style="color:var(--text-muted);margin:16px 0 28px;">
            Cada paciente possui uma história única. Por isso, nossas decisões clínicas não são baseadas apenas em sintomas, mas em uma avaliação completa que considera aspectos cognitivos, emocionais, comportamentais e funcionais. Esse processo permite oferecer um cuidado ético, preciso e verdadeiramente individualizado.
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
                <p>
                  Utilizamos instrumentos validados e práticas fundamentadas na ciência para garantir avaliações e intervenções confiáveis.
                </p>
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
                <p>
                  Laudos acessíveis, com orientações práticas para a família e a escola. Cada conclusão é construída a partir da integração entre testes, entrevistas, observação clínica e análise especializada.
                </p>
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
                <h4>Excelência técnica</h4>
                <p>
                  Um cuidado construído para cada paciente, com intervenções individualizadas, embasamento científico e profissionais com mais de trinta anos de experiência.
                </p>
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
          <a :for={pro <- @professionals} href={~p"/equipe/#{pro.slug}"} class="tt-card">
            <div class="tt-photo">
              <img :if={pro.photo_path} src={pro.photo_path} alt={pro.name} />
            </div>
            <div class="tt-body">
              <h4>{pro.name}</h4>
              <span class="tt-role">{pro.profession}</span>
            </div>
          </a>
        </div>
        <div style="text-align:center;margin-top:40px;">
          <a href={~p"/equipe"} class="btn btn-navy">Conhecer toda a equipe</a>
        </div>
      </div>
    </section>

    <section class="cta" id="contato">
      <div class="wrap" style="text-align:center;">
        <span class="eyebrow on-dark" style="justify-content:center;">Vamos começar</span>
        <h2 style="color:var(--n-50);font-size:clamp(32px,4.5vw,46px);margin-top:20px;">
          O primeiro passo<br />pode ser hoje.
        </h2>
        <p style="color:var(--navy-300);font-size:18px;margin:20px auto 36px;max-width:52ch;">
          Conte para a gente o que está buscando. Retornamos em até um dia útil para encontrar o melhor caminho e profissional para você.
        </p>
        <div style="display:flex;gap:14px;justify-content:center;flex-wrap:wrap;">
          <a
            href="https://wa.me/5543999721540?text=Ol%C3%A1.%20Gostaria%20de%20conhecer%20mais%20sobre%20a%20Espa%C3%A7o%20Neuro."
            class="btn btn-primary"
            target="_blank"
          >
            Falar no WhatsApp
          </a>
          <a href="mailto:profissionalvmb@gmail.com" class="btn btn-ghost-dark">
            Enviar e-mail
          </a>
        </div>
      </div>
    </section>
    <.site_footer />
    """
  end
end
