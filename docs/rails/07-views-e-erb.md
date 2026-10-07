# 07 — Views e ERB

A view gera o que o usuário vê. No Rails, o formato padrão é **ERB** (*Embedded Ruby*): HTML com trechos de Ruby.

## Sintaxe do ERB

| Tag | Efeito |
|-----|--------|
| `<%= expressao %>` | Executa e **imprime** o resultado |
| `<% codigo %>` | Executa, **não** imprime (ifs, loops) |
| `<%# comentario %>` | Comentário (não vai para o HTML) |
| `<%- ... -%>` | Variantes que controlam espaços (raro) |

```erb
<h1><%= @tarefa.titulo %></h1>

<% if @tarefa.concluida? %>
  <p>✔ Concluída</p>
<% else %>
  <p>Pendente</p>
<% end %>

<ul>
  <% @tarefas.each do |tarefa| %>
    <li><%= tarefa.titulo %></li>
  <% end %>
</ul>
```

Erro comum: usar `<% %>` quando queria `<%= %>` (nada aparece), ou `<%= %>` em `if`/`each` (imprime lixo).

## Onde ficam os arquivos

`app/views/<controller>/<action>.html.erb`

```
app/views/
├── layouts/application.html.erb
├── tarefas/
│   ├── index.html.erb
│   ├── show.html.erb
│   ├── new.html.erb
│   ├── edit.html.erb
│   ├── _form.html.erb       ← partial (começa com _)
│   └── _tarefa.html.erb
└── shared/
    └── _menu.html.erb
```

Variáveis `@...` definidas na action estão disponíveis na view.

## Segurança: escape automático

O ERB **escapa HTML** por padrão, protegendo contra XSS:

```erb
<%= "<script>alert('x')</script>" %>
<%# imprime o texto literal, sem executar o script %>
```

Só marque como seguro (`raw`, `html_safe`, `sanitize`) conteúdo **que você controla**. Nunca em dados vindos do usuário sem `sanitize`.

## Helpers de links e botões

```erb
<%= link_to "Voltar", tarefas_path %>
<%= link_to "Detalhes", @tarefa %>
<%= link_to "Editar", edit_tarefa_path(@tarefa), class: "btn" %>
<%= link_to "Site", "https://ruby-lang.org", target: "_blank", rel: "noopener" %>
<%= button_to "Excluir", @tarefa, method: :delete,
              form: { data: { turbo_confirm: "Tem certeza?" } } %>
```

Para ações que alteram dados, use `button_to` (gera um formulário) em vez de link.

## Formulários: `form_with`

```erb
<%# app/views/tarefas/_form.html.erb %>
<%= form_with model: tarefa do |f| %>
  <% if tarefa.errors.any? %>
    <div class="erros">
      <h3><%= pluralize(tarefa.errors.count, "erro") %>:</h3>
      <ul>
        <% tarefa.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= f.label :titulo %>
    <%= f.text_field :titulo %>
  </div>

  <div>
    <%= f.label :descricao %>
    <%= f.text_area :descricao, rows: 4 %>
  </div>

  <div>
    <%= f.check_box :concluida %>
    <%= f.label :concluida, "Concluída" %>
  </div>

  <%= f.submit %>
<% end %>
```

`form_with model: tarefa` é inteligente:

- Se `tarefa` é nova (`Tarefa.new`): envia **POST** para `/tarefas`.
- Se já existe: envia **PATCH** para `/tarefas/:id`.

Campos mais usados:

| Helper | Gera |
|--------|------|
| `f.text_field :nome` | `<input type="text">` |
| `f.text_area :texto` | `<textarea>` |
| `f.number_field :preco` | `<input type="number">` |
| `f.email_field`, `f.password_field` | e-mail / senha |
| `f.date_field :prazo` | data |
| `f.check_box :ativo` | caixa de seleção |
| `f.select :categoria, ["A", "B"]` | lista suspensa |
| `f.collection_select :autor_id, Autor.all, :id, :nome` | lista a partir de registros |
| `f.submit "Salvar"` | botão |

O formulário envia os dados como `params[:tarefa][:titulo]` — por isso o controller usa `params.require(:tarefa)`.

## Partials

Trechos reutilizáveis, com nome iniciado em `_`.

```erb
<%# renderiza app/views/tarefas/_form.html.erb %>
<%= render "form", tarefa: @tarefa %>

<%# renderiza uma partial para cada item (usa _tarefa.html.erb) %>
<%= render @tarefas %>

<%# equivalente, explícito %>
<%= render partial: "tarefa", collection: @tarefas, as: :tarefa %>

<%# partial compartilhada %>
<%= render "shared/menu" %>
```

