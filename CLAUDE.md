# Guia de Construção — Espaço Neuro (Phoenix + LiveView)

> **Para o Claude Code.** Este documento é a fonte de verdade para construir o
> **backend, o banco e as páginas** do site da clínica Espaço Neuro.
> Siga as fases em ordem. Não invente requisitos: tudo que o site precisa está
> descrito aqui e nos arquivos de design já existentes no repositório
> (`styles.css`, `design-tokens.md`, `index.html`, `equipe.html`,
> `Paleta Espaço Neuro.html`).
>
> Os HTMLs são **mockups estáticos** (a verdade do design). Sua tarefa é
> transformá-los em LiveViews que leem do banco — **sem mudar a aparência**.

---

## 1. Stack e premissas

| Camada | Escolha |
|--------|---------|
| Backend | **Phoenix 1.8.x** (Elixir) |
| Acesso a dados | **Ecto** |
| Banco | **PostgreSQL** |
| Front-end | **Phoenix LiveView 1.1** (sem SPA) |
| E-mail | **Swoosh** (já vem no Phoenix) + adapter **Resend** |
| CSS | **Reaproveitar `styles.css`** (sistema de design já pronto) |
| Fontes | Poppins (display) + Inter (texto), via Google Fonts |

Ambiente de desenvolvimento alvo: Arch Linux + Wayland. Postgres local (ou
container). Editor: Neovim (não gere config de editor).

---

## 2. Decisões já tomadas (não re-discutir)

Estas decisões já foram avaliadas. Implemente exatamente assim; só levante a mão
se encontrar um impedimento técnico real.

1. **Conteúdo é global, não "do usuário".** Serviços e profissionais são
   conteúdo público da clínica, **não** dados que pertencem ao admin logado.
   Portanto os recursos do catálogo são gerados com **`--no-scope`**
   (ver Fase 3). O *scope* do Phoenix 1.8 serve só para **proteger as rotas de
   admin**, não para filtrar conteúdo por `user_id`.

2. **Admin = e-mail + senha.** Um único administrador. **Sem cadastro público.**
   O `phx.gen.auth` do 1.8 usa *magic link* por padrão; nós mantemos o fluxo de
   **senha** e removemos a rota de registro (ver Fase 2).

3. **Relação Serviço ↔ Profissional é muitos-para-muitos.** Um serviço tem
   vários profissionais vinculados; um profissional aparece em vários serviços.
   Tabela de junção `services_professionals`.

4. **Imagens via upload no painel admin** (LiveView `allow_upload`), não URL
   colada à mão. **Armazenamento: AWS S3.** O deploy é no **Fly.io**, que tem
   disco efêmero (arquivos somem a cada deploy), então disco local não serve nem
   em produção. Padrão recomendado: **upload direto do navegador para o S3 via
   URL pré-assinada** (uploads externos do LiveView). Detalhes na Fase 6.

5. **E-mail: Resend.** Justificativa e trade-offs na Fase 7.

6. **Preservar o design existente.** O Phoenix 1.8 vem com Tailwind + daisyUI.
   **Não** reescreva o layout em utilitários Tailwind. Importe `styles.css` e
   construa os templates HEEx com as mesmas classes (`.hero`, `.svc-card`,
   `.pro-card`, etc.). daisyUI pode ficar, mas não deve sobrescrever o design.

7. **Serviços e Equipe são duas páginas públicas independentes, com navegação
   cruzada.** Não basta listar serviços dentro da home ou só "pendurados" no
   profissional. Existem duas listagens distintas:
   - `/servicos` — lista de **cards de serviço**.
   - `/equipe` — lista de **cards de profissional**.

   E a relação m2m liga as duas nos **dois sentidos**: a partir de um serviço a
   pessoa vê os profissionais que o oferecem; a partir de um profissional ela vê
   os serviços que ele atende. Isso exige **páginas de detalhe** para cada lado
   (ver Fase 5). Resumo: a pessoa pode entrar por serviço e cair no profissional,
   ou entrar por profissional e cair no serviço.

---

## 3. Convenções e padrões

- **Idioma:** identificadores de código em inglês (`Professional`, `Service`);
  texto de UI em **português** (é um site brasileiro).
