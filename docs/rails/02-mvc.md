# 02 — MVC e o caminho de uma requisição

## O que é MVC

**MVC** (Model–View–Controller) divide a aplicação em três responsabilidades:

| Camada | Responsabilidade | No Rails |
|--------|------------------|----------|
| **Model** | Dados e regras de negócio; conversa com o banco | `app/models/` (ActiveRecord) |
| **View** | O que o usuário vê (HTML, JSON...) | `app/views/` (ERB) |
| **Controller** | Recebe a requisição, coordena model e view | `app/controllers/` |

Analogia (restaurante): o **cliente** faz o pedido; o **garçom** (controller) leva à **cozinha** (model, que sabe preparar e guardar os ingredientes) e traz o **prato montado** (view) para a mesa.

## O ciclo de uma requisição

Quando o navegador acessa `GET /tarefas/5`:

```
Navegador
   │  GET /tarefas/5
   ▼
Servidor (Puma)
   ▼
Router (config/routes.rb)      → "isso vai para TarefasController#show, params[:id] = 5"
   ▼
Controller (TarefasController#show)
   │  @tarefa = Tarefa.find(5)
   ▼
Model (Tarefa)  ⇄  Banco de dados (SELECT * FROM tarefas WHERE id = 5)
   ▼
View (app/views/tarefas/show.html.erb)  → monta o HTML usando @tarefa
   ▼
Resposta HTTP (HTML) → Navegador
```

Passo a passo:

1. **Router:** lê o verbo e a URL e decide qual controller e action executar.
2. **Controller:** busca/modifica dados usando models e prepara variáveis de instância (`@tarefa`).
3. **Model:** consulta ou grava no banco e aplica validações.
4. **View:** recebe as variáveis `@...` do controller e gera o HTML.
5. A resposta volta ao navegador.

## Exemplo mínimo das três peças

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get "/tarefas/:id", to: "tarefas#show"
end
```

```ruby
# app/controllers/tarefas_controller.rb
class TarefasController < ApplicationController
  def show
    @tarefa = Tarefa.find(params[:id])
  end
end
```

```ruby
# app/models/tarefa.rb
class Tarefa < ApplicationRecord
end
```

```erb
<%# app/views/tarefas/show.html.erb %>
<h1><%= @tarefa.titulo %></h1>
<p><%= @tarefa.descricao %></p>
```

Ao final da action, o Rails **renderiza automaticamente** a view com o mesmo nome (`tarefas/show`). As variáveis de instância do controller ficam disponíveis na view.

## O que vai em cada camada

### Model — "fat model, skinny controller"

Regras de negócio e consultas devem ficar no model, não no controller.

```ruby
# Ruim: lógica no controller
def index
  @tarefas = Tarefa.where(concluida: false).order(:prazo)
end

# Melhor: nomear a consulta no model
class Tarefa < ApplicationRecord
  scope :pendentes, -> { where(concluida: false).order(:prazo) }
end

def index
  @tarefas = Tarefa.pendentes
end
```

(Em sistemas grandes, "fat model" também vira problema e se extrai lógica para *service objects*; para começar, a regra serve bem.)

### Controller — coordenar, não decidir

Recebe parâmetros, chama o model, escolhe a resposta (renderizar, redirecionar). Evite regras de negócio e HTML aqui.

### View — apresentar, não calcular

Mostra os dados. Evite consultas ao banco e lógica complexa em views; use *helpers* ou métodos do model.

## Por que separar?

- **Manutenção:** mudar o visual não mexe nas regras.
- **Reuso:** o mesmo model serve para a web, uma API e tarefas em segundo plano.
- **Testes:** cada camada é testada isoladamente.
- **Trabalho em equipe:** designers e programadores atuam em camadas diferentes.

## Outras camadas que você vai encontrar

| Componente | Função |
|-----------|--------|
| Router | Mapeia URL → controller#action |
| Helpers | Métodos auxiliares para as views |
| Mailers | E-mails |
| Jobs | Tarefas em segundo plano |
| Concerns | Módulos para compartilhar código entre models/controllers |

## Resumo

- MVC: **Model** (dados e regras), **View** (apresentação), **Controller** (coordenação).
- A requisição passa por **router → controller → model → view**.
- Variáveis `@` do controller ficam disponíveis na view.
- Regra prática: lógica de negócio no model, controller enxuto, view sem consultas.

## Exercícios

1. Desenhe o caminho de `GET /produtos` até a resposta, nomeando cada componente.
2. Classifique em Model, View ou Controller: (a) validar que o e-mail é único; (b) exibir a lista em uma tabela HTML; (c) redirecionar após salvar; (d) buscar produtos com estoque.
3. Mova a consulta `Produto.where("estoque > 0")` do controller para um `scope` no model.
4. O que acontece se uma action não chamar `render` explicitamente?
5. Por que consultar o banco dentro de uma view é considerado má prática?
