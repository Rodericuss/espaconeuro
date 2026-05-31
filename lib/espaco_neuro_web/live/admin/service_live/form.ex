defmodule EspacoNeuroWeb.Admin.ServiceLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Service

  @icons ~w(brain heart book puzzle clipboard stethoscope users chat)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="service-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Título" />
        <.input field={@form[:summary]} type="text" label="Resumo (card)" />
        <.input field={@form[:description]} type="textarea" label="Descrição completa" />
        <.input
          field={@form[:icon]}
          type="select"
          label="Ícone"
          options={Enum.map(@icons, &{&1, &1})}
          prompt="Selecione..."
        />
        <.input
          field={@form[:modality]}
          type="select"
          label="Modalidade"
          options={[{"Presencial", "presencial"}, {"Online", "online"}, {"Ambos", "ambos"}]}
        />
        <.input field={@form[:price_cents]} type="number" label="Preço (centavos)" />
        <.input
          field={@form[:price_kind]}
          type="select"
          label="Tipo de preço"
          options={[{"Fixo", "fixed"}, {"A partir de", "from"}, {"Sob consulta", "on_request"}]}
        />
        <.input field={@form[:position]} type="number" label="Posição" />
        <.input field={@form[:published]} type="checkbox" label="Publicado" />

        <div class="mt-4">
          <label class="block text-sm font-semibold mb-2">Profissionais vinculados</label>
          <select name="professional_ids[]" multiple class="select select-bordered w-full h-32">
            <option
              :for={pro <- @professionals}
              value={pro.id}
              selected={pro.id in @selected_professional_ids}
            >
              {pro.name}
            </option>
          </select>
        </div>

        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar</.button>
          <.button navigate={~p"/admin/servicos"}>Cancelar</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    professionals = Catalog.list_professionals()

    {:ok,
     socket
     |> assign(:icons, @icons)
     |> assign(:professionals, professionals)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    service = Catalog.get_service!(id)
    selected_ids = Enum.map(service.professionals, & &1.id)

    socket
    |> assign(:page_title, "Editar Serviço")
    |> assign(:service, service)
    |> assign(:selected_professional_ids, selected_ids)
    |> assign(:form, to_form(Catalog.change_service(service)))
  end

  defp apply_action(socket, :new, _params) do
    service = %Service{professionals: []}

    socket
    |> assign(:page_title, "Novo Serviço")
    |> assign(:service, service)
    |> assign(:selected_professional_ids, [])
    |> assign(:form, to_form(Catalog.change_service(service)))
  end

  @impl true
  def handle_event("validate", %{"service" => service_params}, socket) do
    changeset = Catalog.change_service(socket.assigns.service, service_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", params, socket) do
    service_params = params["service"] || %{}
    professional_ids = params["professional_ids"] || []
    save_service(socket, socket.assigns.live_action, service_params, professional_ids)
  end

  defp save_service(socket, :edit, service_params, professional_ids) do
    case Catalog.update_service(socket.assigns.service, service_params, professional_ids) do
      {:ok, _service} ->
        {:noreply,
         socket
         |> put_flash(:info, "Serviço atualizado")
         |> push_navigate(to: ~p"/admin/servicos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_service(socket, :new, service_params, professional_ids) do
    case Catalog.create_service(service_params, professional_ids) do
      {:ok, _service} ->
        {:noreply,
         socket
         |> put_flash(:info, "Serviço criado")
         |> push_navigate(to: ~p"/admin/servicos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