- **Contextos:** toda a regra de negócio mora em contextos
  (`Accounts`, `Catalog`). LiveViews e controllers **nunca** chamam o `Repo`
  diretamente — só funções do contexto.
- **Schemas:** um arquivo por schema dentro do contexto.
- **Migrations:** uma migration por mudança estrutural; nunca editar migration
  já aplicada — criar nova.
- **Formatação:** rodar `mix format` antes de cada commit. Rodar a alias
  `mix precommit` (vem no 1.8: compila com warnings-as-errors, checa formatação
  e roda os testes) e garantir que passa antes de considerar uma fase concluída.
- **Testes:** manter os testes gerados verdes. Ajustá-los quando alterar
  schema/contexto — não apagá-los.
- **Commits:** pequenos e por fase. Mensagens no imperativo
  (`add Catalog.Service schema`).
- **Validações:** toda regra de obrigatoriedade/unicidade vive no changeset do
  schema, não na LiveView.
- Ao usar uma API gerada (ex.: funções de `Accounts`), **leia o código gerado
  antes** — nomes de função variam entre versões. Não chute assinaturas.

---

## 4. Modelo de dados

Os campos abaixo foram extraídos diretamente dos mockups. As anotações entre
parênteses ligam o campo ao elemento visual de origem.

### 4.1 `users` — administrador (gerado pelo `phx.gen.auth`)

Tabela padrão do gerador: `email` (citext, único), `hashed_password`,
`confirmed_at`, `timestamps`, mais a tabela `users_tokens`. **Não** criar campos
extras. Apenas um registro existirá (criado via seeds).

### 4.2 `professionals` — membros da equipe

Origem visual: cards de `equipe.html` (`const TEAM = [...]`).

| Campo | Tipo | Obrig. | Origem / observação |
|-------|------|:------:|---------------------|
| `name` | `string` | ✅ | "Dra. Helena Marques" |
| `slug` | `string` (único) | ✅ | gerado a partir do `name`; usado na URL `/equipe/:slug` |
| `category` | `Ecto.Enum [:psi, :neuro, :pedago]` | ✅ | dirige o **filtro** da página (`data-cat`) |
| `profession` | `string` | ✅ | rótulo do *pill* na foto ("Neuropsicóloga") |
| `crp` | `string` | ✅ | registro profissional (CRP **ou** CRFa) — manter como texto livre |
| `headline` | `string` | ✅ | subtítulo teal ("Avaliação e reabilitação cognitiva") |
| `summary` | `string` |  | resumo curto exibido **no card** (1–2 frases) |
| `description` | `text` | ✅ | bio **completa** — exibida só na **página de detalhe** (`desc`) |
| `approach` | `string` |  | "escola de atendimento" / abordagem teórica (ex.: TCC) |
| `specialties` | `{:array, :string}` |  | "especialidades" — os chips teal (`specs`) |
| `modalities` | `{:array, :string}` |  | "tags" do rodapé do card (`attend`: Presencial/Online/público) |
| `whatsapp` | `string` |  | **só dígitos**, formato `55DDDNÚMERO`; o link `https://wa.me/<whatsapp>` é montado no template |
| `email` | `string` |  | contato (opcional) |
| `photo_path` | `string` |  | caminho da imagem enviada (ver Fase 6) |
| `position` | `integer` |  | ordenação manual na listagem (default 0) |
| `published` | `boolean` |  | esconder rascunho do site público (default `true`) |

**Por que `specialties`/`modalities` como array de string e não tabela?**
O único filtro server-side da página é por `category` (que é coluna própria).
As outras tags são apenas exibidas. Array de Postgres é mais simples para o CRUD
e suficiente. *Trade-off:* não dá para garantir consistência de escrita (ex.:
"TDAH" vs "tdah") nem reaproveitar tags entre profissionais. Se no futuro for
preciso filtrar por especialidade, normalizar em tabela `tags` + junção.

**Card x detalhe (`summary` vs `description`).** O card mostra o `summary`
(curto, controlado pelo admin); a página de detalhe mostra a `description`
completa. *Trade-off:* a alternativa sem o campo extra é mostrar a `description`
truncada no card (via `String.slice/3` ou `line-clamp` no CSS) — zero campos a
mais, mas o corte é arbitrário (pode cortar no meio da frase) e o admin não
controla o texto do card. Recomendo o `summary` dedicado, com **fallback**: se
estiver vazio, o card usa a `description` truncada. Vale o mesmo para `Service`.

