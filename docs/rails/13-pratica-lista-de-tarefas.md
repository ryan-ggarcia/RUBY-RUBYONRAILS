# 13 — Prática: Lista de tarefas

Projeto guiado que junta tudo: um app de **tarefas organizadas por categoria**, com CRUD, validações, associação e uma ação extra ("concluir"). Tempo estimado: 60–90 minutos.

## Objetivo final

- Listar, criar, editar, excluir tarefas.
- Cada tarefa pertence a uma **categoria**.
- Marcar tarefa como concluída com um clique.
- Filtrar por pendentes/concluídas.

## Passo 1 — Criar o projeto

```bash
rails new lista_tarefas
cd lista_tarefas
bin/rails server
```

Abra `http://localhost:3000` para confirmar. Pare o servidor (`Ctrl+C`) e continue.

## Passo 2 — Configurar idioma e fuso

```ruby
# config/application.rb (dentro de class Application)
config.time_zone = "Brasilia"
config.i18n.default_locale = :"pt-BR"
```

Opcional: adicione `gem "rails-i18n"` ao `Gemfile` e rode `bundle install` para traduzir mensagens.

## Passo 3 — Modelar: Categoria e Tarefa

```bash
bin/rails g model Categoria nome:string
bin/rails g model Tarefa titulo:string descricao:text prazo:date concluida:boolean categoria:references
```

Edite as migrations antes de migrar, para valores padrão e restrições:

```ruby
# db/migrate/..._create_categorias.rb
create_table :categorias do |t|
  t.string :nome, null: false
  t.timestamps
end
add_index :categorias, :nome, unique: true
```

```ruby
# db/migrate/..._create_tarefas.rb
create_table :tarefas do |t|
  t.string  :titulo,    null: false
  t.text    :descricao
  t.date    :prazo
  t.boolean :concluida, null: false, default: false
  t.references :categoria, null: false, foreign_key: true
  t.timestamps
end
```

```bash
bin/rails db:migrate
```

## Passo 4 — Models: associações e validações

```ruby
# app/models/categoria.rb
class Categoria < ApplicationRecord
  has_many :tarefas, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: { case_sensitive: false }
end
```

```ruby
# app/models/tarefa.rb
class Tarefa < ApplicationRecord
  belongs_to :categoria

  validates :titulo, presence: true, length: { minimum: 3, maximum: 100 }
  validate  :prazo_nao_pode_estar_no_passado, on: :create

  scope :pendentes,  -> { where(concluida: false) }
  scope :concluidas, -> { where(concluida: true) }
  scope :recentes,   -> { order(created_at: :desc) }

  def atrasada?
    !concluida? && prazo.present? && prazo < Date.current
  end

  private

  def prazo_nao_pode_estar_no_passado
    return if prazo.blank?
    errors.add(:prazo, "não pode estar no passado") if prazo < Date.current
  end
end
```

Teste no console:

```bash
bin/rails c
```

```ruby
cat = Categoria.create!(nome: "Estudos")
Tarefa.create!(titulo: "Ler capítulo de Rails", categoria: cat)
Tarefa.create(titulo: "x", categoria: cat).errors.full_messages
cat.tarefas.count
```

## Passo 5 — Seeds

```ruby
# db/seeds.rb
estudos  = Categoria.find_or_create_by!(nome: "Estudos")
trabalho = Categoria.find_or_create_by!(nome: "Trabalho")

Tarefa.find_or_create_by!(titulo: "Ler sobre MVC", categoria: estudos)
Tarefa.find_or_create_by!(titulo: "Enviar relatório", categoria: trabalho, prazo: Date.current + 2)
```

```bash
bin/rails db:seed
```

## Passo 6 — Rotas

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "tarefas#index"

  resources :categorias, except: %i[show]
  resources :tarefas do
    member do
      patch :concluir
    end
  end
