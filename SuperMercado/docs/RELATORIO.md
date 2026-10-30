# SuperMercado: relatório e passo a passo

## 1. Resumo

O projeto tinha só o CRUD de **Categoria**. Agora tem 5 CRUDs, todos no mesmo padrão:

| CRUD | URL | O que é |
|------|-----|---------|
| Categorias | `/categories` | Tipo de produto (Bebidas, Limpeza...) |
| Produtos | `/products` | Produto com preço, estoque, código de barras e categoria |
| Caixas | `/checkouts` | Caixa do mercado (Caixa 1, Caixa 2...), aberto ou fechado |
| Vendas | `/sales` | Uma venda feita em um caixa |
| Itens da venda | `/item_sales` | Produto + quantidade dentro de uma venda |

Cada CRUD tem: model (com validações), controller (7 actions), rotas (`resources`) e as views `index`, `show`, `new`, `edit` e **`_form`** (um formulário só, usado pelo new e pelo edit).

Todo arquivo tem comentários curtos explicando o código. Onde havia erro, o comentário começa com **ERRO:** e diz como foi corrigido (**CORREÇÃO:**).

## 2. Erros encontrados no CRUD de Categoria

| # | Arquivo | Erro | Correção |
|---|---------|------|----------|
| 1 | `views/categories/index.html.erb` | `<% c.name %>` sem o `=`: o nome não aparecia | `<%= %>` mostra na tela; `<% %>` só executa |
| 2 | `views/categories/index.html.erb` | Botão Delete com `categories_path(c)`: gera `/categories.1` e dá erro de rota | `category_path(c)` (singular) gera `/categories/1` |
| 3 | `views/categories/index.html.erb` | `<ul>` dentro do loop e dentro de `<p>` (HTML inválido) | Um `<ul>` fora do loop e um `<li>` por categoria |
| 4 | `views/categories/index.html.erb` | Título "Categorys" | "Categorias" |
| 5 | `views/categories/show.html.erb` | Links com `<%` sem `=`: não apareciam | `<%= link_to ... %>` |
| 6 | `views/categories/edit.html.erb` | Campo `:nome`, mas a coluna é `name`: a página de editar quebrava | Formulário único `_form.html.erb` para new e edit |
| 7 | `controllers/categories_controller.rb` | `@categories` (plural) para UMA categoria | `@categories` só no index, `@category` no resto |
| 8 | `controllers/categories_controller.rb` | Comentários falando de `Produto` / `produtos_controller.rb` (copiado de outro projeto) | Comentários reescritos para `Category` |
| 9 | `controllers/categories_controller.rb` | `status: :unprocessable_entity` está obsoleto no Rack 3 (gera aviso no log) | `status: :unprocessable_content` (mesmo código 422) |
| 10 | `controllers/categories_controller.rb` | `destroy` não tratava falha | `if @category.destroy ... else ... alert:` |
| 11 | `controllers/categories_controller.rb` | Comentário "private para não ser mostrado na view" | `private` = o método não vira action (nenhuma URL chama ele) |
| 12 | `models/category.rb` | Faltava `has_many :products`: apagar categoria com produtos dava erro 500 | `has_many :products, dependent: :restrict_with_error` |
| 13 | `models/category.rb` | Mensagem aparecia como "Name Erro..Nome não informado." | `full_messages` já põe o nome do campo; mensagem virou "não pode ficar em branco" |
| 14 | `views/layouts/application.html.erb` | O `notice:` dos redirects nunca aparecia na tela | `notice` e `alert` mostrados no layout (aparecem em todas as páginas) |
| 15 | `db/migrate/` | Colunas com erro de digitação: `inventary`, `unit_prince`, `Completed_in` | Nova migration `FixColumnNames` renomeia para `inventory`, `unit_price`, `completed_at` |
| 16 | `config/routes.rb` | Comentário da tabela de rotas falava de `/produtos` | Tabela com `/categories` |

> Por que uma migration nova e não editar as antigas? Migration que já rodou não deve ser editada. A nova corrige o banco de todo mundo com `bin/rails db:migrate`.

## 3. Arquivos criados ou alterados

