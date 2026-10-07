# 12 — CRUD completo

**CRUD** = **C**reate, **R**ead, **U**pdate, **D**elete — as quatro operações básicas sobre dados. No Rails, elas se traduzem nas **7 ações RESTful** de um controller.

## As 7 ações

| Operação | Action | Verbo + URL | Para quê |
|----------|--------|-------------|----------|
| Read | `index` | GET `/tarefas` | Listar |
| Read | `show` | GET `/tarefas/:id` | Mostrar um |
| Create | `new` | GET `/tarefas/new` | Exibir formulário vazio |
| Create | `create` | POST `/tarefas` | Gravar novo |
| Update | `edit` | GET `/tarefas/:id/edit` | Exibir formulário preenchido |
| Update | `update` | PATCH/PUT `/tarefas/:id` | Gravar alteração |
| Delete | `destroy` | DELETE `/tarefas/:id` | Remover |

Quatro delas **exibem** páginas (`index`, `show`, `new`, `edit`) e três **alteram** dados (`create`, `update`, `destroy`).

## O jeito rápido: scaffold

```bash
bin/rails generate scaffold Tarefa titulo:string descricao:text concluida:boolean
bin/rails db:migrate
bin/rails server
```

Abra `http://localhost:3000/tarefas`. O scaffold gera **tudo**: model, migration, controller com as 7 ações, views, rotas (`resources :tarefas`) e testes.

Use o scaffold para **aprender e prototipar**. Em projetos reais, costuma-se gerar peça por peça. Para desfazer: `bin/rails destroy scaffold Tarefa`.

## O controller completo

```ruby
# app/controllers/tarefas_controller.rb
class TarefasController < ApplicationController
  before_action :set_tarefa, only: %i[show edit update destroy]

  # GET /tarefas
  def index
    @tarefas = Tarefa.order(created_at: :desc)
  end

  # GET /tarefas/1
  def show
  end

  # GET /tarefas/new
  def new
    @tarefa = Tarefa.new
  end

  # POST /tarefas
  def create
    @tarefa = Tarefa.new(tarefa_params)

    if @tarefa.save
      redirect_to @tarefa, notice: "Tarefa criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tarefas/1/edit
  def edit
  end

  # PATCH/PUT /tarefas/1
  def update
    if @tarefa.update(tarefa_params)
      redirect_to @tarefa, notice: "Tarefa atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tarefas/1
  def destroy
    @tarefa.destroy
    redirect_to tarefas_path, notice: "Tarefa removida.", status: :see_other
  end

  private

  def set_tarefa
    @tarefa = Tarefa.find(params[:id])
  end

  def tarefa_params
    params.require(:tarefa).permit(:titulo, :descricao, :concluida)
  end
end
```

## Entendendo cada ação

### `new` e `create`: dois passos

1. `GET /tarefas/new` → `new` cria um `Tarefa.new` **vazio** (em memória) e a view mostra o formulário.
2. O usuário preenche e envia: `POST /tarefas` → `create` monta o objeto com os dados (`tarefa_params`) e tenta salvar.
3. Sucesso → `redirect_to` (padrão Post/Redirect/Get). Falha → `render :new` com status 422, mantendo o que o usuário digitou e exibindo os erros.

### `edit` e `update`: idem

1. `GET /tarefas/1/edit` → `set_tarefa` carrega o registro; a view mostra o formulário já preenchido.
2. `PATCH /tarefas/1` → `update` aplica as mudanças e salva.

### `destroy`

Remove e redireciona para a lista (com `status: :see_other` por causa do Turbo).

### Por que `redirect_to` e não `render` no sucesso?

Se renderizasse, o usuário atualizaria a página e o navegador **reenviaria o POST**, duplicando o registro. O redirect transforma a resposta em um GET seguro.

## As views

```erb
<%# app/views/tarefas/index.html.erb %>
<h1>Tarefas</h1>
<%= link_to "Nova tarefa", new_tarefa_path %>

<%= render @tarefas %>
```

```erb
<%# app/views/tarefas/_tarefa.html.erb %>
<div id="<%= dom_id(tarefa) %>">
  <h3><%= link_to tarefa.titulo, tarefa %></h3>
  <p><%= tarefa.descricao %></p>
  <%= link_to "Editar", edit_tarefa_path(tarefa) %>
  <%= button_to "Excluir", tarefa, method: :delete,
        form: { data: { turbo_confirm: "Excluir esta tarefa?" } } %>
</div>
```

