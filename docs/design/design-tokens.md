# Espaço Neuro — Design Tokens

Paleta de cores e tokens de design derivados da logo da **Espaço Neuro**.
Use este arquivo como fonte de verdade ao construir o webapp (navbar, hero, footer e demais seções).

## Cores da marca (extraídas da logo)

| Token | HEX | Uso |
|-------|-----|-----|
| `brand.navy` | `#212951` | Cor principal da marca. Fundos escuros, navbar, hero, footer, texto sobre claro. |
| `brand.teal` | `#74C5C6` | Acento da marca. CTAs, destaques, links, ícones, detalhes. |
| `brand.offwhite` | `#F3F0F6` | "Papel" da marca. Texto sobre fundo escuro, superfícies claras. |

---

## Escalas

### Primary — Navy (`--navy-*`)
H 230 · azul-marinho profundo. **900 = cor exata da marca.**

| Step | HEX |
|------|-----|
| 50  | `#F5F6FA` |
| 100 | `#E8E9F3` |
| 200 | `#C9CEE9` |
| 300 | `#A1AAD9` |
| 400 | `#7583C7` |
| 500 | `#4A5CB5` |
| 600 | `#3E4D98` |
| 700 | `#323E7B` |
| 800 | `#26305E` |
| **900** | **`#212951`** ← marca |
| 950 | `#161B38` |

### Secondary — Teal (`--teal-*`)
H 181 · verde-azulado. **400 = cor exata da marca.**

| Step | HEX |
|------|-----|
| 50  | `#F2FAFA` |
| 100 | `#E1F3F3` |
| 200 | `#C2E8E8` |
| 300 | `#9DDADB` |
| **400** | **`#74C5C6`** ← marca |
| 500 | `#4FB3B4` |
| 600 | `#3B9596` |
| 700 | `#327A7B` |
| 800 | `#285E5E` |
| 900 | `#1E4747` |
| 950 | `#122B2B` |

### Neutral — Cool gray (`--neutral-*`)
Cinzas levemente frios, alinhados ao off-white da marca. **50 = off-white da marca.**

| Step | HEX |
|------|-----|
| 0   | `#FFFFFF` |
| 50  | `#F3F0F6` ← off-white da marca |
| 100 | `#E9E7EF` |
| 200 | `#D6D4DF` |
| 300 | `#B6B4C3` |
| 400 | `#8F8DA0` |
| 500 | `#6B6A7C` |
| 600 | `#514F60` |
| 700 | `#3D3C4A` |
| 800 | `#2A2935` |
| 900 | `#1A1922` |

---

## Cores semânticas
Saturação moderada para conviver com a paleta da marca.

| Token | HEX | Sobre claro (texto) |
|-------|-----|--------------------|
| `success` | `#2E9E6B` | `#1E6B47` |
| `warning` | `#E0A33B` | `#9A6B16` |
| `error`   | `#D7564E` | `#A8362F` |
| `info`    | `#74C5C6` (teal) | `#327A7B` |

---

## Mapeamento semântico — Light mode (padrão do app)

```css
:root {
  /* Brand */
  --color-brand:            #212951; /* navy */
  --color-accent:           #74C5C6; /* teal */

  /* Surfaces */
  --color-bg:               #F3F0F6; /* fundo da página (off-white) */
  --color-surface:          #FFFFFF; /* cards, navbar */
  --color-surface-sunken:   #E9E7EF; /* áreas rebaixadas */

  /* Texto */
  --color-text:             #212951; /* navy-900 */
  --color-text-muted:       #514F60; /* neutral-600 */
  --color-text-subtle:      #8F8DA0; /* neutral-400 */
  --color-text-on-brand:    #F3F0F6; /* texto sobre navy/teal escuro */

  /* Bordas / linhas */
  --color-border:           #D6D4DF; /* neutral-200 */
  --color-border-strong:    #B6B4C3; /* neutral-300 */

  /* Ações */
  --color-primary:          #212951; /* botão primário (navy) */
  --color-primary-hover:    #161B38; /* navy-950 */
  --color-accent-action:    #327A7B; /* teal-700 — texto/links com contraste AA sobre branco */
  --color-accent-action-bg: #3B9596; /* teal-600 — fundo de botão de acento (use texto branco) */
  --color-accent-hover:     #285E5E; /* teal-800 */

  /* Foco */
  --color-focus-ring:       #74C5C6;
}
```

## Mapeamento semântico — Dark mode (ex.: hero/footer sobre navy)

```css
[data-theme="dark"] {
  --color-bg:               #212951; /* navy-900 */
  --color-surface:          #26305E; /* navy-800 */
  --color-surface-sunken:   #161B38; /* navy-950 */

  --color-text:             #F3F0F6; /* off-white */
  --color-text-muted:       #A1AAD9; /* navy-300 */
  --color-text-subtle:      #7583C7; /* navy-400 */

  --color-border:           #323E7B; /* navy-700 */

  --color-primary:          #74C5C6; /* teal — botão primário sobre escuro */
  --color-primary-hover:    #9DDADB; /* teal-300 */
  --color-accent-action:    #74C5C6; /* links em teal claro */
}
```

---

## Diretrizes de uso

- **Navbar:** sobre `#212951` (navy) com logo/texto em off-white e item ativo / CTA em teal `#74C5C6`. Alternativa light: superfície branca, texto navy, CTA teal.
- **Hero:** fundo navy `#212951` é o assinatura da marca (igual à logo). Título em off-white, palavra de destaque em teal, botão primário em teal com texto navy escuro.
- **Footer:** navy `#212951` ou navy-950 `#161B38`, texto off-white/navy-300, links em teal.
- **Acentos:** teal é o acento — use com parcimônia (CTAs, ícones, sublinhados, estados ativos). Não use como grande área de fundo claro com texto pequeno (baixo contraste).
- **Contraste:** para texto/links teal sobre branco, use `teal-700 #327A7B` (AA). O teal da marca `#74C5C6` brilha melhor sobre o navy escuro.
- **Botões:** primário = navy (texto off-white) no light mode; teal (texto navy) no dark mode. Secundário = contorno em `--color-border` com texto navy.

## Tipografia (sugestão)
A logo usa uma sans geométrica de cantos arredondados. Recomendação para o webapp:
- **Display/Headings:** `Poppins` ou `Quicksand` (geométrica, amigável — combina com a logo).
- **Texto/UI:** `Inter` ou `Mulish` para legibilidade em corpo de texto.

## Raio & elevação (sugestão)
- Raio: `--radius-sm: 8px`, `--radius-md: 14px`, `--radius-lg: 22px` (cantos generosos, ecoando a logo).
- Sombra: suave e fria — `0 8px 24px -8px rgba(33,41,81,0.18)`.
