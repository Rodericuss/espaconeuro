defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Professional
  alias EspacoNeuro.Upload

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-header">
        <h1>{@page_title}</h1>
      </div>

      <div class="admin-form-card">
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

          <div style="margin-top:20px;">
            <span style="display:block;font-size:13px;font-weight:600;color:var(--navy-700);margin-bottom:10px;">
              Foto do profissional
            </span>

            <div
              phx-drop-target={@uploads.photo.ref}
              style="position:relative;border:2px dashed var(--border-strong);border-radius:var(--radius-md);padding:32px 24px;text-align:center;transition:border-color .2s,background .2s;cursor:pointer;background:var(--n-50);"
              onmouseover="this.style.borderColor='var(--teal-400)';this.style.background='rgba(116,197,198,0.05)'"
              onmouseout="this.style.borderColor='var(--border-strong)';this.style.background='var(--n-50)'"
            >
              <div
                :if={@uploads.photo.entries == [] && !@professional.photo_path}
                style="display:flex;flex-direction:column;align-items:center;gap:8px;pointer-events:none;"
              >
                <svg
                  width="40"
                  height="40"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="var(--navy-400)"
                  stroke-width="1.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="17 8 12 3 7 8" /><line
                    x1="12"
                    y1="3"
                    x2="12"
                    y2="15"
                  />
                </svg>
                <span style="font-size:14px;color:var(--navy-700);font-weight:500;">
                  Arraste uma imagem ou clique para selecionar
                </span>
                <span style="font-size:12px;color:var(--text-muted);">
                  JPG, PNG ou WebP · Máx 2MB
                </span>
              </div>

              <div
                :if={@professional.photo_path && @uploads.photo.entries == []}
                style="display:flex;align-items:center;gap:16px;justify-content:center;pointer-events:none;"
              >
                <img
                  src={@professional.photo_path}
                  alt={@professional.name}
                  style="width:100px;height:100px;object-fit:cover;border-radius:var(--radius-md);border:2px solid var(--border);"
                />
                <div style="text-align:left;">
                  <span style="font-size:14px;color:var(--navy-700);font-weight:500;display:block;">
                    Foto atual
                  </span>
                  <span style="font-size:12px;color:var(--text-muted);">
                    Arraste ou clique para substituir
                  </span>
                </div>
              </div>

              <div
                :for={entry <- @uploads.photo.entries}
                style="display:flex;align-items:center;gap:16px;justify-content:center;"
              >
                <.live_img_preview
                  entry={entry}
                  style="width:100px;height:100px;object-fit:cover;border-radius:var(--radius-md);border:2px solid var(--teal-300);"
                />
                <div style="text-align:left;">
                  <span style="font-size:14px;color:var(--navy-900);font-weight:500;display:block;">
                    Nova foto selecionada
                  </span>
                  <span style="font-size:12px;color:var(--text-muted);">{entry.client_name}</span>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    style="display:block;margin-top:6px;font-size:12px;color:#dc2626;background:none;border:none;cursor:pointer;padding:0;font-weight:600;position:relative;z-index:2;"
                  >
                    Remover
                  </button>
                </div>
              </div>

              <.live_file_input
                upload={@uploads.photo}
                style="position:absolute;inset:0;width:100%;height:100%;opacity:0;cursor:pointer;z-index:1;"
              />
            </div>

            <%= for entry <- @uploads.photo.entries, err <- upload_errors(@uploads.photo, entry) do %>
              <p style="color:#dc2626;font-size:13px;margin-top:6px;">{error_to_string(err)}</p>
            <% end %>
          </div>

          <div style="display:flex;gap:12px;margin-top:28px;">
            <button type="submit" class="btn btn-primary" phx-disable-with="Salvando...">
              Salvar
            </button>
            <a href={~p"/admin/profissionais"} class="btn btn-ghost-light">Cancelar</a>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> allow_upload(:photo,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: 2_000_000,
        external: &Upload.presign_upload/2
      )

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

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def handle_event("save", %{"professional" => params}, socket) do
    params = parse_array_fields(params)
    photo_path = consume_photo(socket)
    old_photo = socket.assigns.professional.photo_path

    if photo_path && old_photo do
      Upload.delete_object(old_photo)
    end

    params = if photo_path, do: Map.put(params, "photo_path", photo_path), else: params
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

  defp consume_photo(socket) do
    uploaded_entries =
      consume_uploaded_entries(socket, :photo, fn meta, _entry ->
        {:ok, meta.public_url}
      end)

    List.first(uploaded_entries)
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

  defp error_to_string(:too_large), do: "Arquivo muito grande (máx 2MB)"
  defp error_to_string(:not_accepted), do: "Formato não aceito (use JPG, PNG ou WebP)"
  defp error_to_string(:too_many_files), do: "Apenas uma foto"
  defp error_to_string(err), do: inspect(err)
end