end
```

Confira com `bin/rails routes -g tarefa`.

## Passo 7 — Controller de tarefas

```ruby
# app/controllers/tarefas_controller.rb
class TarefasController < ApplicationController
  before_action :set_tarefa, only: %i[show edit update destroy concluir]

  def index
    @tarefas = Tarefa.includes(:categoria).recentes
    @tarefas = @tarefas.pendentes  if params[:filtro] == "pendentes"
    @tarefas = @tarefas.concluidas if params[:filtro] == "concluidas"
  end

  def show; end

  def new
    @tarefa = Tarefa.new
  end

  def create
    @tarefa = Tarefa.new(tarefa_params)
    if @tarefa.save
      redirect_to tarefas_path, notice: "Tarefa criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tarefa.update(tarefa_params)
      redirect_to tarefas_path, notice: "Tarefa atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tarefa.destroy
    redirect_to tarefas_path, notice: "Tarefa removida.", status: :see_other
  end

  def concluir
    @tarefa.update!(concluida: true)
    redirect_to tarefas_path, notice: "Tarefa concluída!"
  end

  private

  def set_tarefa
    @tarefa = Tarefa.find(params[:id])
  end

  def tarefa_params
    params.require(:tarefa).permit(:titulo, :descricao, :prazo, :concluida, :categoria_id)
  end
end
```

## Passo 8 — Controller de categorias

```bash
bin/rails g controller Categorias index new edit
```

```ruby
# app/controllers/categorias_controller.rb
class CategoriasController < ApplicationController
  before_action :set_categoria, only: %i[edit update destroy]

  def index
    @categorias = Categoria.order(:nome)
  end

  def new
    @categoria = Categoria.new
  end

  def create
    @categoria = Categoria.new(categoria_params)
    if @categoria.save
      redirect_to categorias_path, notice: "Categoria criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @categoria.update(categoria_params)
      redirect_to categorias_path, notice: "Categoria atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @categoria.destroy
      redirect_to categorias_path, notice: "Categoria removida.", status: :see_other
    else
      redirect_to categorias_path,
                  alert: @categoria.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.require(:categoria).permit(:nome)
  end
end
```

## Passo 9 — Views

### Layout com menu e mensagens

```erb
<%# app/views/layouts/application.html.erb (trecho do body) %>
<body>
  <nav>
    <%= link_to "Tarefas", tarefas_path %> |
    <%= link_to "Categorias", categorias_path %> |
    <%= link_to "Nova tarefa", new_tarefa_path %>
  </nav>

  <% if notice %><p class="aviso"><%= notice %></p><% end %>
  <% if alert  %><p class="erro"><%= alert %></p><% end %>

  <main><%= yield %></main>
</body>
```

### Lista de tarefas

```erb
<%# app/views/tarefas/index.html.erb %>
<h1>Tarefas</h1>

<p>
  Filtrar:
  <%= link_to "Todas", tarefas_path %> |
  <%= link_to "Pendentes", tarefas_path(filtro: "pendentes") %> |
  <%= link_to "Concluídas", tarefas_path(filtro: "concluidas") %>
</p>

<% if @tarefas.empty? %>
  <p>Nenhuma tarefa por aqui.</p>
<% else %>
  <table>
    <thead>
      <tr><th>Título</th><th>Categoria</th><th>Prazo</th><th>Status</th><th>Ações</th></tr>
    </thead>
    <tbody>
      <%= render @tarefas %>
    </tbody>
  </table>
<% end %>
```

```erb
<%# app/views/tarefas/_tarefa.html.erb %>
<tr id="<%= dom_id(tarefa) %>">
  <td><%= link_to tarefa.titulo, tarefa %></td>
  <td><%= tarefa.categoria.nome %></td>
  <td>
    <%= tarefa.prazo ? l(tarefa.prazo) : "—" %>
    <%= "(atrasada)" if tarefa.atrasada? %>
  </td>
  <td><%= tarefa.concluida? ? "Concluída" : "Pendente" %></td>
  <td>
    <% unless tarefa.concluida? %>
      <%= button_to "Concluir", concluir_tarefa_path(tarefa), method: :patch %>
    <% end %>
    <%= link_to "Editar", edit_tarefa_path(tarefa) %>
    <%= button_to "Excluir", tarefa, method: :delete,
          form: { data: { turbo_confirm: "Excluir esta tarefa?" } } %>
  </td>
