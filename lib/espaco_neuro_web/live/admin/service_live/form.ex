defmodule EspacoNeuroWeb.Admin.ServiceLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Service

  @icons ~w(brain heart book puzzle clipboard stethoscope users chat)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-header">
        <h1>{@page_title}</h1>
      </div>

      <div class="admin-form-card">
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

          <div style="margin-top:16px;">
            <span style="display:block;font-size:13px;font-weight:600;color:var(--navy-700);margin-bottom:10px;">
              Profissionais vinculados
            </span>
            <input
              :if={@selected_professional_ids == []}
              type="hidden"
              name="professional_ids[]"
              value=""
            />
            <div style="display:flex;flex-direction:column;gap:6px;">
              <label
                :for={pro <- @professionals}
                style="display:flex;align-items:center;gap:10px;padding:10px 14px;background:var(--n-50);border:1.5px solid var(--border);border-radius:var(--radius-sm);cursor:pointer;transition:border-color .15s,background .15s;"
                onmouseover="this.style.borderColor='var(--teal-300)'"
                onmouseout="this.style.borderColor=this.querySelector('input').checked?'var(--teal-400)':'var(--border)'"
              >
                <input
                  type="checkbox"
                  name="professional_ids[]"
                  value={pro.id}
                  checked={pro.id in @selected_professional_ids}
                  style="width:18px;height:18px;accent-color:var(--teal-500);cursor:pointer;"
                />
                <div>
                  <span style="font-size:14px;font-weight:500;color:var(--navy-900);">
                    {pro.name}
                  </span>
                  <span style="font-size:12px;color:var(--text-muted);margin-left:8px;">
                    {pro.profession}
                  </span>
                </div>
              </label>
            </div>
          </div>

          <div style="display:flex;gap:12px;margin-top:28px;">
            <button type="submit" class="btn btn-primary" phx-disable-with="Salvando...">
              Salvar
            </button>
            <a href={~p"/admin/servicos"} class="btn btn-ghost-light">Cancelar</a>
          </div>
        </.form>
      </div>
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

    professional_ids =
      (params["professional_ids"] || [])
      |> Enum.reject(&(&1 == ""))

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
