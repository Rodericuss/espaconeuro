defmodule EspacoNeuroWeb.ProfessionalLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Professional

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage professional records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="professional-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:category]} type="text" label="Category" />
        <.input field={@form[:profession]} type="text" label="Profession" />
        <.input field={@form[:crp]} type="text" label="Crp" />
        <.input field={@form[:headline]} type="text" label="Headline" />
        <.input field={@form[:summary]} type="text" label="Summary" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:approach]} type="text" label="Approach" />
        <.input
          field={@form[:specialties]}
          type="select"
          multiple
          label="Specialties"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input
          field={@form[:modalities]}
          type="select"
          multiple
          label="Modalities"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input field={@form[:whatsapp]} type="text" label="Whatsapp" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:photo_path]} type="text" label="Photo path" />
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Professional</.button>
          <.button navigate={return_path(@return_to, @professional)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    professional = Catalog.get_professional!(id)

    socket
    |> assign(:page_title, "Edit Professional")
    |> assign(:professional, professional)
    |> assign(:form, to_form(Catalog.change_professional(professional)))
  end

  defp apply_action(socket, :new, _params) do
    professional = %Professional{}

    socket
    |> assign(:page_title, "New Professional")
    |> assign(:professional, professional)
    |> assign(:form, to_form(Catalog.change_professional(professional)))
  end

  @impl true
  def handle_event("validate", %{"professional" => professional_params}, socket) do
    changeset = Catalog.change_professional(socket.assigns.professional, professional_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"professional" => professional_params}, socket) do
    save_professional(socket, socket.assigns.live_action, professional_params)
  end

  defp save_professional(socket, :edit, professional_params) do
    case Catalog.update_professional(socket.assigns.professional, professional_params) do
      {:ok, professional} ->
        {:noreply,
         socket
         |> put_flash(:info, "Professional updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, professional))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_professional(socket, :new, professional_params) do
    case Catalog.create_professional(professional_params) do
      {:ok, professional} ->
        {:noreply,
         socket
         |> put_flash(:info, "Professional created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, professional))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _professional), do: ~p"/professionals"
  defp return_path("show", professional), do: ~p"/professionals/#{professional}"
end