```
app/models/            category.rb (corrigido), product.rb, checkout.rb, sale.rb, item_sale.rb
app/controllers/       categories_controller.rb (corrigido), products_, checkouts_, sales_, item_sales_controller.rb
app/views/categories/  index, show, new, edit (corrigidos) + _form (novo)
app/views/products/    index, show, new, edit, _form
app/views/checkouts/   index, show, new, edit, _form
app/views/sales/       index, show, new, edit, _form
app/views/item_sales/  index, show, new, edit, _form
app/views/layouts/application.html.erb   (notice/alert + fonte)
app/assets/stylesheets/application.css   (CSS de todas as telas)
app/controllers/home_controller.rb + app/views/home/index.html.erb   (página inicial, root)
config/routes.rb                         (resources dos 5 CRUDs)
db/migrate/20261029120000_fix_column_names.rb
test/fixtures/         products.yml, sales.yml, item_sales.yml (nomes de coluna novos)
```

## 4. Passo a passo: como montar um CRUD (exemplo: Produto)

**1. Criar a tabela (migration + model)**

```bash
bin/rails g model Product name:string price:decimal inventory:integer barcode:string category:references
bin/rails db:migrate
```

`category:references` cria a coluna `category_id` e já coloca `belongs_to :category` no model.

**2. Rotas** (`config/routes.rb`)

```ruby
resources :products
```

Uma linha cria as 7 rotas: index, show, new, create, edit, update, destroy. Para ver todas: `bin/rails routes`.

**3. Model** (`app/models/product.rb`): associações e validações

```ruby
belongs_to :category
validates :name, presence: true
```

E no outro lado (`category.rb`): `has_many :products`.

**4. Controller** (`app/controllers/products_controller.rb`)

- `before_action :set_product`: busca o registro antes de show/edit/update/destroy
- `index`: `@products = Product.all`
- `new`: `@product = Product.new`
- `create`: `Product.new(product_params)`, depois `save`, depois `redirect_to` ou `render :new, status: :unprocessable_content`
- `update`: `@product.update(product_params)`, depois `redirect_to` ou `render :edit`
- `destroy`: `@product.destroy`, depois `redirect_to products_path`
- `product_params`: `params.require(:product).permit(...)` (só os campos liberados)

**5. Views** (`app/views/products/`)

- `_form.html.erb`: o formulário (`form_with model: product`), usado pelo new e pelo edit
- `new.html.erb` e `edit.html.erb`: só o título + `<%= render "form", product: @product %>`
- `index.html.erb`: lista com links Editar/Apagar
- `show.html.erb`: mostra um registro

**6. Testar no navegador**: `http://localhost:3000/products`

## 5. Como rodar o projeto

```bash
bundle install
bin/rails db:migrate
bin/rails server
```

Abra `http://localhost:3000`: a página inicial (root) tem os links para os 5 cadastros. Como ela foi feita: `docs/TUTORIAL_LANDING_PAGE.md`.

Ordem para cadastrar (cada um depende do anterior):
**Categoria**, depois **Produto**, depois **Caixa**, depois **Venda**, depois **Item da venda**.

## 6. CSS

Um arquivo só, `app/assets/stylesheets/application.css`, vale para todas as telas. As views não têm classes: o CSS usa as próprias tags (`h1`, `ul`, `li`, `form`...).

- Título = etiqueta de preço amarela (`h1`, `h2`)
- Link "Novo..." logo depois do título vira botão (`h1 + a`)
- Botão "Apagar" em vermelho (`button`, criado pelo `button_to`)
- Formulário numa caixa branca (`body > form`)
- Campo com erro em vermelho (`.field_with_errors`, a div que o Rails cria quando a validação falha)
- Mensagens `notice` (verde) e `alert` (vermelho) do layout
- Cores em variáveis no `:root`: para mudar uma cor no site todo, muda em um lugar só

## 7. O que ficou de fora (de propósito, para manter simples)

- **Total da venda e preço do item são digitados à mão.** Num sistema real, o total seria a soma dos itens e o preço viria do produto (callbacks no model).
- **Estoque não diminui** quando um item é vendido.
- **Mensagens de erro padrão do Rails aparecem em inglês** (ex.: "Category must exist"). Para traduzir, é preciso um arquivo de tradução pt-BR em `config/locales/`.
