defmodule EspacoNeuroWeb.Admin.ProfessionalLive.FormTest do
  use EspacoNeuroWeb.ConnCase, async: true

  import EspacoNeuro.CatalogFixtures
  import Phoenix.LiveViewTest

  alias EspacoNeuroWeb.SiteComponents

  setup :register_and_log_in_user

  test "shows the scrollable editor beside a live card preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/new")

    assert has_element?(view, "#professional-editor-layout")
    assert has_element?(view, "#professional-form-panel #professional-form")
    assert has_element?(view, "#professional-preview-panel")

    assert has_element?(
             view,
             "#professional-card-preview-stage[phx-hook='ProfessionalCardTextFit']"
           )

    assert has_element?(
             view,
             "#professional-card-preview.pro-card-preview[data-preview='true']"
           )

    refute has_element?(view, "#professional-card-preview .pro-card-link")
  end

  test "updates the card preview from the form fields and tags", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/new")

    view
    |> form("#professional-form",
      professional: %{
        name: "Dra. Helena Marques",
        profession: "Neuropsicóloga",
        headline: "Avaliação neuropsicológica com acolhimento",
        summary: "Uma apresentação curta para o card.",
        specialties_input: "TDAH, Memória",
        modalities_input: "Presencial, Online",
        whatsapp: "5511999990000"
      }
    )
    |> render_change()

    assert has_element?(view, "#professional-card-preview .pro-name", "Dra. Helena Marques")

    assert has_element?(
             view,
             "#professional-card-text-preview",
             "Avaliação neuropsicológica com acolhimento"
           )

    assert has_element?(
             view,
             "#professional-card-summary-preview",
             "Uma apresentação curta para o card."
           )

    assert has_element?(view, "#professional-specialties-preview .spec", "TDAH")
    assert has_element?(view, "#professional-specialties-preview .spec", "Memória")
    assert has_element?(view, "#professional-modalities-preview .attend", "Presencial")
    assert has_element?(view, "#professional-modalities-preview .attend", "Online")
    assert has_element?(view, "#professional-card-preview .pro-actions .btn", "WhatsApp")
  end

  test "uses the saved photo in the card preview while editing", %{conn: conn} do
    professional =
      professional_fixture(%{
        photo_path: "https://example.com/professional-photo.jpg"
      })

    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/#{professional}/edit")

    assert has_element?(
             view,
             "#professional-card-preview img.pro-photo" <>
               "[src='https://example.com/professional-photo.jpg']"
           )
  end

  test "uses a newly selected photo in the card preview before saving" do
    professional = professional_fixture()

    entry = %Phoenix.LiveView.UploadEntry{
      upload_ref: "upload-ref",
      ref: "entry-ref",
      client_name: "preview.png",
      client_size: 8,
      client_type: "image/png",
      valid?: true
    }

    document =
      render_component(&SiteComponents.professional_card/1, %{
        professional: professional,
        preview: true,
        photo_entry: entry
      })
      |> LazyHTML.from_fragment()

    assert [_preview] =
             document
             |> LazyHTML.query(
               "#professional-card-photo-preview-preview" <>
                 "[data-phx-hook='Phoenix.LiveImgPreview']" <>
                 "[data-phx-update='ignore']"
             )
             |> LazyHTML.to_tree()
  end

  test "identifies the required fields when creating a professional", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/new")

    assert has_element?(
             view,
             "#admin-header-logo[src='/images/logo-light.png'][alt='Espaço Neuro']"
           )

    assert has_element?(view, "#professional-required-fields-legend", "Campos obrigatórios")

    for field <- ~w(name category profession headline description) do
      assert has_element?(view, "#professional_#{field}[required]")
      assert has_element?(view, "label[for='professional_#{field}']", "*")
    end
  end

  test "identifies the required fields when editing a professional", %{conn: conn} do
    professional = professional_fixture()
    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/#{professional}/edit")

    assert has_element?(view, "#professional-required-fields-legend", "Campos obrigatórios")

    for field <- ~w(name category profession headline description) do
      assert has_element?(view, "#professional_#{field}[required]")
      assert has_element?(view, "label[for='professional_#{field}']", "*")
    end
  end

  test "shows the card text counter without limiting what can be entered", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/new")

    assert has_element?(
             view,
             "#professional_headline[aria-describedby='professional-card-text-counter']" <>
               "[phx-hook='LiveCharacterCounter']" <>
               "[data-counter-target='professional-card-text-character-count']"
           )

    refute has_element?(view, "#professional_headline[data-character-limit]")
    refute has_element?(view, "#professional_headline[maxlength]")
    refute has_element?(view, "#professional_summary[aria-describedby]")
    assert has_element?(view, "#professional-card-text-counter", "0 caracteres digitados")
    assert has_element?(view, "#professional-card-text-character-count", "0")

    assert has_element?(
             view,
             "#professional-card-text-preview" <>
               "[data-fit-status-target='professional-card-text-fit-status']"
           )

    long_card_text = String.duplicate("á", 180)

    view
    |> form("#professional-form", professional: %{headline: long_card_text})
    |> render_change()

    assert has_element?(view, "#professional-card-text-counter", "180 caracteres digitados")
    assert has_element?(view, "#professional-card-text-preview", long_card_text)
    assert has_element?(view, "#professional_headline[value='#{long_card_text}']")
  end

  test "counts an existing long card text when editing", %{conn: conn} do
    card_text = String.duplicate("Texto longo. ", 30)
    professional = professional_fixture(%{headline: card_text})

    {:ok, view, _html} = live(conn, ~p"/admin/profissionais/#{professional}/edit")

    assert has_element?(
             view,
             "#professional-card-text-counter",
             "#{String.length(card_text)} caracteres digitados"
           )

    refute has_element?(view, "#professional_headline[maxlength]")
  end
end
