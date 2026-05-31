alias EspacoNeuro.Repo
alias EspacoNeuro.Accounts
alias EspacoNeuro.Catalog

# --- Admin user ---
admin_email = System.get_env("ADMIN_EMAIL") || "admin@espaconeuro.com.br"
admin_password = System.get_env("ADMIN_PASSWORD") || "admin123admin123"

case Accounts.get_user_by_email(admin_email) do
  nil ->
    {:ok, user} = Accounts.register_user(%{email: admin_email})
    {:ok, {user, _}} = Accounts.update_user_password(user, %{password: admin_password})
    # Confirm user
    user
    |> Ecto.Changeset.change(confirmed_at: DateTime.utc_now(:second))
    |> Repo.update!()

    IO.puts("Admin created: #{admin_email}")

  _user ->
    IO.puts("Admin already exists: #{admin_email}")
end

# --- Professionals ---
professionals_data = [
  %{
    name: "Dra. Helena Marques",
    category: :neuro,
    profession: "Neuropsicóloga",
    crp: "CRP 06/123456",
    headline: "Avaliação e reabilitação cognitiva",
    description:
      "Atua com avaliação neuropsicológica e estimulação cognitiva, com foco no desenvolvimento infantil e no diagnóstico do espectro autista.",
    specialties: ["Crianças com TEA", "TDAH", "Dificuldades de aprendizagem"],
    modalities: ["Presencial", "Online", "Crianças"],
    position: 1
  },
  %{
    name: "Dr. Rafael Nunes",
    category: :psi,
    profession: "Psicólogo clínico",
    crp: "CRP 06/234567",
    headline: "Terapia Cognitivo-Comportamental",
    description:
      "Acompanha adultos no manejo de ansiedade, depressão e estresse, com abordagem prática e baseada em evidências.",
    approach: "TCC",
    specialties: ["Ansiedade", "Depressão", "Burnout"],
    modalities: ["Presencial", "Online", "Adultos"],
    position: 2
  },
  %{
    name: "Camila Ferreira",
    category: :pedago,
    profession: "Neuropsicopedagoga",
    crp: "CRFa 2-98765",
    headline: "Aprendizagem e alfabetização",
    description:
      "Intervenção nas dificuldades de leitura, escrita e matemática, integrando família e escola no processo.",
    specialties: ["Dislexia", "Discalculia", "Alfabetização"],
    modalities: ["Presencial", "Crianças", "Adolescentes"],
    position: 3
  },
  %{
    name: "Dra. Beatriz Lopes",
    category: :psi,
    profession: "Psicóloga",
    crp: "CRP 06/345678",
    headline: "Terapia de casal e família",
    description:
      "Apoia casais e famílias na comunicação, resolução de conflitos e reconstrução de vínculos.",
    specialties: ["Casal", "Terapia familiar", "Relacionamentos"],
    modalities: ["Presencial", "Online", "Casal"],
    position: 4
  },
  %{
    name: "Dr. André Tavares",
    category: :neuro,
    profession: "Neuropsicólogo",
    crp: "CRP 06/456789",
    headline: "Neuropsicologia do envelhecimento",
    description:
      "Avaliação e acompanhamento de quadros como demências e declínio cognitivo em idosos.",
    specialties: ["Idosos", "Demências", "Reabilitação cognitiva"],
    modalities: ["Presencial", "Idosos"],
    position: 5
  },
  %{
    name: "Marina Castro",
    category: :psi,
    profession: "Psicóloga infantil",
    crp: "CRP 06/567890",
    headline: "Ludoterapia e desenvolvimento",
    description:
      "Atendimento de crianças por meio do brincar, apoiando emoções, comportamento e autonomia.",
    specialties: ["Crianças", "Ansiedade infantil", "Comportamento"],
    modalities: ["Presencial", "Crianças"],
    position: 6
  },
  %{
    name: "Lucas Almeida",
    category: :pedago,
    profession: "Neuropsicopedagogo",
    crp: "CRFa 2-87654",
    headline: "Mediação escolar e funções executivas",
    description:
      "Desenvolve estratégias de organização, foco e estudo para estudantes com TDAH e dificuldades acadêmicas.",
    specialties: ["TDAH", "Funções executivas", "Adolescentes"],
    modalities: ["Presencial", "Online", "Adolescentes"],
    position: 7
  },
  %{
    name: "Dra. Patrícia Reis",
    category: :neuro,
    profession: "Neuropsicóloga",
    crp: "CRP 06/678901",
    headline: "Avaliação para diagnóstico diferencial",
    description:
      "Especialista em avaliação de adultos com suspeita de TDAH, TEA e transtornos de aprendizagem.",
    specialties: ["TDAH adulto", "TEA adulto", "Avaliação"],
    modalities: ["Presencial", "Online", "Adultos"],
    position: 8
  },
  %{
    name: "Dr. Thiago Moraes",
    category: :psi,
    profession: "Psicólogo",
    crp: "CRP 06/789012",
    headline: "Luto, trauma e regulação emocional",
    description:
      "Acompanha processos de luto, trauma e momentos de transição com escuta acolhedora.",
    specialties: ["Luto", "Trauma", "Depressão"],
    modalities: ["Presencial", "Online", "Adultos"],
    position: 9
  }
]

professionals =
  Enum.map(professionals_data, fn data ->
    {:ok, pro} = Catalog.create_professional(data)
    pro
  end)

IO.puts("Created #{length(professionals)} professionals")

# --- Services ---
# Link professionals to services based on category relevance
neuro_pros = Enum.filter(professionals, &(&1.category == :neuro)) |> Enum.map(& &1.id)
psi_pros = Enum.filter(professionals, &(&1.category == :psi)) |> Enum.map(& &1.id)
pedago_pros = Enum.filter(professionals, &(&1.category == :pedago)) |> Enum.map(& &1.id)

services_data = [
  {%{
     title: "Avaliação neuropsicológica",
     description:
       "Investigação detalhada de atenção, memória, funções executivas e aprendizagem, com laudo completo e devolutiva orientada.",
     icon: "brain",
     modality: :ambos,
     price_kind: :from,
     price_cents: 80_000,
     position: 1
   }, neuro_pros},
  {%{
     title: "Psicoterapia",
     description:
       "Acompanhamento individual, de casal e familiar para ansiedade, depressão, luto, relacionamentos e desenvolvimento pessoal.",
     icon: "heart",
     modality: :ambos,
     price_kind: :on_request,
     position: 2
   }, psi_pros},
  {%{
     title: "Neuropsicopedagogia",
     description:
       "Intervenção nas dificuldades de aprendizagem e na alfabetização, integrando escola, família e estratégias personalizadas.",
     icon: "book",
     modality: :presencial,
     price_kind: :from,
     price_cents: 50_000,
     position: 3
   }, pedago_pros}
]

Enum.each(services_data, fn {attrs, pro_ids} ->
  {:ok, _service} = Catalog.create_service(attrs, pro_ids)
end)

IO.puts("Created #{length(services_data)} services")
