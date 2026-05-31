# Espaco Neuro

Site da clinica Espaco Neuro — Phoenix 1.8 + LiveView 1.1.

## Requisitos

- Elixir ~> 1.15
- PostgreSQL
- Node.js (para assets)

## Setup local

```bash
mix setup          # deps.get + ecto.setup + assets
mix phx.server     # http://localhost:4000
```

O seed cria um admin e dados de exemplo:
- Email: `admin@espaconeuro.com.br`
- Senha: `admin123456789!`

## Variaveis de ambiente

| Variavel | Descricao | Obrigatoria |
|----------|-----------|:-----------:|
| `DATABASE_URL` | URL do Postgres | Prod |
| `SECRET_KEY_BASE` | `mix phx.gen.secret` | Prod |
| `PHX_HOST` | Dominio (ex: `espaconeuro.com.br`) | Prod |
| `RESEND_API_KEY` | API key do Resend para email | Prod |
| `CONTACT_EMAIL` | Email que recebe contatos (default: `contato@espaconeuro.com.br`) | Nao |
| `AWS_ACCESS_KEY_ID` | Credencial IAM para S3 upload | Sim |
| `AWS_SECRET_ACCESS_KEY` | Secret IAM | Sim |
| `AWS_REGION` | Regiao AWS (default: `sa-east-1`) | Nao |
| `S3_BUCKET` | Nome do bucket S3 | Sim |

## Deploy (Fly.io)

```bash
fly launch
fly secrets set DATABASE_URL=... SECRET_KEY_BASE=... \
  RESEND_API_KEY=... AWS_ACCESS_KEY_ID=... \
  AWS_SECRET_ACCESS_KEY=... AWS_REGION=sa-east-1 \
  S3_BUCKET=... PHX_HOST=espaconeuro.com.br
fly deploy
```

Migrations rodam automaticamente no release (`rel/overlays/bin/migrate`).

## CORS do S3

O bucket precisa permitir PUT da origem do site:

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["PUT"],
    "AllowedOrigins": ["https://espaconeuro.com.br", "http://localhost:4000"],
    "ExposeHeaders": []
  }
]
```

## Testes

```bash
mix test
mix precommit   # compile --warnings-as-errors + format + test
```
