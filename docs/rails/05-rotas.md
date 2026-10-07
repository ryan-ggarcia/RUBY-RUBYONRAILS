# 05 — Rotas

As rotas ligam uma **URL + verbo HTTP** a uma **action de um controller**. Ficam em `config/routes.rb`.

## Rota simples

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get "/sobre", to: "paginas#sobre"     # GET /sobre → PaginasController#sobre
  post "/contato", to: "contatos#create"
  root "home#index"                      # página inicial (/)
end
```

Verbos disponíveis: `get`, `post`, `patch`, `put`, `delete`.

## Parâmetros na URL

```ruby
get "/produtos/:id", to: "produtos#show"
# GET /produtos/42  → params[:id] == "42"

get "/blog/:ano/:mes", to: "posts#arquivo"
# GET /blog/2025/03 → params[:ano] == "2025", params[:mes] == "03"
```

Parâmetros chegam **sempre como String**.

## `resources`: as 7 rotas REST

A linha abaixo gera todas as rotas de um CRUD:

```ruby
resources :tarefas
```

| Verbo | Caminho | Controller#Action | Helper | Finalidade |
|-------|---------|-------------------|--------|-----------|
| GET | `/tarefas` | `tarefas#index` | `tarefas_path` | Listar |
| GET | `/tarefas/new` | `tarefas#new` | `new_tarefa_path` | Formulário de criação |
| POST | `/tarefas` | `tarefas#create` | `tarefas_path` | Criar |
| GET | `/tarefas/:id` | `tarefas#show` | `tarefa_path(id)` | Exibir um |
| GET | `/tarefas/:id/edit` | `tarefas#edit` | `edit_tarefa_path(id)` | Formulário de edição |
| PATCH/PUT | `/tarefas/:id` | `tarefas#update` | `tarefa_path(id)` | Atualizar |
| DELETE | `/tarefas/:id` | `tarefas#destroy` | `tarefa_path(id)` | Remover |

Apenas algumas:

```ruby
resources :tarefas, only: %i[index show]
resources :tarefas, except: %i[destroy]
```

### Recurso singular

Quando só existe um (perfil do usuário logado):

```ruby
resource :perfil          # sem :id; o controller continua no plural (PerfisController)
```

(Cuidado com a pluralização em português; veja *inflections* abaixo.)

## Ver as rotas

```bash
bin/rails routes
bin/rails routes -g tarefas      # filtrar
bin/rails routes -c tarefas      # por controller
```

No navegador (development): `http://localhost:3000/rails/info/routes`.

## Helpers de rota

Cada rota nomeada gera dois helpers: `*_path` (caminho relativo) e `*_url` (URL completa).

```ruby
tarefas_path                 # => "/tarefas"
tarefa_path(5)               # => "/tarefas/5"
tarefa_path(@tarefa)         # => "/tarefas/5" (usa o id do objeto)
new_tarefa_path              # => "/tarefas/new"
edit_tarefa_path(@tarefa)    # => "/tarefas/5/edit"
tarefas_url                  # => "http://localhost:3000/tarefas"
```

Nas views:

```erb
<%= link_to "Ver todas", tarefas_path %>
<%= link_to "Detalhes", @tarefa %>              <%# atalho para tarefa_path(@tarefa) %>
<%= link_to "Editar", edit_tarefa_path(@tarefa) %>
<%= button_to "Excluir", @tarefa, method: :delete %>
```

Use **sempre helpers** em vez de escrever URLs à mão: se a rota mudar, o código continua certo. `_path` é o padrão nas views; `_url` é usado em e-mails e redirecionamentos externos.

## Rotas aninhadas

Quando um recurso pertence a outro:

```ruby
resources :autores do
  resources :livros
end
```

Gera, entre outras: `GET /autores/:autor_id/livros`, `POST /autores/:autor_id/livros`. Helper: `autor_livros_path(@autor)`.

Recomendação: **no máximo um nível** de aninhamento. Use `shallow: true` para evitar URLs enormes:

```ruby
resources :autores, shallow: true do
  resources :livros      # index/new/create aninhados; show/edit/update/destroy não
end
```

## Rotas extras: `member` e `collection`

```ruby
resources :tarefas do
  member do
    patch :concluir            # PATCH /tarefas/:id/concluir → concluir_tarefa_path(id)
  end
  collection do
    get :pendentes             # GET /tarefas/pendentes → pendentes_tarefas_path
  end
end
```

Se você precisa de muitas rotas extras, talvez deva criar **outro recurso/controller**.

## `namespace` e `scope`

```ruby
namespace :admin do
  resources :usuarios        # /admin/usuarios → Admin::UsuariosController
end

scope "/v1" do               # só altera a URL, não o módulo do controller
  resources :produtos
end
```

## Rota raiz e redirecionamentos

```ruby
root "tarefas#index"
get "/antiga", to: redirect("/nova")
```

## Restrições e constraints

```ruby
get "/produtos/:id", to: "produtos#show", constraints: { id: /\d+/ }
```

## Pluralização em português (*inflections*)

O Rails pluraliza em inglês. Para português, configure:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "tarefa", "tarefas"
  inflect.irregular "perfil", "perfis"
  inflect.irregular "animal", "animais"
end
```

Teste no console: `"perfil".pluralize # => "perfis"`.

## Boas práticas

1. Prefira `resources` às rotas manuais.
2. Mantenha os controllers com apenas as 7 ações padrão; crie novos controllers em vez de dezenas de ações extras.
3. Evite aninhar mais de um nível.
4. Use os helpers `_path`.
5. Consulte `rails routes` quando em dúvida.

## Resumo

- Rota = verbo + URL → `controller#action`.
- `resources :x` gera as 7 rotas RESTful e os helpers.
- `rails routes` lista tudo; helpers `_path`/`_url` evitam URLs escritas à mão.
- Use `member`/`collection` para ações extras e `namespace` para agrupar (ex.: `admin`).

## Exercícios

1. Declare `resources :produtos` e liste as rotas com `rails routes`.
2. Restrinja a `index` e `show` e confira a diferença.
3. Crie `get "/sobre"` apontando para `paginas#sobre` e defina a `root`.
4. Aninhe `comentarios` dentro de `posts` e anote o helper para listar os comentários de um post.
5. Adicione a rota `PATCH /tarefas/:id/concluir` com `member`.
6. Configure a *inflection* para que `Perfil` use a tabela `perfis`.
