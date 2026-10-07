# 04 — Estrutura de pastas

Um projeto Rails novo tem muitas pastas. Você só precisa conhecer algumas para ser produtivo.

```
biblioteca/
├── app/
│   ├── assets/          # CSS, imagens
│   ├── controllers/     # Controllers
│   ├── helpers/         # Helpers das views
│   ├── javascript/      # JavaScript (Stimulus/Turbo)
│   ├── jobs/            # Tarefas em segundo plano
│   ├── mailers/         # E-mails
│   ├── models/          # Models
│   └── views/           # Templates (ERB)
│       └── layouts/     # application.html.erb
├── bin/                 # Executáveis (rails, setup...)
├── config/
│   ├── routes.rb        # Rotas
│   ├── database.yml     # Configuração do banco
│   ├── application.rb   # Configuração geral
│   ├── environments/    # development.rb, test.rb, production.rb
│   └── initializers/    # Código executado na inicialização
├── db/
│   ├── migrate/         # Migrations
│   ├── schema.rb        # Retrato atual do banco
│   └── seeds.rb         # Dados iniciais
├── lib/                 # Código próprio fora do app, tasks
├── log/                 # Logs (development.log)
├── public/              # Arquivos estáticos (404.html, favicon)
├── storage/             # Arquivos do Active Storage
├── test/                # Testes
├── tmp/                 # Arquivos temporários e cache
├── vendor/              # Código de terceiros
├── Gemfile              # Dependências
├── Gemfile.lock         # Versões exatas
└── README.md
```

## `app/` — o coração da aplicação

É onde você passa 90% do tempo.

| Pasta | O que guarda | Exemplo |
|-------|--------------|---------|
| `models/` | Classes de dados e regras | `tarefa.rb` |
| `controllers/` | Classes que tratam requisições | `tarefas_controller.rb` |
| `views/` | Templates por controller | `tarefas/index.html.erb` |
| `helpers/` | Métodos para views | `tarefas_helper.rb` |
| `jobs/` | Processamento assíncrono | `enviar_email_job.rb` |
| `mailers/` | Envio de e-mails | `usuario_mailer.rb` |

Tudo em `app/*` é **carregado automaticamente** (autoload): você não precisa de `require` para suas classes.

## `config/`

| Arquivo | Para quê |
|---------|----------|
| `routes.rb` | Define as URLs da aplicação |
| `database.yml` | Banco por ambiente |
| `application.rb` | Configurações gerais (fuso horário, idioma) |
| `environments/*.rb` | Ajustes por ambiente |
| `initializers/` | Configuração de gems e extensões |
| `credentials.yml.enc` | Segredos criptografados |

Exemplo — fuso e idioma em `config/application.rb`:

```ruby
config.time_zone = "Brasilia"
config.i18n.default_locale = :"pt-BR"
```

## `db/`

- `migrate/` — um arquivo por mudança no banco, com carimbo de data (`20250115120000_create_tarefas.rb`).
- `schema.rb` — gerado automaticamente; representa o estado atual do banco. **Não edite.**
- `seeds.rb` — dados iniciais (`rails db:seed`).
- `development.sqlite3` — o banco SQLite (não deve ir para o Git).

## Ambientes

O Rails tem três ambientes padrão, escolhidos pela variável `RAILS_ENV`:

| Ambiente | Uso | Característica |
|----------|-----|----------------|
| `development` | Desenvolvimento local | Recarrega código, erros detalhados |
| `test` | Testes automatizados | Banco isolado |
| `production` | Servidor real | Cache, erros genéricos, desempenho |

```bash
RAILS_ENV=production bin/rails server
```

## `Gemfile` e `Gemfile.lock`

O `Gemfile` lista as gems (detalhes no [doc 16 de Ruby](../ruby/16-gems-e-bundler.md)); o `Gemfile.lock` fixa as versões e **deve ser versionado** no Git.

## Relação entre nomes e arquivos

O Rails encontra as coisas pelo nome:

| Você escreve | O Rails procura |
|--------------|-----------------|
| `class Tarefa` | `app/models/tarefa.rb` |
| `class TarefasController` | `app/controllers/tarefas_controller.rb` |
| `class Admin::UsuariosController` | `app/controllers/admin/usuarios_controller.rb` |
| action `index` em `TarefasController` | `app/views/tarefas/index.html.erb` |
| tabela | `tarefas` (plural do model) |

Regra: **CamelCase na classe, snake_case no arquivo.** Se o nome do arquivo não bate com o da classe, o autoload falha (`NameError: uninitialized constant`).

## O que ignorar no Git

O `.gitignore` gerado já cobre: `log/`, `tmp/`, `*.sqlite3`, `storage/`, `config/master.key` (chave das credentials). **Nunca** versione `master.key`.

## Resumo

- `app/` guarda models, views e controllers (autoload automático).
- `config/routes.rb` define URLs; `config/database.yml` configura o banco.
- `db/migrate` versiona o banco; `schema.rb` é só um retrato.
- Nomes seguem convenção: classe CamelCase ↔ arquivo snake_case.
- Três ambientes: development, test, production.

## Exercícios

1. Em qual arquivo ficaria a classe `ProdutoCategoria`? E o controller `Admin::PedidosController`?
2. Altere o fuso horário e o idioma padrão da aplicação.
3. Abra `log/development.log`, acesse a página inicial e identifique a linha da requisição.
4. Explique por que `db/schema.rb` não deve ser editado à mão.
5. Liste três itens que não devem ser versionados e diga por quê.
