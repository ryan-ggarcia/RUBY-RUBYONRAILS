# 06 — Controllers

O controller recebe a requisição já roteada, usa os models e decide a resposta. Cada **action** é um método público da classe.

## Estrutura

```ruby
# app/controllers/tarefas_controller.rb
class TarefasController < ApplicationController
  def index
    @tarefas = Tarefa.all           # disponível na view como @tarefas
  end

  def show
    @tarefa = Tarefa.find(params[:id])
  end
end
```

- Herda de `ApplicationController` (que herda de `ActionController::Base`).
- Nome: plural + `Controller` (`TarefasController`), arquivo em snake_case.
- Ao terminar a action sem `render`/`redirect_to`, o Rails renderiza `app/views/tarefas/<action>.html.erb`.

Gerar:

```bash
bin/rails generate controller Tarefas index show
```

## `params`

`params` é um hash (`ActionController::Parameters`) com tudo que veio na requisição: parâmetros da URL, da query string e do corpo do formulário.

```ruby
# GET /tarefas/5?formato=resumo
params[:id]         # => "5"       (da rota)
params[:formato]    # => "resumo"  (da query string)

# POST de um formulário
params[:tarefa]            # => { "titulo" => "Estudar", "descricao" => "..." }
params[:tarefa][:titulo]   # => "Estudar"
```

Tudo é String; converta quando precisar (`params[:pagina].to_i`).

## Strong parameters (segurança)

Nunca passe `params` direto para o model: um usuário malicioso poderia enviar campos extras (`admin=true`). O Rails exige que você **liste os campos permitidos**:

```ruby
class TarefasController < ApplicationController
  def create
    @tarefa = Tarefa.new(tarefa_params)
    # ...
  end

  private

  def tarefa_params
    params.require(:tarefa).permit(:titulo, :descricao, :concluida)
  end
end
```

- `require(:tarefa)`: exige a chave `tarefa` (erro 400 se faltar).
- `permit(...)`: só esses campos passam; os demais são descartados.
- Arrays: `permit(tag_ids: [])`. Hashes aninhados: `permit(endereco: [:rua, :cidade])`.

Se você tentar `Tarefa.new(params[:tarefa])`, obterá `ActiveModel::ForbiddenAttributesError`.

(No Rails 8 também existe `params.expect(tarefa: [:titulo, :descricao])`.)

## Respostas: `render` e `redirect_to`

### `render` — gera a página agora

```ruby
render :new                          # renderiza a view new (sem executar a action new)
render :edit, status: :unprocessable_entity
render plain: "Olá"
render json: @tarefa
render json: { erro: "não encontrado" }, status: :not_found
```

### `redirect_to` — manda o navegador para outra URL

```ruby
redirect_to tarefas_path
redirect_to @tarefa                       # → /tarefas/5
redirect_to @tarefa, notice: "Criada!"    # com mensagem flash
redirect_to root_path, status: :see_other # recomendado após DELETE
```

### Qual usar?

| Situação | Use |
|----------|-----|
| Sucesso ao salvar | `redirect_to` (evita reenvio do formulário ao atualizar a página — padrão **PRG**: Post/Redirect/Get) |
| Falha na validação | `render :new` ou `:edit` com `status: :unprocessable_entity` (mantém os dados digitados e os erros) |
| Resposta JSON/API | `render json:` |

**Importante:** `render` e `redirect_to` só podem ser chamados **uma vez** por requisição (`DoubleRenderError`). `redirect_to` não interrompe a action; use `return` se houver código depois.

## Flash: mensagens entre requisições

```ruby
redirect_to tarefas_path, notice: "Tarefa criada."   # flash[:notice]
redirect_to tarefas_path, alert: "Algo deu errado."  # flash[:alert]
flash[:sucesso] = "Salvo"                            # chave customizada
flash.now[:alert] = "Corrija os erros"               # só nesta requisição (para render)
```

Na view (geralmente no layout):

```erb
<% if notice %><p class="aviso"><%= notice %></p><% end %>
<% if alert %><p class="erro"><%= alert %></p><% end %>
```

## Filtros (`before_action`)

Código que roda **antes** (ou depois) das actions, para evitar repetição:

```ruby
class TarefasController < ApplicationController
  before_action :set_tarefa, only: %i[show edit update destroy]
  before_action :autenticar!, except: %i[index show]

  def show; end     # @tarefa já foi carregada

  private

  def set_tarefa
    @tarefa = Tarefa.find(params[:id])
  end
end
```

Se um filtro chamar `redirect_to` ou `render`, a action **não** é executada (útil para autenticação).

Tipos: `before_action`, `after_action`, `around_action`. Opções: `only:`, `except:`.

## Sessão e cookies

```ruby
session[:usuario_id] = usuario.id     # guardado de forma assinada no cookie
session[:usuario_id]                  # lê
session.delete(:usuario_id)           # remove (logout)
cookies[:tema] = "escuro"
```

Não guarde dados grandes ou sensíveis na sessão; guarde apenas identificadores.

## Formatos de resposta

```ruby
def show
  @tarefa = Tarefa.find(params[:id])
  respond_to do |format|
    format.html                            # show.html.erb
    format.json { render json: @tarefa }
  end
end
```

## Tratando registro não encontrado

`Tarefa.find(999)` levanta `ActiveRecord::RecordNotFound`; o Rails responde **404** automaticamente em produção. Para tratar:

```ruby
rescue_from ActiveRecord::RecordNotFound do
  redirect_to tarefas_path, alert: "Tarefa não encontrada."
end
```

## Métodos privados

Tudo abaixo de `private` não é action (não é roteável). Coloque lá os métodos auxiliares (`set_tarefa`, `tarefa_params`).

## ApplicationController

Código compartilhado por todos os controllers:

```ruby
class ApplicationController < ActionController::Base
  helper_method :usuario_atual

  def usuario_atual
    @usuario_atual ||= Usuario.find_by(id: session[:usuario_id])
  end
end
```

`helper_method` torna o método disponível também nas views.

## Boas práticas

1. **Controller magro:** receba, delegue ao model, responda.
2. Use strong parameters sempre.
3. Extraia a busca repetida em `before_action`.
4. Redirecione após sucesso; renderize após falha.
5. Mantenha as 7 ações RESTful; novos comportamentos viram novos controllers.

## Resumo

- Action = método público; sem `render`/`redirect_to` ela renderiza a view de mesmo nome.
- `params` traz URL, query e formulário; use **strong parameters** (`require` + `permit`).
- `redirect_to` após sucesso, `render` após falha; flash para mensagens.
- `before_action` evita repetição (carregar registro, autenticar).

## Exercícios

1. Crie `ProdutosController` com `index` e `show` usando `Produto.all` e `Produto.find`.
2. Escreva `produto_params` permitindo `nome`, `preco` e `estoque`.
3. Extraia `Produto.find(params[:id])` para um `before_action :set_produto`.
4. Explique a diferença entre `render :new` e `redirect_to new_produto_path`.
5. Adicione `rescue_from` para redirecionar com alerta quando o produto não existir.
6. Faça `show` responder em HTML e JSON.
