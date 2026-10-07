# 13 — Do Express/Node ao Rails

Para quem já criou APIs e sites com **Node.js (Express, Next.js)**, este documento mapeia os conceitos para **Ruby on Rails**.

## Filosofia

| | Express / Node | Rails |
|--|---------------|-------|
| Estilo | Minimalista, monte você mesmo (*unopinionated*) | Completo e opinativo ("baterias incluídas") |
| Estrutura de pastas | Livre | Padronizada |
| Banco de dados | Escolhe-se ORM e driver | ActiveRecord embutido |
| Autenticação, e-mail, jobs | Gems/pacotes variados | Integrados ou recomendados (Active Job, Action Mailer) |
| Configuração | Muita | Convenção sobre configuração |

O equivalente mais próximo do Express em Ruby é o **Sinatra**.

## Hello world: Express vs Sinatra vs Rails

```javascript
// Express
const express = require("express");
const app = express();
app.get("/ola/:nome", (req, res) => res.send(`Olá, ${req.params.nome}!`));
app.listen(3000);
```

```ruby
# Sinatra
require "sinatra"
get "/ola/:nome" do
  "Olá, #{params[:nome]}!"
end
```

```ruby
# Rails
# config/routes.rb:  get "/ola/:nome", to: "saudacoes#ola"
class SaudacoesController < ApplicationController
  def ola
    render plain: "Olá, #{params[:nome]}!"
  end
end
```

## Mapa de conceitos

| Conceito | Express / Node | Rails |
|----------|---------------|-------|
| Criar projeto | `npm init` / `create-next-app` | `rails new app` |
| Rodar em dev | `npm run dev` / `nodemon` | `bin/rails server` (recarrega código sozinho) |
| Rotas | `app.get("/x", handler)` | `config/routes.rb` (`get "/x", to: "c#a"`) |
| Handler | função `(req, res) => {}` | **action** de um controller |
| `req.params` | `req.params`, `req.query`, `req.body` | `params` (unificado) |
| `res.json(x)` | `res.json(x)` | `render json: x` |
| `res.redirect` | `res.redirect("/x")` | `redirect_to x_path` |
| `res.status(404)` | `res.status(404)` | `head :not_found` / `render status: 404` |
| Middleware | `app.use(fn)` | **Rack middleware** / `before_action` / `ApplicationController` |
| Templates | EJS, Pug, Handlebars, JSX | **ERB** (`.html.erb`) |
| Arquivos estáticos | `express.static("public")` | `public/` e assets pipeline |
| Validação de entrada | Joi, Zod | Validations do model + **strong parameters** |
| ORM | Prisma, Sequelize, TypeORM | **ActiveRecord** |
| Migrações | `prisma migrate`, `knex migrate` | `rails db:migrate` |
| Variáveis de ambiente | `process.env`, dotenv | `ENV`, `credentials`, `dotenv-rails` |
| Sessão / cookies | `express-session`, `cookie-parser` | `session`, `cookies` (embutidos) |
| Autenticação | Passport, NextAuth | Devise, `has_secure_password`, authentication generator (Rails 8) |
| CORS | `cors` | `rack-cors` |
| Logs | morgan, pino | `Rails.logger`, `log/development.log` |
| Testes | Jest + supertest | Minitest / RSpec (integrados) |
| E-mail | nodemailer | Action Mailer |
| Jobs | BullMQ | Active Job + Sidekiq / Solid Queue |
| Websockets | socket.io | Action Cable |
| Upload | multer | Active Storage |
| Deploy | PM2, Docker, Vercel | Kamal, Docker, Render, Fly.io, Heroku |

## Rotas e controllers

```javascript
// Express (arquivo de rotas + controller manual)
const router = express.Router();
router.get("/tarefas", listar);
router.post("/tarefas", criar);
router.get("/tarefas/:id", mostrar);
router.put("/tarefas/:id", atualizar);
router.delete("/tarefas/:id", remover);
```