```erb
<%# app/views/tarefas/_tarefa.html.erb %>
<li id="<%= dom_id(tarefa) %>">
  <%= link_to tarefa.titulo, tarefa %>
</li>
```

Dentro da partial, os dados chegam como **variáveis locais** (`tarefa`), não `@tarefa`. `dom_id(tarefa)` gera `tarefa_5`.

## Layouts

O layout envolve todas as views; fica em `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <title><%= content_for(:titulo) || "Minha App" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <%= render "shared/menu" %>

    <% if notice %><p class="aviso"><%= notice %></p><% end %>

    <main>
      <%= yield %>        <%# aqui entra a view da action %>
    </main>
  </body>
</html>
```

- `yield` marca onde a view da action é inserida.
- Cada view pode definir o título: `<% content_for :titulo, "Tarefas" %>`.
- Para trocar o layout de um controller: `layout "admin"`.

## Helpers úteis

```erb
<%= number_to_currency(1234.5, unit: "R$ ", separator: ",", delimiter: ".") %>
<%# => R$ 1.234,50 %>
<%= l(@tarefa.prazo, format: :short) %>
<%= time_ago_in_words(@tarefa.created_at) %>    <%# "há 3 dias" (com locale pt-BR) %>
<%= truncate(@tarefa.descricao, length: 50) %>
<%= pluralize(3, "tarefa") %>
<%= simple_format(@tarefa.descricao) %>          <%# quebras de linha → <p>/<br> %>
<%= image_tag "logo.png", alt: "Logo" %>
```

### Helpers próprios

```ruby
# app/helpers/tarefas_helper.rb
module TarefasHelper
  def rotulo_status(tarefa)
    tarefa.concluida? ? "Concluída" : "Pendente"
  end
end
```

```erb
<%= rotulo_status(@tarefa) %>
```

Todos os helpers de `app/helpers` estão disponíveis em todas as views.

## Exemplo completo: `index`

```erb
<%# app/views/tarefas/index.html.erb %>
<h1>Tarefas</h1>

<%= link_to "Nova tarefa", new_tarefa_path %>

<% if @tarefas.empty? %>
  <p>Nenhuma tarefa cadastrada.</p>
<% else %>
  <table>
    <thead>
      <tr><th>Título</th><th>Status</th><th></th></tr>
    </thead>
    <tbody>
      <% @tarefas.each do |tarefa| %>
        <tr>
          <td><%= link_to tarefa.titulo, tarefa %></td>
          <td><%= rotulo_status(tarefa) %></td>
          <td>
            <%= link_to "Editar", edit_tarefa_path(tarefa) %>
            <%= button_to "Excluir", tarefa, method: :delete %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
<% end %>
```

## Outros formatos de view

| Arquivo | Para |
|---------|------|
| `show.html.erb` | HTML |
| `show.json.jbuilder` | JSON montado com Jbuilder |
| `show.turbo_stream.erb` | Atualizações parciais da página (Turbo Streams) |
| `.text.erb` | E-mails em texto |

## Boas práticas

1. Sem consultas ao banco dentro de views; prepare no controller.
2. Lógica complexa → helper ou método do model.
3. Quebre telas grandes em partials.
4. Use helpers de rota e de formulário, não HTML escrito à mão.
5. Confie no escape automático; evite `raw`/`html_safe`.

## Resumo

- ERB: `<%= %>` imprime, `<% %>` apenas executa.
- Views em `app/views/<controller>/<action>.html.erb`; variáveis `@` vêm do controller.
- `form_with model:` escolhe POST ou PATCH sozinho e liga o formulário ao model.
- Partials (`_nome`) reaproveitam trechos; o layout envolve tudo com `yield`.
- O escape de HTML é automático e protege contra XSS.

## Exercícios

1. Crie `index.html.erb` listando produtos em uma tabela, com mensagem para lista vazia.
2. Extraia cada linha em uma partial `_produto.html.erb` e use `render @produtos`.
3. Monte `_form.html.erb` para `Produto` e reaproveite em `new` e `edit`.
4. Formate o preço com `number_to_currency` em reais.
5. Mostre as mensagens de erro de validação acima do formulário.
6. Crie um helper `rotulo_estoque(produto)` que devolve "Esgotado" ou "Disponível".
