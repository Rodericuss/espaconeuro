defmodule EspacoNeuroWeb.SiteComponents do
  use Phoenix.Component
  use EspacoNeuroWeb, :verified_routes

  @icons %{
    "brain" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"></path><path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"></path></svg>),
    "heart" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.42 4.58a5.4 5.4 0 0 0-7.65 0L12 5.35l-.77-.77a5.4 5.4 0 0 0-7.65 7.65l.77.77L12 20.66l7.65-7.66.77-.77a5.4 5.4 0 0 0 0-7.65z"></path></svg>),
    "book" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>),
    "puzzle" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19.439 7.85c-.049.322.059.648.289.878l1.568 1.568c.47.47.706 1.087.706 1.704s-.235 1.233-.706 1.704l-1.611 1.611a.98.98 0 0 1-.837.276c-.47-.07-.802-.48-.968-.925a2.501 2.501 0 1 0-3.214 3.214c.446.166.855.497.925.968a.979.979 0 0 1-.276.837l-1.61 1.61a2.404 2.404 0 0 1-1.705.707 2.402 2.402 0 0 1-1.704-.706l-1.568-1.568a1.026 1.026 0 0 0-.877-.29c-.493.074-.84.504-1.02.968a2.5 2.5 0 1 1-3.237-3.237c.464-.18.894-.527.967-1.02a1.026 1.026 0 0 0-.289-.877l-1.568-1.568A2.402 2.402 0 0 1 1.998 12c0-.617.236-1.234.706-1.704L4.23 8.77c.24-.24.581-.353.917-.303.515.077.877.528 1.073 1.01a2.5 2.5 0 1 0 3.259-3.259c-.482-.196-.933-.558-1.01-1.073-.05-.336.062-.676.303-.917l1.525-1.525A2.402 2.402 0 0 1 12 1.998c.617 0 1.234.236 1.704.706l1.568 1.568c.23.23.556.338.878.29.493-.074.84-.504 1.02-.968a2.5 2.5 0 1 1 3.237 3.237c-.464.18-.894.527-.967 1.02Z"></path></svg>),
    "clipboard" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path></svg>),
    "stethoscope" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.8 2.3A.3.3 0 1 0 5 2H4a2 2 0 0 0-2 2v5a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6V4a2 2 0 0 0-2-2h-1a.2.2 0 1 0 .3.3"></path><path d="M8 15v1a6 6 0 0 0 6 6h.7"></path><path d="M19 17a2 2 0 1 0 0-4 2 2 0 0 0 0 4z"></path></svg>),
    "users" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>),
    "chat" =>
      ~s(<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>)
  }

  def service_icon(assigns) do
    icon_svg = Map.get(@icons, assigns.icon, @icons["brain"])
    assigns = assign(assigns, :icon_svg, icon_svg)

    ~H"""
    <div class="ic">{Phoenix.HTML.raw(@icon_svg)}</div>
    """
  end

  attr :service, :map, required: true

  def service_card(assigns) do
    ~H"""
    <article class="svc-card">
      <.service_icon icon={@service.icon} />
      <h3>{@service.title}</h3>
      <p>{@service.summary || String.slice(@service.description, 0, 120) <> "..."}</p>
      <div class="svc-meta">
        <span class="attend">{format_modality(@service.modality)}</span>
        <span class="svc-price">{format_price(@service)}</span>
      </div>
      <a href={~p"/servicos/#{@service.slug}"} class="more">
        Saiba mais
        <svg
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="5" y1="12" x2="19" y2="12"></line>
          <polyline points="12 5 19 12 12 19"></polyline>
        </svg>
      </a>
    </article>
    """
  end

  attr :professional, :map, required: true

  def professional_card(assigns) do
    ~H"""
    <article class="pro-card" data-cat={@professional.category}>
      <div class="pro-photo-wrap">
        <img
          :if={@professional.photo_path}
          src={@professional.photo_path}
          alt={@professional.name}
          class="pro-photo"
        />
        <div :if={!@professional.photo_path} class="pro-photo pro-photo-placeholder"></div>
        <span class="pro-prof">{@professional.profession}</span>
      </div>
      <div class="pro-body">
        <h3 class="pro-name">{@professional.name}</h3>
        <span class="pro-crp">{@professional.crp}</span>
        <div class="pro-title">{@professional.headline}</div>
        <p class="pro-desc">
          {@professional.summary || String.slice(@professional.description, 0, 150) <> "..."}
        </p>
        <div :if={@professional.specialties != []} class="pro-label">Especializações</div>
        <div :if={@professional.specialties != []} class="spec-list">
          <span :for={spec <- @professional.specialties || []} class="spec">{spec}</span>
        </div>
        <div class="pro-foot">
          <span :for={mod <- @professional.modalities || []} class="attend">{mod}</span>
        </div>
        <div class="pro-actions">
          <a
            :if={@professional.whatsapp}
            href={"https://wa.me/#{@professional.whatsapp}"}
            class="btn btn-primary btn-sm"
            target="_blank"
          >
            WhatsApp
          </a>
          <a href={~p"/equipe/#{@professional.slug}"} class="more">
            Saiba mais
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12"></line>
              <polyline points="12 5 19 12 12 19"></polyline>
            </svg>
          </a>
        </div>
      </div>
    </article>
    """
  end

  attr :current, :string, default: "home"

  def site_navbar(assigns) do
    ~H"""
    <header class="nav" id="site-nav">
      <div class="wrap nav-inner">
        <a href={~p"/"} class="nav-brand">
          <img
            src={~p"/images/logo-wordmark.png"}
            alt="Espaço Neuro"
            style="height:52px;width:auto;"
          />
        </a>
        <nav class="nav-links">
          <a href={~p"/"} class={if @current == "home", do: "active"}>Início</a>
          <a href={~p"/servicos"}>Serviços</a>
          <a href="/#abordagem">Abordagem</a>
          <a href={~p"/equipe"} class={if @current == "equipe", do: "active"}>Equipe</a>
          <a href="/#contato">Contato</a>
        </nav>
        <div class="nav-cta">
          <a href="/#contato" class="btn btn-primary">Agendar consulta</a>
        </div>
        <button class="nav-toggle" id="navToggle" aria-label="Menu" phx-click={toggle_mobile_menu()}>
          <span></span><span></span><span></span>
        </button>
      </div>
      <nav class="mobile-menu" id="mobileMenu" style="display:none;background:var(--navy-800);">
        <div class="wrap" style="display:flex;flex-direction:column;gap:4px;padding:14px 28px 22px;">
          <a href={~p"/"} style="color:var(--n-50);padding:11px 0;">Início</a>
          <a href={~p"/servicos"} style="color:var(--navy-300);padding:11px 0;">Serviços</a>
          <a href="/#abordagem" style="color:var(--navy-300);padding:11px 0;">Abordagem</a>
          <a href={~p"/equipe"} style="color:var(--navy-300);padding:11px 0;">Equipe</a>
          <a href="/#contato" style="color:var(--navy-300);padding:11px 0;">Contato</a>
          <a href="/#contato" class="btn btn-primary btn-sm" style="margin-top:10px;">
            Agendar consulta
          </a>
        </div>
      </nav>
    </header>
    """
  end

  def site_footer(assigns) do
    ~H"""
    <footer class="footer">
      <div class="wrap">
        <div class="footer-grid">
          <div>
            <img
              src={~p"/images/logo-wordmark.png"}
              alt="Espaço Neuro"
              style="height:42px;width:auto;margin-bottom:18px;"
            />
            <p>
              Clínica de neuropsicologia, psicologia e neuropsicopedagogia. Cuidado humano e baseado em evidências para todas as idades.
            </p>
          </div>
          <div>
            <h4>Navegação</h4>
            <ul>
              <li><a href={~p"/"}>Início</a></li>
              <li><a href={~p"/servicos"}>Serviços</a></li>
              <li><a href="/#abordagem">Abordagem</a></li>
              <li><a href={~p"/equipe"}>Equipe</a></li>
            </ul>
          </div>
          <div>
            <h4>Serviços</h4>
            <ul>
              <li><a href={~p"/servicos"}>Avaliação neuropsicológica</a></li>
              <li><a href={~p"/servicos"}>Psicoterapia</a></li>
              <li><a href={~p"/servicos"}>Neuropsicopedagogia</a></li>
            </ul>
          </div>
          <div>
            <h4>Contato</h4>
            <ul>
              <li><a href="mailto:contato@espaconeuro.com.br">profissionalvmb@gmail.com</a></li>
              <li>Londrina · PR</li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <span>© 2026 Espaço Neuro. Todos os direitos reservados.</span>
        </div>
      </div>
    </footer>
    """
  end

  def cta_section(assigns) do
    ~H"""
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
          <a href="mailto:contato@espaconeuro.com.br" class="btn btn-ghost-dark">Enviar e-mail</a>
        </div>
      </div>
    </section>
    """
  end

  defp toggle_mobile_menu do
    Phoenix.LiveView.JS.toggle(to: "#mobileMenu")
  end

  def format_modality(:presencial), do: "Presencial"
  def format_modality(:online), do: "Online"
  def format_modality(:ambos), do: "Presencial e Online"
  def format_modality(_), do: ""

  def format_price(%{price_kind: :on_request}), do: "Sob consulta"
  def format_price(%{price_kind: :fixed, price_cents: nil}), do: ""
  def format_price(%{price_kind: :fixed, price_cents: cents}), do: "R$ #{format_cents(cents)}"
  def format_price(%{price_kind: :from, price_cents: nil}), do: ""

  def format_price(%{price_kind: :from, price_cents: cents}),
    do: "A partir de R$ #{format_cents(cents)}"

  def format_price(_), do: ""

  defp format_cents(cents) when is_integer(cents) do
    whole = div(cents, 100)
    frac = rem(cents, 100)
    "#{whole},#{String.pad_leading(Integer.to_string(frac), 2, "0")}"
  end

  defp format_cents(_), do: "—"
end