```ruby
# Rails — uma linha gera as 7 rotas RESTful
resources :tarefas
```

Cada rota aponta para uma action de `TarefasController` (`index`, `create`, `show`, `update`, `destroy`, mais `new` e `edit` para formulários).

```javascript
// Express
async function criar(req, res) {
  const { titulo, descricao } = req.body;
  if (!titulo) return res.status(422).json({ erro: "título obrigatório" });
  const tarefa = await Tarefa.create({ titulo, descricao });
  res.status(201).json(tarefa);
}
```

```ruby
# Rails
def create
  @tarefa = Tarefa.new(tarefa_params)
  if @tarefa.save
    render json: @tarefa, status: :created
  else
    render json: @tarefa.errors, status: :unprocessable_entity
  end
end

private

def tarefa_params
  params.require(:tarefa).permit(:titulo, :descricao)
end
```

Pontos-chave:

- A **validação** vive no model (`validates :titulo, presence: true`), não no handler.
- **Strong parameters** substituem a seleção manual de campos do `req.body`.
- Não há `async/await`: o acesso ao banco é síncrono (veja o [doc 12](12-assincronia-e-io.md)).

## Models: Prisma/Sequelize → ActiveRecord

```javascript
// Prisma
const tarefas = await prisma.tarefa.findMany({
  where: { concluida: false },
  orderBy: { criadaEm: "desc" },
  take: 10,
  include: { categoria: true },
});
const t = await prisma.tarefa.findUnique({ where: { id: 5 } });
await prisma.tarefa.update({ where: { id: 5 }, data: { concluida: true } });
await prisma.tarefa.delete({ where: { id: 5 } });
```

```ruby
# ActiveRecord
tarefas = Tarefa.where(concluida: false)
                .order(created_at: :desc)
                .limit(10)
                .includes(:categoria)
t = Tarefa.find(5)
t.update(concluida: true)
t.destroy
```

| Ação | Sequelize/Prisma | ActiveRecord |
|------|-----------------|--------------|
| Todos | `findMany()` | `Tarefa.all` |
| Por id | `findByPk(5)` / `findUnique` | `Tarefa.find(5)` |
| Um por condição | `findOne({ where })` | `Tarefa.find_by(titulo: "x")` |
| Criar | `create({ data })` | `Tarefa.create(attrs)` |
| Atualizar | `update(...)` | `tarefa.update(attrs)` |
| Remover | `delete`/`destroy` | `tarefa.destroy` |
| Contar | `count()` | `Tarefa.count` |
| Incluir relação | `include` | `includes` / `joins` |
| Escopos | métodos estáticos | `scope :pendentes, -> { ... }` |
| Relações | `hasMany`, `belongsTo` | `has_many`, `belongs_to` |

Diferenças de mentalidade:

- ActiveRecord é **Active Record pattern**: o objeto sabe se salvar (`tarefa.save`); em Prisma você chama o cliente (`prisma.tarefa.update`).
- Os atributos vêm **das colunas do banco**: você não declara campos na classe.
- Consultas são *relations* encadeáveis e **preguiçosas** (só executam quando necessário).

## Middleware → filtros e Rack

```javascript
function autenticar(req, res, next) {
  if (!req.session.usuarioId) return res.redirect("/login");
  next();
}
app.use("/admin", autenticar);
```

```ruby
class AdminController < ApplicationController
  before_action :autenticar!

  private

  def autenticar!
    redirect_to login_path unless session[:usuario_id]
  end
end
```

`before_action` (e `after_action`, `around_action`) cobre a maior parte do uso de middleware por controller; middlewares globais ficam em **Rack** (`config/application.rb`).

## Views: JSX/EJS → ERB

```jsx
// React/JSX
{tarefas.map(t => <li key={t.id}>{t.titulo}</li>)}
{ativo ? <b>Ativo</b> : <i>Inativo</i>}
```