### 4.3 `services` — serviços

Origem visual: cards `.svc-card` de `index.html` (seção `#servicos`).

| Campo | Tipo | Obrig. | Origem / observação |
|-------|------|:------:|---------------------|
| `title` | `string` | ✅ | "Avaliação neuropsicológica" |
| `slug` | `string` (único) | ✅ | gerado a partir do `title`; usado em URLs |
| `summary` | `string` |  | resumo curto exibido **no card** (1–2 frases) |
| `description` | `text` | ✅ | texto **completo** — exibido só na **página de detalhe** |
| `icon` | `string` | ✅ | **chave** de um ícone pré-definido (ex.: `"brain"`, `"heart"`, `"book"`), não SVG cru |
| `modality` | `Ecto.Enum [:presencial, :online, :ambos]` | ✅ | "modo de atendimento" |
| `price_cents` | `integer` |  | **preço em centavos** (ex.: R$ 350,00 → `35000`); nulo quando "sob consulta" |
| `price_kind` | `Ecto.Enum [:fixed, :from, :on_request]` | ✅ | como exibir o preço (default `:on_request`) |
| `position` | `integer` |  | ordenação (default 0) |
| `published` | `boolean` |  | default `true` |

**Por que `icon` é uma chave e não SVG?** O admin não deve colar SVG. Mantenha
um mapa fixo `chave → SVG` no front (os SVGs já estão em `index.html`). O form
do admin mostra um `<select>` com as chaves disponíveis.

**Por que dois campos para preço?** Preço de clínica raramente é um número seco:
costuma ser "a partir de R$ X" ou "sob consulta". O par `price_cents` +
`price_kind` cobre os três casos sem perder a capacidade de formatar/ordenar:
- `:fixed` → "R$ 350,00"
- `:from` → "A partir de R$ 350,00"
- `:on_request` → "Sob consulta" (ignora `price_cents`)

