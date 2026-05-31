defmodule EspacoNeuroWeb.ServiceLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Service

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage service records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="service-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:summary]} type="text" label="Summary" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:icon]} type="text" label="Icon" />
        <.input field={@form[:modality]} type="text" label="Modality" />
        <.input field={@form[:price_cents]} type="number" label="Price cents" />
        <.input field={@form[:price_kind]} type="text" label="Price kind" />
        <.input field={@form[:position]} type="number" label="Position" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Service</.button>
          <.button navigate={return_path(@return_to, @service)}>Cancel</.button>
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
    service = Catalog.get_service!(id)

    socket
    |> assign(:page_title, "Edit Service")
    |> assign(:service, service)
    |> assign(:form, to_form(Catalog.change_service(service)))
  end

  defp apply_action(socket, :new, _params) do
    service = %Service{}

    socket
    |> assign(:page_title, "New Service")
    |> assign(:service, service)
    |> assign(:form, to_form(Catalog.change_service(service)))
  end

  @impl true
  def handle_event("validate", %{"service" => service_params}, socket) do
    changeset = Catalog.change_service(socket.assigns.service, service_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"service" => service_params}, socket) do
    save_service(socket, socket.assigns.live_action, service_params)
  end

  defp save_service(socket, :edit, service_params) do
    case Catalog.update_service(socket.assigns.service, service_params) do
      {:ok, service} ->
        {:noreply,
         socket
         |> put_flash(:info, "Service updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, service))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_service(socket, :new, service_params) do
    case Catalog.create_service(service_params) do
      {:ok, service} ->
        {:noreply,
         socket
         |> put_flash(:info, "Service created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, service))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _service), do: ~p"/services"
  defp return_path("show", service), do: ~p"/services/#{service}"
end
