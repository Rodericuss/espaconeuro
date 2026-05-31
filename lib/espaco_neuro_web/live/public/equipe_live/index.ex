defmodule EspacoNeuroWeb.EquipeLive.Index do
  use EspacoNeuroWeb, :live_view

  import EspacoNeuroWeb.SiteComponents

  alias EspacoNeuro.Catalog

  @impl true
  def mount(_params, _session, socket) do
    professionals = Catalog.list_published_professionals()

    {:ok,
     socket
     |> assign(:page_title, "Equipe")
     |> assign(:current_filter, "all")
     |> assign(:count, length(professionals))
     |> stream(:professionals, professionals)}
  end

  @impl true
  def handle_event("filter", %{"cat" => cat}, socket) do
    professionals =
      if cat == "all" do
        Catalog.list_published_professionals()
      else
        Catalog.list_published_professionals_by_category(String.to_existing_atom(cat))
      end

    {:noreply,
     socket
     |> assign(:current_filter, cat)
     |> assign(:count, length(professionals))
     |> stream(:professionals, professionals, reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.site_navbar current="equipe" />

    <section class="page-head">
      <div class="wrap">
        <span class="eyebrow on-dark">Conheça nosso time</span>
        <h1>Nossa Equipe</h1>
        <p class="page-head-sub">Profissionais especializados e dedicados ao seu cuidado.</p>
      </div>
    </section>

    <section class="section filter-bar">
      <div class="wrap">
        <div class="chip-group">
          <button
            phx-click="filter"
            phx-value-cat="all"
            class={"chip-btn #{if @current_filter == "all", do: "active"}"}
          >
            Todos
          </button>
          <button
            phx-click="filter"
            phx-value-cat="neuro"
            class={"chip-btn #{if @current_filter == "neuro", do: "active"}"}
          >
            Neuropsicologia
          </button>
          <button
            phx-click="filter"
            phx-value-cat="psi"
            class={"chip-btn #{if @current_filter == "psi", do: "active"}"}
          >
            Psicologia
          </button>
          <button
            phx-click="filter"
            phx-value-cat="pedago"
            class={"chip-btn #{if @current_filter == "pedago", do: "active"}"}
          >
            Pedagogia
          </button>
        </div>
        <span class="count" id="count">{@count} profissionais</span>
      </div>
    </section>

    <section class="section">
      <div class="wrap">
        <div class="team-grid" id="team-grid" phx-update="stream">
          <div :for={{dom_id, pro} <- @streams.professionals} id={dom_id}>
            <.professional_card professional={pro} />
          </div>
        </div>
      </div>
    </section>

    <.cta_section />
    <.site_footer />
    """
  end
end
