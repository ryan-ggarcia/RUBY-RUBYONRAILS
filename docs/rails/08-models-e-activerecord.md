# 08 — Models e ActiveRecord

O **model** representa um conceito do seu negócio (Tarefa, Produto, Usuário) e conversa com o banco através do **ActiveRecord**, o ORM do Rails.

> **ORM** (*Object-Relational Mapping*): mapeia **tabelas** para **classes**, **linhas** para **objetos** e **colunas** para **atributos**. Você escreve Ruby; o ActiveRecord gera o SQL.

| Banco de dados | Ruby |
|----------------|------|
| Tabela `tarefas` | Classe `Tarefa` |
| Linha | Objeto (instância) |
| Coluna `titulo` | Atributo `tarefa.titulo` |

## Criando um model

```bash
bin/rails generate model Tarefa titulo:string descricao:text concluida:boolean prazo:date
bin/rails db:migrate
```

Isso cria:

- `app/models/tarefa.rb`
- `db/migrate/2025..._create_tarefas.rb` (veja o [doc 09](09-migrations.md))

```ruby
# app/models/tarefa.rb
class Tarefa < ApplicationRecord
end
```

A classe está vazia, mas já sabe tudo sobre as colunas da tabela `tarefas`. É a convenção em ação.

## Tipos de coluna

| Tipo Rails | Ruby | Exemplos |
|------------|------|----------|
| `string` | String curta (255) | nome, e-mail |
| `text` | String longa | descrição, conteúdo |
| `integer` | Integer | quantidade |
| `bigint` | Integer grande | chaves estrangeiras |
| `float` | Float | medidas |
| `decimal` | BigDecimal | dinheiro (`precision: 10, scale: 2`) |
| `boolean` | true/false | concluída |
| `date` | Date | prazo |
| `datetime` | Time | publicado_em |
| `json`/`jsonb` | Hash | configurações |
| `references` | chave estrangeira | `autor:references` |

Para dinheiro, use `decimal` (ou guarde centavos em `integer`), nunca `float`.

## CRUD no console

```bash
bin/rails console
```

### Create

```ruby
t = Tarefa.new(titulo: "Estudar Rails", prazo: Date.today)
t.save                     # => true (grava) / false (falhou a validação)

Tarefa.create(titulo: "Ler")        # new + save numa linha
Tarefa.create!(titulo: nil)         # levanta erro se inválido
```

### Read

```ruby
Tarefa.all                          # todas (relation)
Tarefa.first                        # primeira por id
Tarefa.last
Tarefa.find(3)                      # por id; levanta RecordNotFound se não achar
Tarefa.find_by(titulo: "Ler")       # primeira que bate; nil se não achar
Tarefa.count                        # => 2
Tarefa.exists?(titulo: "Ler")       # => true
```

### Update

```ruby
t = Tarefa.find(1)
t.titulo = "Novo título"
t.save

t.update(titulo: "Outro", concluida: true)   # atribui e salva
t.update!(...)                               # versão que levanta erro
t.toggle!(:concluida)                        # inverte o booleano
Tarefa.where(concluida: false).update_all(concluida: true)   # em lote, sem validações
```

### Delete

```ruby
t.destroy                           # remove executando callbacks
Tarefa.destroy_by(concluida: true)
t.delete                            # remove direto no SQL, sem callbacks
Tarefa.delete_all
```

Prefira `destroy` (respeita callbacks e `dependent:`).

## Consultas

### `where`

```ruby
Tarefa.where(concluida: false)
Tarefa.where(titulo: "Ler", concluida: false)           # AND
Tarefa.where(prazo: Date.today..Date.today + 7)          # BETWEEN
Tarefa.where(id: [1, 2, 3])                              # IN
Tarefa.where.not(concluida: true)

# Com SQL parametrizado (SEMPRE use ? ou nomes, nunca interpolação)
Tarefa.where("titulo LIKE ?", "%rails%")
Tarefa.where("prazo < :hoje AND concluida = :c", hoje: Date.today, c: false)

# NUNCA faça: Tarefa.where("titulo = '#{params[:q]}'")   # SQL injection!
```

### Ordenação, limite, seleção

```ruby
Tarefa.order(:prazo)                     # ASC
Tarefa.order(prazo: :desc)
Tarefa.order(concluida: :asc, prazo: :asc)
Tarefa.limit(5)
Tarefa.offset(10).limit(10)              # paginação manual
Tarefa.select(:id, :titulo)              # só estas colunas
Tarefa.pluck(:titulo)                    # => ["Estudar", "Ler"] (array direto, sem objetos)
Tarefa.distinct.pluck(:categoria)
```

### Encadeamento