</tr>
```

### Formulário compartilhado

```erb
<%# app/views/tarefas/_form.html.erb %>
<%= form_with model: tarefa do |f| %>
  <% if tarefa.errors.any? %>
    <div class="erros">
      <ul>
        <% tarefa.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p><%= f.label :titulo %><br><%= f.text_field :titulo %></p>
  <p><%= f.label :descricao %><br><%= f.text_area :descricao, rows: 4 %></p>
  <p><%= f.label :prazo %><br><%= f.date_field :prazo %></p>
  <p>
    <%= f.label :categoria_id, "Categoria" %><br>
    <%= f.collection_select :categoria_id, Categoria.order(:nome), :id, :nome,
                            prompt: "Selecione..." %>
  </p>
  <p><%= f.check_box :concluida %> <%= f.label :concluida, "Concluída" %></p>

  <%= f.submit "Salvar" %>
<% end %>
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
<%= link_to "Cancelar", tarefas_path %>
```

```erb
<%# app/views/tarefas/show.html.erb %>
<h1><%= @tarefa.titulo %></h1>
<p><strong>Categoria:</strong> <%= @tarefa.categoria.nome %></p>
<p><strong>Prazo:</strong> <%= @tarefa.prazo ? l(@tarefa.prazo) : "sem prazo" %></p>
<%= simple_format(@tarefa.descricao) %>
<%= link_to "Editar", edit_tarefa_path(@tarefa) %> |
<%= link_to "Voltar", tarefas_path %>
```

### Categorias (resumo)

```erb
<%# app/views/categorias/index.html.erb %>
<h1>Categorias</h1>
<%= link_to "Nova categoria", new_categoria_path %>
<ul>
  <% @categorias.each do |categoria| %>
    <li>
      <%= categoria.nome %> (<%= categoria.tarefas.count %>)
      <%= link_to "Editar", edit_categoria_path(categoria) %>
      <%= button_to "Excluir", categoria, method: :delete %>
    </li>
  <% end %>
</ul>
```

```erb
<%# app/views/categorias/_form.html.erb %>
<%= form_with model: categoria do |f| %>
  <% categoria.errors.full_messages.each do |msg| %><p class="erro"><%= msg %></p><% end %>
  <p><%= f.label :nome %><br><%= f.text_field :nome %></p>
  <%= f.submit "Salvar" %>
<% end %>
```

`new.html.erb` e `edit.html.erb` de categorias: um título e `<%= render "form", categoria: @categoria %>`.

## Passo 10 — Testar o fluxo

1. `bin/rails server` e abra `http://localhost:3000`.
2. Crie uma categoria, depois uma tarefa nela.
3. Tente salvar uma tarefa com título de 1 letra: o erro deve aparecer.
4. Marque como concluída e use os filtros.
5. Tente excluir uma categoria que tem tarefas: deve ser bloqueado.

## Desafios extras

1. **Contador:** exiba no topo "X pendentes de Y tarefas" usando `Tarefa.pendentes.count`.
2. **Busca:** campo de busca por título usando `params[:q]`.
3. **Ordenação:** ordenar por prazo, colocando as atrasadas em destaque (CSS).
4. **Enum:** trocar `concluida` por `status` (`pendente`, `em_andamento`, `concluida`).
5. **Testes:** escrever testes de model (validações) com Minitest.
6. **Paginação:** adicionar a gem `pagy`.
7. **Autenticação:** gerar login com `bin/rails generate authentication` (Rails 8) ou usar `devise`.
8. **API:** responder `index` em JSON.
9. **Publicação:** colocar o app no ar (Render, Fly.io, Railway ou Kamal).

## Checklist do que você praticou

- [x] `rails new`, `generate model`/`controller`, migrations
- [x] Rotas com `resources` e `member`
- [x] Controllers com strong parameters e `before_action`
- [x] Views com ERB, partials, layout e `form_with`
- [x] Validações, `scope`, métodos no model
- [x] Associação `belongs_to` / `has_many` com `dependent`
- [x] Seeds e console

## Resumo

- Um app Rails completo nasce da combinação de migrations, models, rotas, controllers e views.
- A ordem recomendada: **modelar o banco → models → rotas → controllers → views**.
- Valide no model, restrinja no banco, redirecione após sucesso e renderize após falha.

## Exercícios

Os desafios extras acima são os exercícios deste documento. Escolha ao menos três e implemente.
