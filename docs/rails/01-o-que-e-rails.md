# 01 — O que é Ruby on Rails

## Definição

**Ruby on Rails** (ou só **Rails**) é um **framework web** escrito em Ruby, criado por **David Heinemeier Hansson (DHH)** e lançado em 2004, extraído do sistema Basecamp. Um framework é um conjunto de código e regras que resolve os problemas comuns de uma aplicação, para que você escreva apenas o que é específico do seu negócio.

Com Rails você tem pronto: roteamento, acesso a banco de dados, templates HTML, validações, envio de e-mail, jobs em segundo plano, testes, proteção contra ataques comuns (CSRF, XSS, SQL injection) e muito mais.

Aplicações conhecidas que usam ou usaram Rails: GitHub, Shopify, Basecamp, Airbnb (início), Hotmart, entre outras.

## Duas ideias centrais

### 1. Convenção sobre configuração (*Convention over Configuration*)

Em vez de configurar tudo, o Rails assume **padrões sensatos**. Se você segue o padrão, não escreve configuração.

| Convenção | Efeito |
|-----------|--------|
| Model `Tarefa` (singular, CamelCase) | Usa a tabela `tarefas` (plural, snake_case) |
| Controller `TarefasController` | Procura views em `app/views/tarefas/` |
| Action `show` | Renderiza `show.html.erb` por padrão |
| Coluna `id` | Chave primária automática |
| Colunas `created_at` / `updated_at` | Preenchidas automaticamente |

Você só configura quando **foge** do padrão.

### 2. DRY — *Don't Repeat Yourself*

Cada conhecimento deve ter **uma única representação** no sistema. Exemplos no Rails:

- Os atributos de um model vêm das colunas do banco, não são declarados de novo na classe.
- Partials e layouts evitam repetir HTML.
- Uma regra de validação mora no model e vale para qualquer tela ou API.

## Outras características

- **REST por padrão:** recursos (`/tarefas`) com verbos HTTP (GET, POST, PATCH, DELETE).
- **Banco como cidadão de primeira classe:** migrations versionam o esquema.
- **Ecossistema de gems:** autenticação (`devise`), paginação, testes (`rspec`), etc.
- **Hotwire (Turbo + Stimulus):** páginas dinâmicas com pouco ou nenhum JavaScript escrito por você.
- **Generators:** comandos que criam arquivos prontos (`rails generate`).

## Rails é "opinativo"

O Rails toma decisões por você (estrutura de pastas, nomes, ORM). Isso:

- **acelera** o início e padroniza equipes;
- **reduz** discussões de arquitetura;
- exige **aprender o jeito Rails** — e fugir dele custa mais caro.

## Quando usar Rails

**Bom para:**
- Produtos web com banco de dados (e-commerce, SaaS, painéis administrativos, marketplaces).
- MVPs e startups que precisam validar ideias rápido.
- APIs JSON (modo `--api`).

**Menos indicado para:**
- Sistemas que exigem altíssimo desempenho por requisição com cargas extremas (mas Rails escala bem com a arquitetura certa).
- Aplicações sem servidor/sem banco, puramente estáticas (um gerador de sites estáticos basta).

## Rails x Ruby

| Ruby | Rails |
|------|-------|
| Linguagem de programação | Framework escrito nessa linguagem |
| Serve para scripts, ferramentas, qualquer coisa | Serve para aplicações web |
| Instala-se com o interpretador | Instala-se como uma **gem** (`gem install rails`) |

Muito do que parece "mágica" no Rails é Ruby comum: métodos que recebem blocos, hashes de opções, classes abertas, `method_missing`, módulos incluídos. Quem domina Ruby entende Rails mais depressa.

## Linha do tempo resumida

| Ano | Marco |
|-----|-------|
| 2004 | Primeira versão pública |
| 2007 | Rails 2 — REST como padrão |
| 2010 | Rails 3 — modularização, Bundler |
| 2012–2016 | Rails 4 e 5 — Turbolinks, ActionCable, modo API |
| 2021 | Rails 7 — Hotwire, import maps, sem Node obrigatório |
| 2024–2025 | Rails 8 — Solid Queue/Cache/Cable, autenticação nativa, Kamal |

## Resumo

- Rails é um framework web em Ruby, opinativo e completo ("baterias incluídas").
- **Convenção sobre configuração:** siga os nomes e dispense configuração.
- **DRY:** evite repetição; uma regra, um lugar.
- Aprender Rails é aprender Ruby + as convenções do framework.

## Exercícios

1. Com suas palavras, explique a diferença entre Ruby e Rails.
2. Dada a classe `Produto`, qual seria o nome da tabela e do controller por convenção?
3. Cite dois exemplos de DRY que você já viu em Ruby (ex.: métodos, módulos) e um que o Rails oferece.
4. Pesquise e liste três sistemas conhecidos feitos com Rails.
5. Dê um exemplo de um projeto em que Rails **não** seria a melhor escolha e justifique.