⚠️ **Nunca use `float` para dinheiro.** Ponto flutuante não representa centavos
decimais com exatidão (0,1 + 0,2 ≠ 0,3 em binário), o que gera erros de
arredondamento. Guarde **inteiro em centavos** e formate só na exibição (ou use
`:decimal` se preferir; mas centavos inteiros é o mais simples e seguro).
*Trade-off da alternativa:* um único campo `price :string` ("R$ 350" / "Sob
consulta") é mais flexível para texto livre, mas impede ordenar/filtrar por
preço e abre brecha para inconsistência de formatação. Fique com o par numérico.

### 4.4 `services_professionals` — junção (muitos-para-muitos)

| Campo | Tipo |
|-------|------|
| `service_id` | FK → `services` |
| `professional_id` | FK → `professionals` |

Índice único em `[:service_id, :professional_id]`. Sem timestamps.
Associações: `many_to_many` nos dois schemas (`join_through: "services_professionals"`).

---

## 5. Fases de implementação

### Fase 0 — Projeto base

```bash
mix phx.new espaco_neuro --database postgres
cd espaco_neuro
mix ecto.create
```

- LiveView e Tailwind/daisyUI já vêm por padrão no 1.8.
- Copie `styles.css` para `assets/css/` e importe-o no `app.css`. Adicione as
  fontes Poppins/Inter no `root.html.heex` (os `<link>` estão nos mockups).
- Copie os assets de imagem (`assets/logo-espaco-neuro.png`,
  `assets/logo-wordmark.png`) para `priv/static/images/`.
- Rode `mix precommit` para confirmar que o esqueleto está saudável.

### Fase 1 — Autenticação do admin (e-mail + senha)

```bash
mix phx.gen.auth Accounts User users
mix deps.get
mix ecto.migrate
```

Ajustes obrigatórios (porque o padrão do 1.8 é *magic link* e cadastro aberto):

1. **Remover o registro público.** Apague/oculte as rotas e a LiveView de
   `UserRegistrationLive` no `router.ex`. Só existe um admin.
2. **Garantir login por senha.** A `UserLive.Login` gerada já suporta senha;
   mantenha esse caminho funcional. Não dependa de envio de magic link para
   o login do dia a dia.
3. **Criar o admin via seeds** (Fase 4), definindo a senha diretamente pelo
   changeset de senha do schema `User`. **Leia o `lib/espaco_neuro/accounts.ex`
   gerado** para usar as funções/changesets corretos desta versão.
4. O `phx.gen.auth` cria um *scope* default e o plug `require_authenticated_user`
   + o hook `on_mount` em `UserAuth`. Usaremos isso só para proteger `/admin`.

### Fase 2 — Contexto `Catalog` (schemas + migrations)

> **Importante:** como o `phx.gen.auth` já tornou o *scope* default, **todos**
> os geradores abaixo precisam de **`--no-scope`**, senão o Phoenix vai amarrar
> serviços/profissionais a um `user_id` (errado: conteúdo é global).

```bash
# Serviços
mix phx.gen.live Catalog Service services \
  title:string slug:string:unique summary:string description:text \
  icon:string modality:string price_cents:integer price_kind:string \
  position:integer published:boolean \
  --no-scope

# Profissionais (arrays incluídos direto no gerador)
mix phx.gen.live Catalog Professional professionals \
  name:string slug:string:unique category:string profession:string crp:string \
  headline:string summary:string description:text approach:string \
  specialties:array:string modalities:array:string \
  whatsapp:string email:string photo_path:string \
  position:integer published:boolean \
  --no-scope
```

Edições manuais após gerar:

1. **Enums.** Troque `category`, `modality` e `price_kind` para `Ecto.Enum`:
   - `field :category, Ecto.Enum, values: [:psi, :neuro, :pedago]`
   - `field :modality, Ecto.Enum, values: [:presencial, :online, :ambos]`
   - `field :price_kind, Ecto.Enum, values: [:fixed, :from, :on_request], default: :on_request`
2. **Junção many-to-many.** Crie a migration da tabela `services_professionals`
   (com índice único `[:service_id, :professional_id]`) e adicione:
   - em `Service`: `many_to_many :professionals, Professional, join_through: "services_professionals", on_replace: :delete`
   - em `Professional`: `many_to_many :services, Service, join_through: "services_professionals"`
3. **`slug` (em `Service` e `Professional`).** Gere automaticamente no changeset
   a partir do `title`/`name` (normalizar acentos, baixar caixa, trocar espaços
   por `-`). Validar unicidade. Em caso de nomes repetidos, garanta unicidade
   (ex.: sufixo numérico). Dica: a lib `slugify` resolve a normalização.
4. **Vínculo no form de Serviço.** O CRUD gerado não cuida de m2m. No form,
   adicione um multi-select de profissionais; no changeset do `Service`, carregue
   os `Professional` escolhidos por id e use
   `Ecto.Changeset.put_assoc(changeset, :professionals, escolhidos)`.
   (Padrão canônico do Ecto para m2m — `put_assoc`, não `cast_assoc`.)
5. **Inputs de array.** O form gerado não sabe lidar com `{:array, :string}`.
   Em `specialties`/`modalities`, use um input de tags (ou um campo de texto
   separado por vírgula que você divide/junta no changeset).
6. `mix ecto.migrate` e ajuste os testes de contexto/LiveView que o gerador criou.

### Fase 3 — Mover o CRUD para `/admin` e proteger

O gerador colocou o CRUD em rotas de topo. Mova tudo para um escopo protegido:

```elixir
# router.ex (esboço)
scope "/admin", EspacoNeuroWeb.Admin do
  pipe_through [:browser, :require_authenticated_user]

  live_session :admin,
    on_mount: [{EspacoNeuroWeb.UserAuth, :require_authenticated}] do
    live "/servicos", ServiceLive.Index, :index
    live "/servicos/new", ServiceLive.Form, :new
    live "/servicos/:id/edit", ServiceLive.Form, :edit
    live "/profissionais", ProfessionalLive.Index, :index
    # ... (new/edit análogos)
  end
end
```

- Renomeie os módulos gerados para o namespace `Admin` (ou mantenha o namespace
  e só proteja — escolha um e seja consistente).
- A home pública (`/`) e a equipe pública (`/equipe`) **não** ficam aqui;
  são LiveViews separadas e somente-leitura (Fase 5).

### Fase 4 — Seeds

Em `priv/repo/seeds.exs`:

1. **Admin** (e-mail + senha) — usar os changesets de `Accounts`/`User`
   (confira os nomes no código gerado). Idealmente ler senha de uma variável de
   ambiente em produção; em dev pode ser fixa documentada.
2. **Dados de exemplo** dos 9 profissionais e 3 serviços. Use exatamente os
   dados do mockup `equipe.html` (`const TEAM`) e de `index.html` para o site já
   nascer populado. Vincule alguns profissionais a cada serviço para exercitar
   a relação m2m.

### Fase 5 — Páginas públicas (LiveView, seguindo o design)

Reconstrua os mockups como LiveViews lendo do `Catalog`. **Mesmo HTML/CSS**,
só trocando o conteúdo estático por dados do banco.

#### Rotas públicas (somente leitura)

```elixir
# router.ex — escopo público, sem autenticação
scope "/", EspacoNeuroWeb do
  pipe_through :browser

  live "/", HomeLive, :index
  live "/servicos", ServicoLive.Index, :index          # lista de cards de serviço
  live "/servicos/:slug", ServicoLive.Show, :show       # PÁGINA DE DETALHE do serviço
  live "/equipe", EquipeLive.Index, :index              # lista de cards de profissional
  live "/equipe/:slug", EquipeLive.Show, :show          # PÁGINA DE DETALHE do profissional
end
```

> **Não confunda** estas LiveViews públicas com o CRUD de admin da Fase 3. As de
> admin editam dados (protegidas); estas só exibem. São módulos diferentes.

#### Páginas de detalhe ("Saiba mais") — perfil completo

Cada card (de serviço **e** de profissional) tem um botão **"Saiba mais"** que
leva à página de detalhe daquele item. Essa página é o **perfil completo**: é
onde mora a `description` na íntegra (textos longos ficam aqui, não no card) e
todas as informações. Ela **não foi prototipada** — projete seguindo a paleta e
os padrões do site (ver blueprint abaixo).

- **Card de serviço** (`.svc-card`) → já tem o link `.more` "Saiba mais →". Só
  troque o destino de `#contato` para `/servicos/:slug`.
- **Card de profissional** (`.pro-card`) → o mockup **não** tem esse botão.
  **Adicione** um "Saiba mais" (mesma linguagem do `.more`: texto teal + seta)
  apontando para `/equipe/:slug`.

#### Navegação cruzada (via relação m2m)

Além das informações próprias, cada página de detalhe lista o **outro lado** da
relação. Pré-carregue a associação ao buscar (`Repo.preload`) e exponha no
contexto:
- `Catalog.get_service_by_slug!/1` → traz o serviço **com** `:professionals`.
- `Catalog.get_professional_by_slug!/1` → traz o profissional **com** `:services`.

Assim:
- **Detalhe do serviço** (`/servicos/:slug`) = info completa do serviço **+** uma
  **lista de cards de profissional** (os vinculados). Cada card linka para
  `/equipe/:slug`.
- **Detalhe do profissional** (`/equipe/:slug`) = perfil completo **+** uma **lista
  de cards de serviço** (os que ele atende). Cada card linka para `/servicos/:slug`.

Resultado: entra por serviço → cai no profissional; entra por profissional →
cai no serviço. Os mesmos componentes (`service_card`, `professional_card`) são
reusados nas duas listagens e nas duas páginas de detalhe.

#### Blueprint de design das páginas de detalhe (não prototipadas)

Siga `design-tokens.md` e `styles.css`. Estrutura sugerida (vale para os dois):

1. **Cabeçalho escuro** reusando `.page-head` (fundo `--navy-900`, brilho teal),
   como em `equipe.html`. Nele:
   - *Serviço:* ícone + `title` + linha de **modalidade** e **preço**.
   - *Profissional:* foto + `name`, pill `profession`, `crp`, `headline`.
   - Botão de volta para a listagem (`← Serviços` / `← Equipe`).
2. **Corpo claro** (`--bg`) com a `description` completa em prosa legível
   (largura máx. ~`65ch` para conforto de leitura).
3. **Metadados** em chips/listas no padrão já existente:
   - *Serviço:* modalidade, preço formatado.
   - *Profissional:* `approach`, `specialties` (chips `.spec`), `modalities`
     (chips `.attend`), contato (**WhatsApp** `wa.me/<whatsapp>` + `email`).
4. **Seção "relacionados"** com a lista de cards do outro lado (a navegação
   cruzada), com um `.section-head` ("Profissionais deste serviço" /
   "Serviços atendidos").
5. **CTA** reusando a faixa `.cta` (agendar / WhatsApp).

Mantém a mesma navbar e footer das outras páginas (function components
compartilhados).

#### Páginas

**Home (`/`)** — espelhe `index.html`:
- Navbar, Hero (botão de contato → WhatsApp/`#contato`), faixa de áreas,
  **prévia de Serviços** (de `Catalog.list_services/0`, só `published`) com botão
  "Ver todos os serviços" → `/servicos`, seção Abordagem (estática), **prévia da
  equipe** (3 primeiros `published`) com botão → `/equipe`, faixa CTA, Footer.
- Os "Saiba mais" dos cards de serviço agora apontam para `/servicos/:slug`
  (não mais para `#contato`).

**Serviços (`/servicos`)** — **página nova** (o mockup só tinha a seção na home):
- Cabeçalho próprio (reuse o padrão `.page-head` de `equipe.html`).
- Grid de **cards de serviço** reusando `.svc-card`. Cada card exibe: ícone,
  `title`, **`summary`** (resumo curto, não a descrição completa), **modo de
  atendimento** (`modality`), **preço** (formatado de `price_cents`/`price_kind`
  — ver §4.3) e o botão **"Saiba mais"** → `/servicos/:slug`.
- ⚠️ O `.svc-card` do mockup não tem linha de preço nem de modalidade; **adicione**
  esses dois elementos ao card (mesma linguagem visual: use `--text-muted`,
  `.attend` para a modalidade e um destaque teal para o preço).

**Equipe (`/equipe`)** — espelhe `equipe.html`:
- Cabeçalho + **barra de filtro** + grid de cards.
- **O filtro vira server-side.** No mockup ele é JS (`render(cat)`). Em LiveView:
  cada chip é `phx-click="filter"` com `phx-value-cat`; o `handle_event/3`
  reatribui a lista filtrada por `category`. Use `stream/3` para a lista de cards
  (eficiente, sem reenviar tudo). Resultado: zero JavaScript próprio para o filtro.
- Cada card mostra: foto (`photo_path`), pill `profession`, `name`, `crp`,
  `headline`, **`summary`** (resumo curto), chips de `specialties`, chips de
  `modalities`, **botão de WhatsApp** (`https://wa.me/<whatsapp>`) e o botão
  **"Saiba mais"** → `/equipe/:slug` (este botão precisa ser **adicionado** ao
  `.pro-card`, que no mockup não o tem).

Mapeamento de design → componentes (referência rápida):

| Mockup | Vira | Classes a reusar |
|--------|------|------------------|
| `.svc-card` (index) | componente `service_card` | `.svc-card`, `.ic`, `.more` (+ preço/modalidade) |
| card de `TEAM` (equipe) | componente `professional_card` | `.pro-card`, `.pro-photo`, `.spec`, `.attend` (+ botão "Saiba mais") |
| `.tt-card` (index) | prévia da equipe | `.tt-card`, `.tt-photo` |
| navbar/footer | function components compartilhados | `.nav`, `.footer` |

> **Navbar:** atualize os links — "Serviços" aponta para `/servicos` (não mais
> `#servicos`) e "Equipe" para `/equipe`. "Abordagem"/"Contato" seguem como
> âncoras da home.

> Os `<image-slot>` dos mockups são **placeholders de design** (drag-and-drop em
> protótipo). No site real eles viram `<img src={professional.photo_path}>`.

### Fase 6 — Upload de imagens para AWS S3 (deploy no Fly.io)

O Fly.io recria a máquina a cada deploy (disco efêmero) — disco local **não
serve**. As fotos vão para um **bucket S3**. Padrão recomendado: **upload direto
do navegador para o S3 via URL pré-assinada** (uploads externos do LiveView).

**Por que upload direto (presigned) e não passar pelo servidor?** No upload
"normal" o arquivo sobe para a máquina do Fly e só depois vai pro S3 — gasta
banda, disco temporário e memória da máquina (que é pequena). Com URL
pré-assinada, o servidor só **assina** uma autorização temporária; os bytes vão
do navegador **direto** para o S3. A máquina do Fly nunca toca no arquivo.
*Analogia:* em vez de você levar a encomenda até o depósito, o servidor te dá um
crachá temporário que deixa você entregar direto na doca.

Implementação:

1. **Dependências:** `ex_aws`, `ex_aws_s3`, mais um cliente HTTP (`req` ou
   `hackney`) e `sweet_xml` (para parsear respostas do S3). Adicione ao `mix.exs`.
2. **Configuração** em `config/runtime.exs`, lendo de variáveis de ambiente:
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `S3_BUCKET`.
   - Use um usuário IAM **dedicado**, com permissão **apenas** de `PutObject`
     (e `GetObject` se for servir via presigned GET) **só nesse bucket**. Nunca
     use chave root.
3. **Bucket:** crie em uma região (ex.: `sa-east-1`, São Paulo, menor latência no
   Brasil). Para imagens públicas do site, o caminho mais simples é deixar os
   objetos com leitura pública (ou servir via CloudFront). Salve em `photo_path`
   a **URL pública** (ou a *key* do objeto, montando a URL no template).
4. **CORS no bucket:** o upload direto vem do navegador, então o bucket precisa
   permitir `PUT` da origem do site (`https://seudominio`) na configuração de CORS.
   Sem isso o browser bloqueia o upload.
5. **LiveView (upload externo):**
   ```elixir
   allow_upload(socket, :photo,
     accept: ~w(.jpg .jpeg .png .webp),
     max_entries: 1,
     max_file_size: 2_000_000,        # ~2 MB
     external: &presign_upload/2)      # <- torna o upload "externo" (direto p/ S3)
   ```
   Implemente `presign_upload/2` gerando uma URL/post pré-assinado com
   `ExAws.S3.presigned_url/4` (ou `presigned_post`) para a *key* destino
   (ex.: `professionals/<uuid>.<ext>`). Gere a *key* você mesmo — **nunca** confie
   no nome de arquivo do cliente (evita colisão e *path traversal*).
6. Ao salvar o `Professional`, grave em `photo_path` a URL/key final.
7. **Validação:** confira `content-type` e tamanho; aceite só imagens. Considere
   redimensionar/comprimir (opcional) antes — mas isso teria que ser server-side,
   então só faça se realmente precisar.

**Dev x produção:** em desenvolvimento você pode apontar para o mesmo bucket
(prefixo `dev/`) ou usar um bucket separado. Evite disco local mesmo em dev para
o código de upload ser idêntico nos dois ambientes (menos surpresa no deploy).

**Secrets no Fly:** configure as variáveis com
`fly secrets set AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_REGION=sa-east-1 S3_BUCKET=...`
— elas entram no ambiente da máquina sem ir para o código/repо.

### Fase 7 — E-mail (Resend via Swoosh) + formulário de contato

**Provedor: Resend.** Por quê (cenário: clínica pequena, baixo volume — só
reset de senha e, opcionalmente, aviso de contato):

- A **SendGrid encerrou o tier gratuito permanente**: hoje é teste de 60 dias e
  depois ~US$ 19,95/mês. A **Resend mantém 3.000 e-mails/mês grátis para sempre**,
  folga de sobra para a clínica.
- **DX melhor** (API limpa, adapter pronto) e sem surpresa de cobrança por
  excedente. Preço equivalente ao da SendGrid quando/se escalar.
- SendGrid só venceria se você precisasse de **e-mail de marketing + transacional
  no mesmo lugar** ou de **BAA/HIPAA** — não é o caso aqui.

> ⚠️ **Privacidade (LGPD, não HIPAA — clínica no Brasil):** nenhum desses
> provedores torna e-mail um canal seguro para **dados sensíveis de pacientes**.
> Não inclua prontuário/dados de saúde em e-mails transacionais. O formulário de
> contato coleta dados pessoais — trate com cuidado (consentimento, finalidade).

Implementação:

1. Conta na Resend, **verificar o domínio** (SPF/DKIM/DMARC) — sem isso, cai em
   spam. Gerar API key.
2. Configurar o **Swoosh** (já é dependência do Phoenix) com o **adapter da
   Resend**. Confirme no hexdocs do Swoosh o módulo/configuração exatos da versão
   antes de escrever; ponha a API key em variável de ambiente
   (`config/runtime.exs`).
3. **Reset de senha:** a `UserNotifier` gerada já manda e-mail via Swoosh —
   só passa a sair de verdade quando o adapter de produção (Resend) estiver
   configurado. Em dev, use o mailbox local do Phoenix.
4. **Formulário de contato (opcional, mas o design pede "Enviar e-mail"):**
   uma LiveView de contato (`#contato`) com nome/e-mail/mensagem que envia um
   e-mail para a caixa da clínica. Valide os campos e proteja contra spam
   (honeypot ou rate limit simples).

### Fase 8 — Fechamento

- Rodar `mix precommit` (formatação + compilação estrita + testes) limpo.
- Revisar acessibilidade básica: `alt` nas imagens, contraste (o
  `design-tokens.md` já indica os pares AA), navegação por teclado.
- Documentar no `README` como rodar (deps, `ecto.setup`, seeds, variáveis de
  ambiente: `DATABASE_URL`, `SECRET_KEY_BASE`, `RESEND_API_KEY`, senha do admin,
  `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `S3_BUCKET`).
- **Deploy no Fly.io:** `fly launch` gera `fly.toml` + `Dockerfile` (o gerador do
  Phoenix tem suporte). Provisione o Postgres (Fly Postgres ou um gerenciado) e
  rode as migrations no release. Configure todos os secrets com `fly secrets set`
  (ver Fases 6 e 7). Lembre: **disco efêmero** — nada de gravar arquivo local.

---

## 6. Checklist final

- [ ] Login admin por e-mail + senha funciona; **sem** cadastro público.
- [ ] `Service` e `Professional` gerados com `--no-scope` (conteúdo global).
- [ ] Enums (`category`, `modality`, `price_kind`) aplicados.
- [ ] Preço com `price_cents` (inteiro) + `price_kind`; formatação correta dos 3 casos.
- [ ] `summary` no card; `description` completa só na página de detalhe (com fallback truncado).
- [ ] Botão "Saiba mais" nos cards de serviço **e** de profissional → página de detalhe.
- [ ] Páginas de detalhe (`/servicos/:slug`, `/equipe/:slug`) com info na íntegra, seguindo a paleta.
- [ ] `slug` único em `Service` **e** `Professional`, gerado de `title`/`name`.
- [ ] m2m `services_professionals` com `put_assoc` no form de serviço.
- [ ] Arrays `specialties`/`modalities` editáveis no admin e exibidos nos cards.
- [ ] Páginas públicas `/servicos` e `/equipe` existem como listas independentes.
- [ ] Navegação cruzada: serviço → profissionais e profissional → serviços (via preload).
- [ ] Home, Serviços e Equipe seguindo o design, lendo do banco.
- [ ] Filtro da equipe é server-side (LiveView), sem JS próprio.
- [ ] Upload de foto vai **direto para o S3** (presigned); URL salva em `photo_path`.
- [ ] CORS do bucket libera `PUT` da origem do site; IAM com permissão mínima.
- [ ] Botão de WhatsApp monta `wa.me/<whatsapp>` corretamente.
- [ ] Swoosh + Resend configurados; domínio verificado; chave em env var.
- [ ] Secrets do Fly configurados; migrations rodam no release.
- [ ] `mix precommit` verde.

---

## 7. Referências (já no repositório / docs oficiais)

- `design-tokens.md` — paleta, semântica light/dark, diretrizes de uso.
- `styles.css` — sistema de estilos pronto (variáveis CSS, botões, navbar, footer).
- `index.html`, `equipe.html` — verdade do design (home e equipe).
- `Paleta Espaço Neuro.html` — visualização interativa da paleta.
- Phoenix `mix phx.gen.auth`, *Scopes* e LiveView: hexdocs.pm/phoenix.
