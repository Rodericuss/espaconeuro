defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Professional

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="professional-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Nome" />
        <.input
          field={@form[:category]}
          type="select"
          label="Categoria"
          options={[{"Psicologia", "psi"}, {"Neuropsicologia", "neuro"}, {"Pedagogia", "pedago"}]}
        />
        <.input field={@form[:profession]} type="text" label="Profissão (pill)" />
        <.input field={@form[:crp]} type="text" label="Registro (CRP/CRFa)" />
        <.input field={@form[:headline]} type="text" label="Headline (subtítulo teal)" />
        <.input field={@form[:summary]} type="text" label="Resumo (card)" />
        <.input field={@form[:description]} type="textarea" label="Bio completa (detalhe)" />
        <.input field={@form[:approach]} type="text" label="Abordagem" />
        <.input
          field={@form[:specialties_input]}
          type="text"
          label="Especialidades (separar por vírgula)"
          value={@specialties_input}
        />
        <.input
          field={@form[:modalities_input]}
          type="text"
          label="Modalidades/tags (separar por vírgula)"
          value={@modalities_input}
        />
        <.input field={@form[:whatsapp]} type="text" label="WhatsApp (só dígitos: 55DDDNÚMERO)" />
        <.input field={@form[:email]} type="email" label="E-mail" />
        <.input field={@form[:position]} type="number" label="Posição" />
        <.input field={@form[:published]} type="checkbox" label="Publicado" />
        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar</.button>
          <.button navigate={~p"/admin/profissionais"}>Cancelar</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    professional = Catalog.get_professional!(id)

    socket
    |> assign(:page_title, "Editar Profissional")
    |> assign(:professional, professional)
    |> assign(:specialties_input, Enum.join(professional.specialties || [], ", "))
    |> assign(:modalities_input, Enum.join(professional.modalities || [], ", "))
    |> assign(:form, to_form(Catalog.change_professional(professional)))
  end

  defp apply_action(socket, :new, _params) do
    professional = %Professional{}

    socket
    |> assign(:page_title, "Novo Profissional")
    |> assign(:professional, professional)
    |> assign(:specialties_input, "")
    |> assign(:modalities_input, "")
    |> assign(:form, to_form(Catalog.change_professional(professional)))
  end

  @impl true
  def handle_event("validate", %{"professional" => params}, socket) do
    params = parse_array_fields(params)
    changeset = Catalog.change_professional(socket.assigns.professional, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"professional" => params}, socket) do
    params = parse_array_fields(params)
    save_professional(socket, socket.assigns.live_action, params)
  end

  defp save_professional(socket, :edit, params) do
    case Catalog.update_professional(socket.assigns.professional, params) do
      {:ok, _professional} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profissional atualizado")
         |> push_navigate(to: ~p"/admin/profissionais")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_professional(socket, :new, params) do
    case Catalog.create_professional(params) do
      {:ok, _professional} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profissional criado")
         |> push_navigate(to: ~p"/admin/profissionais")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp parse_array_fields(params) do
    params
    |> Map.put("specialties", split_comma_field(params["specialties_input"]))
    |> Map.put("modalities", split_comma_field(params["modalities_input"]))
    |> Map.delete("specialties_input")
    |> Map.delete("modalities_input")
  end

  defp split_comma_field(nil), do: []
  defp split_comma_field(""), do: []

  defp split_comma_field(str) do
    str |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end
end