Cada método devolve uma **relation** (consulta ainda não executada, **preguiçosa**), então dá para encadear:

```ruby
Tarefa.where(concluida: false).where("prazo < ?", Date.today).order(:prazo).limit(10)
```

O SQL só roda quando você precisa dos dados (`each`, `to_a`, `first`, `count`, `inspect`...).

### Agregações

```ruby
Produto.count
Produto.sum(:preco)
Produto.average(:preco)
Produto.maximum(:preco)
Produto.minimum(:preco)
Produto.group(:categoria).count          # => { "A" => 3, "B" => 5 }
```

### `scope`: consultas com nome

```ruby
class Tarefa < ApplicationRecord
  scope :pendentes,  -> { where(concluida: false) }
  scope :atrasadas,  -> { pendentes.where("prazo < ?", Date.current) }
  scope :recentes,   -> { order(created_at: :desc) }
  scope :com_titulo, ->(termo) { where("titulo LIKE ?", "%#{termo}%") }
end

Tarefa.pendentes.recentes.limit(5)
Tarefa.com_titulo("rails")
```

## Atributos, estado e erros

```ruby
t = Tarefa.new(titulo: "X")
t.new_record?        # => true (ainda não salva)
t.persisted?         # => false
t.save
t.persisted?         # => true
t.id                 # => 1
t.created_at         # preenchido automaticamente
t.changed?           # tem alterações não salvas?
t.titulo_changed?
t.errors.full_messages   # após uma validação falhar
t.attributes         # => hash com todos os atributos
```

Também gera métodos para booleanos: `t.concluida?`.

## Métodos de instância e de classe próprios

```ruby
class Tarefa < ApplicationRecord
  def atrasada?
    !concluida? && prazo.present? && prazo < Date.current
  end

  def concluir!
    update!(concluida: true, concluida_em: Time.current)
  end

  def self.resumo
    { total: count, pendentes: pendentes.count }
  end
end

Tarefa.first.atrasada?
Tarefa.resumo
```

Coloque a lógica de negócio aqui, no model.

## Enum

Mapeia um inteiro/string a nomes legíveis:

```ruby
class Tarefa < ApplicationRecord
  enum :status, { pendente: 0, em_andamento: 1, concluida: 2 }
end

t = Tarefa.new(status: :em_andamento)
t.em_andamento?          # => true
t.concluida!             # atualiza e salva
Tarefa.pendente          # scope gerado automaticamente
Tarefa.statuses          # => { "pendente" => 0, ... }
```

(Sintaxe `enum status: {...}` em versões antigas.)

## Problema N+1 e `includes`

```ruby
# Ruim: 1 consulta + 1 por tarefa para buscar o autor (N+1)
Tarefa.all.each { |t| puts t.usuario.nome }

# Bom: 2 consultas no total
Tarefa.includes(:usuario).each { |t| puts t.usuario.nome }
```

Veja mais nas associações ([doc 11](11-associacoes.md)).

## Busca com SQL cru (quando necessário)

```ruby
Tarefa.find_by_sql("SELECT * FROM tarefas WHERE ...")
ActiveRecord::Base.connection.execute("...")
```

Use só quando o ActiveRecord não der conta.

## Seeds

```ruby
# db/seeds.rb
Tarefa.create!([
  { titulo: "Instalar Ruby",  prazo: Date.today },
  { titulo: "Criar projeto",  prazo: Date.today + 1 }
])
```

```bash
bin/rails db:seed
```

## Boas práticas

1. Regras de negócio e consultas no model (use `scope`).
2. Nunca interpole entradas do usuário em SQL.
3. Use `find_by`/`find` conscientemente (`nil` vs exceção).
4. Evite N+1 com `includes`.
5. Prefira `update`/`destroy` a `update_all`/`delete_all` quando validações/callbacks importam.

## Resumo

- Model = classe que mapeia uma tabela; ActiveRecord gera o SQL.
- CRUD: `create`, `find`/`where`, `update`, `destroy`.
- Consultas são *relations* encadeáveis e preguiçosas; `scope` dá nome a elas.
- Use consultas parametrizadas e `includes` para segurança e desempenho.

## Exercícios

1. Gere o model `Produto` (`nome:string preco:decimal estoque:integer`) e migre.
2. No console, crie 5 produtos e liste-os ordenados por preço decrescente.
3. Escreva `scope :disponiveis` (estoque > 0) e `scope :baratos` (preço < 100) e combine-os.
4. Calcule a soma do estoque e o preço médio.
5. Mostre por que `Produto.where("nome = '#{x}'")` é perigoso e corrija com `?`.
6. Crie o método `esgotado?` no model.
7. Transforme `status` em `enum` e liste os registros de um status.
