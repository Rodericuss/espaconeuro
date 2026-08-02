defmodule EspacoNeuroWeb.Admin.ProfessionalLive.Form do
  use EspacoNeuroWeb, :live_view

  alias EspacoNeuro.Catalog
  alias EspacoNeuro.Catalog.Professional
  alias EspacoNeuro.Upload
  alias EspacoNeuroWeb.SiteComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} wide>
      <div class="admin-header">
        <h1>{@page_title}</h1>
      </div>

      <div id="professional-editor-layout" class="professional-editor-layout">
        <section id="professional-form-panel" class="admin-form-card professional-form-panel">
          <.form for={@form} id="professional-form" phx-change="validate" phx-submit="save">
            <p
              id="professional-required-fields-legend"
              class="mb-5 text-sm text-slate-600"
            >
              <span class="font-semibold text-red-600" aria-hidden="true">*</span> Campos obrigatórios
            </p>

            <.input field={@form[:name]} type="text" label="Nome *" required />
            <.input
              field={@form[:category]}
              type="select"
              label="Categoria *"
              options={[{"Psicologia", "psi"}, {"Neuropsicologia", "neuro"}, {"Pedagogia", "pedago"}]}
              required
            />
            <.input field={@form[:profession]} type="text" label="Profissão (pill) *" required />
            <.input field={@form[:crp]} type="text" label="Registro (CRP/CRFa)" />
            <div id="professional-card-text-field">
              <.input
                field={@form[:headline]}
                type="text"
                label="Texto do card (subtítulo teal) *"
                aria-describedby="professional-card-text-counter"
                data-counter-target="professional-card-text-character-count"
                phx-hook="LiveCharacterCounter"
                phx-debounce="150"
                required
              />
              <p
                id="professional-card-text-counter"
                class="mb-3 mt-1 text-sm text-slate-600"
                role="status"
                aria-live="polite"
              >
                <strong id="professional-card-text-character-count">
                  {@card_text_character_count}
                </strong>
                caracteres digitados.
                <span id="professional-card-text-fit-status">
                  A prévia ao lado calcula quanto do texto cabe no card.
                </span>
              </p>
            </div>
            <.input field={@form[:summary]} type="text" label="Descrição curta do card" />
            <.input
              field={@form[:description]}
              type="textarea"
              label="Bio completa (página de detalhe) *"
              required
            />
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
            <.input
              field={@form[:whatsapp]}
              type="text"
              label="WhatsApp (só dígitos: 55DDDNÚMERO)"
            />
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
        </section>

        <aside id="professional-preview-panel" class="professional-preview-panel">
          <div class="professional-preview-heading">
            <div>
              <span class="professional-preview-eyebrow">Visualização em tempo real</span>
              <h2>Prévia do card</h2>
            </div>
            <span class="professional-preview-badge">
              <.icon name="hero-eye" class="size-4" /> Prévia
            </span>
          </div>

          <p class="professional-preview-help">
            O card acompanha os dados, as tags e a imagem selecionada. Nenhuma alteração será
            publicada antes de salvar.
          </p>

          <div
            id="professional-card-preview-stage"
            class="professional-card-preview-stage"
            phx-hook="ProfessionalCardTextFit"
          >
            <SiteComponents.professional_card
              professional={@preview_professional}
              photo_entry={List.first(@uploads.photo.entries)}
              preview
            />
          </div>
        </aside>
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
    changeset = Catalog.change_professional(professional)

    socket
    |> assign(:page_title, "Editar Profissional")
    |> assign(:professional, professional)
    |> assign(:specialties_input, Enum.join(professional.specialties || [], ", "))
    |> assign(:modalities_input, Enum.join(professional.modalities || [], ", "))
    |> assign_card_text_counter(professional.headline)
    |> assign_preview(changeset)
    |> assign(:form, to_form(changeset))
  end

  defp apply_action(socket, :new, _params) do
    professional = %Professional{}
    changeset = Catalog.change_professional(professional)

    socket
    |> assign(:page_title, "Novo Profissional")
    |> assign(:professional, professional)
    |> assign(:specialties_input, "")
    |> assign(:modalities_input, "")
    |> assign_card_text_counter(nil)
    |> assign_preview(changeset)
    |> assign(:form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"professional" => params}, socket) do
    params = parse_array_fields(params)
    changeset = Catalog.change_professional(socket.assigns.professional, params)

    {:noreply,
     socket
     |> assign_card_text_counter(params["headline"])
     |> assign_preview(changeset)
     |> assign(:form, to_form(changeset, action: :validate))}
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
        {:noreply,
         socket
         |> assign_card_text_counter(params["headline"])
         |> assign_preview(changeset)
         |> assign(:form, to_form(changeset))}
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
        {:noreply,
         socket
         |> assign_card_text_counter(params["headline"])
         |> assign_preview(changeset)
         |> assign(:form, to_form(changeset))}
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

  defp assign_card_text_counter(socket, card_text) do
    assign(socket, :card_text_character_count, character_count(card_text))
  end

  defp character_count(text) when is_binary(text), do: String.length(text)
  defp character_count(_text), do: 0

  defp assign_preview(socket, changeset) do
    professional =
      changeset
      |> Ecto.Changeset.apply_changes()
      |> with_preview_placeholders()

    assign(socket, :preview_professional, professional)
  end

  defp with_preview_placeholders(%Professional{} = professional) do
    %Professional{
      professional
      | name: preview_value(professional.name, "Nome do profissional"),
        profession: preview_value(professional.profession, "Profissão"),
        headline:
          preview_value(
            professional.headline,
            "O texto principal do card aparecerá aqui conforme você digitar."
          ),
        summary: preview_summary(professional)
    }
  end

  defp preview_summary(professional) do
    cond do
      present?(professional.summary) -> professional.summary
      present?(professional.description) -> professional.description
      true -> "Adicione uma descrição curta para apresentar o atendimento desta profissional."
    end
  end

  defp preview_value(value, fallback) do
    if present?(value), do: value, else: fallback
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(_value), do: false

  defp error_to_string(:too_large), do: "Arquivo muito grande (máx 2MB)"
  defp error_to_string(:not_accepted), do: "Formato não aceito (use JPG, PNG ou WebP)"
  defp error_to_string(:too_many_files), do: "Apenas uma foto"
  defp error_to_string(err), do: inspect(err)
end