```erb
<%# ERB %>
<% @tarefas.each do |t| %>
  <li><%= t.titulo %></li>
<% end %>
<%= ativo ? "<b>Ativo</b>".html_safe : "Inativo" %>
```

- Rails renderiza HTML **no servidor** (como o EJS), com **Turbo/Hotwire** para dar sensação de SPA sem escrever JS.
- Se você quer React/Vue com Rails: use Rails como **API** (`rails new --api`) ou integre com Vite (`vite_rails`).
- Componentes: partials (`render "tarefa"`) ou ViewComponent.

## Front-end moderno com Rails

| Estratégia | Como |
|-----------|------|
| Hotwire (padrão) | Turbo (navegação rápida e atualizações parciais) + Stimulus (JS leve em controllers) |
| Rails API + SPA | `rails new api --api` e um front React/Vue/Next separado |
| Rails + React integrado | `vite_rails`, `jsbundling-rails` com esbuild |

## JSON e APIs

```javascript
app.get("/api/tarefas", async (req, res) => res.json(await Tarefa.findAll()));
```

```ruby
# routes.rb
namespace :api do
  resources :tarefas, only: %i[index show create]
end

# app/controllers/api/tarefas_controller.rb
module Api
  class TarefasController < ApplicationController
    def index
      render json: Tarefa.all
    end
  end
end
```

Para serialização elaborada: Jbuilder, `active_model_serializers`, Blueprinter. `rails new --api` cria um app só de API (sem views/cookies).

## Estrutura de pastas

```
Express (livre)             Rails (convenção)
├── src/                    ├── app/
│   ├── routes/             │   ├── controllers/
│   ├── controllers/        │   ├── models/
│   ├── models/             │   ├── views/
│   └── views/              │   └── jobs/
├── public/                 ├── config/routes.rb
├── package.json            ├── db/migrate/
└── app.js                  ├── public/
                            ├── Gemfile
                            └── ...
```

## Geradores: o que você ganha de graça

```bash
bin/rails generate scaffold Tarefa titulo:string concluida:boolean
```

Gera model, migration, controller completo, views, rotas e testes — um CRUD funcional em um comando. No Node, você escreveria isso à mão ou usaria CLIs de terceiros.

## O que costuma surpreender quem vem do Node

1. **Reinício automático:** em desenvolvimento o Rails recarrega o código sem reiniciar o servidor.
2. **Sem `await`:** o código é síncrono; a concorrência vem de múltiplos processos/threads (Puma).
3. **"Mágica" por convenção:** nomes de arquivos/classes/tabelas conectam as peças; consulte as convenções ([Rails doc 01](../rails/01-o-que-e-rails.md)).
4. **Console:** `rails console` carrega a app inteira e permite testar consultas ao vivo.
5. **Migrations em Ruby**, não SQL cru nem arquivos de schema declarativos.
6. **Segurança embutida:** proteção CSRF, escape de HTML e SQL parametrizado por padrão.

## Resumo

- Express ≈ Sinatra (minimalista); Rails é o "framework completo" com decisões prontas.
- Handler → **action**; middleware → **filtros**; Prisma/Sequelize → **ActiveRecord**; JSX/EJS → **ERB** (+ Hotwire).
- `resources :x` gera as rotas REST; validações vivem no model; parâmetros passam por **strong parameters**.
- Sem `async/await`: o modelo de concorrência é de processos/threads.

## Exercícios

1. Reescreva uma rota Express `GET /produtos/:id` como rota, controller e view/JSON no Rails.
2. Traduza uma consulta Prisma com `where`, `orderBy` e `take` para ActiveRecord.
3. Converta um middleware de autenticação em `before_action`.
4. Gere um CRUD com `scaffold` e compare com o código equivalente que você escreveria no Express.
5. Liste três coisas que o Rails dá embutidas e que você instalaria como pacotes no Express.
6. Crie um endpoint JSON `GET /api/tarefas` em Rails.