```erb
<%# app/views/tarefas/show.html.erb %>
<%= render @tarefa %>
<%= link_to "Voltar", tarefas_path %>
```

```erb
<%# app/views/tarefas/new.html.erb %>
<h1>Nova tarefa</h1>
<%= render "form", tarefa: @tarefa %>
<%= link_to "Cancelar", tarefas_path %>
```

```erb
<%# app/views/tarefas/edit.html.erb %>
<h1>Editar tarefa</h1>
<%= render "form", tarefa: @tarefa %>
```

`_form.html.erb` é o mesmo mostrado no [doc 07](07-views-e-erb.md): um só formulário atende `new` e `edit`.

## O fluxo todo, de ponta a ponta

```
Criar
 GET  /tarefas/new   → new      → formulário vazio
 POST /tarefas       → create   → valida e salva → redirect /tarefas/5 (ou volta ao form com erros)

Ler
 GET  /tarefas       → index    → lista
 GET  /tarefas/5     → show     → detalhe

Atualizar
 GET   /tarefas/5/edit → edit   → formulário preenchido
 PATCH /tarefas/5      → update → valida e salva → redirect /tarefas/5

Remover
 DELETE /tarefas/5   → destroy  → remove → redirect /tarefas
```

## Por que PATCH e DELETE se o HTML só tem GET e POST?

Formulários HTML só enviam GET e POST. O Rails inclui um campo oculto `_method` (ou o Turbo envia o verbo correto) para simular PATCH/PUT/DELETE. Por isso o `form_with` e o `button_to` cuidam disso para você.

## Respondendo também em JSON

```ruby
def index
  @tarefas = Tarefa.all
  respond_to do |format|
    format.html
    format.json { render json: @tarefas }
  end
end

def create
  @tarefa = Tarefa.new(tarefa_params)
  respond_to do |format|
    if @tarefa.save
      format.html { redirect_to @tarefa, notice: "Criada." }
      format.json { render json: @tarefa, status: :created }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @tarefa.errors, status: :unprocessable_entity }
    end
  end
end
```

## Detalhes importantes

| Tema | Ponto de atenção |
|------|------------------|
| Segurança | Strong parameters em `create` e `update` |
| Falha | `render` com `:unprocessable_entity` para o Turbo exibir o formulário com erros |
| Exclusão | `button_to ... method: :delete`, não `link_to` |
| Redirecionamento | `redirect_to @tarefa` usa `tarefa_path(@tarefa)` |
| Não encontrado | `find` levanta `RecordNotFound` → 404 |
| Paginação | Listas grandes pedem paginação (`pagy`, `kaminari`) |

## Extensões comuns ao CRUD

- **Busca e filtros:** `Tarefa.where("titulo LIKE ?", "%#{params[:q]}%")`.
- **Ordenação e paginação.**
- **Autenticação e autorização:** quem pode ver/editar o quê (`devise`, `pundit`).
- **Ações extras:** `PATCH /tarefas/:id/concluir` (rota `member`).
- **Upload de arquivos:** Active Storage.

## Resumo

- CRUD = 7 ações: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`.
- `new`/`edit` mostram formulários; `create`/`update`/`destroy` alteram dados e redirecionam.
- Em falha de validação: `render` com status 422; em sucesso: `redirect_to`.
- `resources` + strong parameters + `form_with` + partial `_form` = CRUD enxuto.

## Exercícios

1. Gere um scaffold `Produto` (`nome:string preco:decimal estoque:integer`) e navegue por todas as telas.
2. Leia o controller gerado e comente cada action com suas palavras.
3. Adicione validações e veja os erros aparecerem no formulário.
4. Troque o `index` para mostrar apenas produtos em estoque, ordenados por nome.
5. Escreva do zero o CRUD de `Categoria` (sem scaffold), com controller, rotas e views.
6. Acrescente uma busca por nome em `index` usando `params[:q]`.
7. Explique, com o padrão Post/Redirect/Get, por que o `create` bem-sucedido usa `redirect_to`.
