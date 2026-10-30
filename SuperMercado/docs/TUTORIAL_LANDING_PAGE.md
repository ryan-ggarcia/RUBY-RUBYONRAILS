# Tutorial: página inicial (landing page) como root

Objetivo: quando alguém abrir `http://localhost:3000`, aparece uma página inicial com os links para os 5 cadastros, em vez da tela padrão do Rails.

Uma página no Rails sempre precisa de 3 coisas: **rota**, **controller** e **view**.

```
navegador pede "/"  ->  rota (routes.rb)  ->  controller (HomeController#index)  ->  view (home/index.html.erb)
```

---

## Passo 1: criar o controller

Arquivo novo: `app/controllers/home_controller.rb`

```ruby
class HomeController < ApplicationController
  def index
  end
end
```

- O nome da classe é `HomeController`, e o arquivo é `home_controller.rb`. O Rails liga um ao outro pelo nome (convenção).
- A action `index` fica vazia porque a página não busca nada no banco.
- Sem `render`, o Rails abre sozinho a view com o mesmo nome: `app/views/home/index.html.erb`.

## Passo 2: criar a view

Pasta nova: `app/views/home/`. Arquivo novo: `app/views/home/index.html.erb`

```erb
<section class="home">
  <h1>SuperMercado</h1>
  <p>Sistema do mercado: cadastre os produtos, abra os caixas e registre as vendas.</p>

  <ol>
    <li>
      <%= link_to "Categorias", categories_path %>
      <span>Tipos de produto: Bebidas, Limpeza, Hortifrúti.</span>
    </li>
    <%# ... um <li> para cada cadastro: products_path, checkouts_path, sales_path, item_sales_path %>
  </ol>
</section>
```

- `link_to "Texto", caminho` cria um link `<a href="...">`.
- `categories_path` é um **route helper**: o `resources :categories` das rotas cria esse método, e ele devolve `"/categories"`. Se a URL mudar um dia, o link continua certo.
- `<ol>` é uma lista numerada. Foi usada porque a ordem importa: cada cadastro usa o anterior.
- `class="home"` serve para o CSS da página valer só aqui (passo 4).

## Passo 3: colocar a página como root

Arquivo: `config/routes.rb`

```ruby
Rails.application.routes.draw do
  root "home#index"

  resources :categories
  # ...
end
```

- `root` define a página do endereço `/`.
- `"home#index"` significa `HomeController`, action `index` (formato `"controller#action"`).
- O `root` também cria o helper `root_path` (`"/"`). Para um link "Início" em qualquer tela, use `<%= link_to "Início", root_path %>`.

Para conferir no terminal:

```bash
bin/rails routes -g root
#  root GET  /  home#index
```

## Passo 4: CSS da página

No fim de `app/assets/stylesheets/application.css` foi adicionado um bloco em que todas as regras começam com `.home`:

```css
.home ol {
  display: grid;                                              /* coloca os passos em grade */
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); /* quantas colunas couberem */
  gap: 12px;
  list-style: none;
  counter-reset: passo;                                       /* zera o contador */
}

.home li {
  counter-increment: passo;                                   /* soma 1 a cada <li> */
}

.home li::before {
  content: counter(passo);                                    /* escreve o número: 1, 2, 3... */
}
```

- Começar com `.home` faz a regra valer só dentro de `<section class="home">`. As listas dos outros CRUDs não mudam.
- `grid` + `auto-fit`: no computador ficam 3 por linha; no celular, 1 por linha. Não precisa de media query.
- `counter`: o próprio CSS numera os itens e mostra o número grande, como o preço numa etiqueta.

## Passo 5: testar

```bash
bin/rails server
```

Abra `http://localhost:3000`. A página inicial aparece com os 5 cadastros numerados. Clique em cada um para conferir os links.

---

## Atalho: usar o gerador do Rails

O Rails pode criar o controller e a view de uma vez:

```bash
bin/rails g controller Home index
```

Ele cria o controller, a view e uma rota `get "home/index"`, e também um helper e um teste. Depois disso, é só trocar a rota por `root "home#index"`.
Neste projeto os arquivos foram criados à mão para mostrar cada parte separada.

## Erros comuns

| Erro | Causa | Como arrumar |
|------|-------|--------------|
| `uninitialized constant HomeController` | Nome do arquivo ou da classe errado | Arquivo `home_controller.rb`, classe `HomeController` |
| `HomeController#index is missing a template` | View na pasta errada | A view tem que estar em `app/views/home/index.html.erb` |
| `undefined local variable or method 'categorys_path'` | Nome do helper errado | Veja os nomes certos com `bin/rails routes` |
| Continua aparecendo a página padrão do Rails | Faltou o `root` ou o servidor é antigo | Confira o `routes.rb` e reinicie o servidor |
