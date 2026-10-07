# 11 — Associações

**Associações** declaram como os models se relacionam, espelhando os relacionamentos entre tabelas. Com elas você navega entre objetos em Ruby (`autor.livros`) sem escrever JOINs.

## A chave estrangeira

Em um relacionamento um-para-muitos, a tabela do lado "muitos" guarda o `id` do lado "um" em uma **chave estrangeira** (`autor_id`).

```
autores              livros
id | nome            id | titulo   | autor_id
 1 | Machado          1 | Dom Casmurro | 1
 2 | Clarice          2 | Quincas Borba | 1
                      3 | A Hora da Estrela | 2
```

Convenção: a coluna se chama `<model_no_singular>_id`.

## `belongs_to` e `has_many` (um-para-muitos)

```bash
bin/rails g model Autor nome:string
bin/rails g model Livro titulo:string autor:references
bin/rails db:migrate
```

`autor:references` cria a coluna `autor_id`, o índice e a chave estrangeira.

```ruby
class Autor < ApplicationRecord
  has_many :livros
end

class Livro < ApplicationRecord
  belongs_to :autor
end
```

- **`belongs_to`** fica no model que **tem** a chave estrangeira (Livro).
- **`has_many`** fica no lado oposto (Autor).

Uso:

```ruby
machado = Autor.create(nome: "Machado de Assis")

machado.livros                                    # coleção (relation)
machado.livros.create(titulo: "Dom Casmurro")     # cria já associado
machado.livros << Livro.new(titulo: "Quincas Borba")
machado.livros.count
machado.livros.where("titulo LIKE ?", "%Dom%")

livro = Livro.first
livro.autor              # => #<Autor ...>
livro.autor.nome         # => "Machado de Assis"
livro.autor = outro_autor
livro.autor_id           # => id do autor
```

Desde o Rails 5, `belongs_to` é **obrigatório** por padrão: salvar um livro sem autor gera erro de validação ("Autor must exist"). Para torná-lo opcional: `belongs_to :autor, optional: true`.

## `dependent`: o que fazer ao remover o "pai"

```ruby
class Autor < ApplicationRecord
  has_many :livros, dependent: :destroy
end
```

| Opção | Efeito ao apagar o autor |
|-------|--------------------------|
| `:destroy` | Apaga cada livro (executa callbacks) |
| `:delete_all` | Apaga os livros com um único SQL (sem callbacks) |
| `:nullify` | Define `autor_id = NULL` nos livros (precisa permitir nulo) |
| `:restrict_with_error` | Impede a remoção e adiciona um erro |
| `:restrict_with_exception` | Impede a remoção levantando exceção |
| (nada) | Livros ficam "órfãos"; com chave estrangeira, o banco recusa a remoção |

## `has_one` (um-para-um)

```ruby
class Usuario < ApplicationRecord
  has_one :perfil, dependent: :destroy
end

class Perfil < ApplicationRecord
  belongs_to :usuario        # perfis.usuario_id
end

usuario.perfil
usuario.build_perfil(bio: "...")
usuario.create_perfil(bio: "...")
```

Regra: quem tem a chave estrangeira usa `belongs_to`; o outro lado, `has_one` ou `has_many`.

## `has_many :through` (muitos-para-muitos)

Alunos fazem muitos cursos; cursos têm muitos alunos. Usa-se uma **tabela intermediária** que também pode guardar dados próprios (nota, data).

```bash
bin/rails g model Aluno nome:string
bin/rails g model Curso titulo:string
bin/rails g model Matricula aluno:references curso:references nota:decimal
```

```ruby
class Aluno < ApplicationRecord
  has_many :matriculas, dependent: :destroy
  has_many :cursos, through: :matriculas
end

class Curso < ApplicationRecord
  has_many :matriculas, dependent: :destroy
  has_many :alunos, through: :matriculas
end

class Matricula < ApplicationRecord
  belongs_to :aluno
  belongs_to :curso
  validates :aluno_id, uniqueness: { scope: :curso_id }
end
```

```ruby
ana = Aluno.create(nome: "Ana")
ruby = Curso.create(titulo: "Ruby")

ana.cursos << ruby              # cria a Matricula automaticamente
ana.cursos                      # => [Ruby]
ruby.alunos                     # => [Ana]
ana.matriculas.first.nota
```

### `has_and_belongs_to_many` (HABTM)

Versão simples, sem model intermediário e sem dados extras (tabela `alunos_cursos` com só duas colunas). Para projetos reais, prefira `has_many :through`, que cresce melhor.

## Associações com nomes diferentes

Quando o nome da associação não coincide com o model:

```ruby
class Mensagem < ApplicationRecord
  belongs_to :remetente,    class_name: "Usuario"
  belongs_to :destinatario, class_name: "Usuario"
end
# colunas: remetente_id, destinatario_id
# migration: t.references :remetente, foreign_key: { to_table: :usuarios }
```

Auto-relacionamento:

```ruby
class Categoria < ApplicationRecord
  belongs_to :pai, class_name: "Categoria", optional: true
  has_many :filhas, class_name: "Categoria", foreign_key: :pai_id
end
```

## Associações polimórficas (visão geral)

Um model que pertence a **vários tipos** de models (um comentário em post **ou** em foto):

```ruby
class Comentario < ApplicationRecord
  belongs_to :comentavel, polymorphic: true    # comentavel_id + comentavel_type
end

class Post < ApplicationRecord
  has_many :comentarios, as: :comentavel
end
```

## Consultas com associações

### `joins` — filtrar pelo relacionado (INNER JOIN)

```ruby
Livro.joins(:autor).where(autores: { nome: "Machado de Assis" })
Autor.joins(:livros).distinct      # autores que têm livros
Autor.left_joins(:livros).where(livros: { id: nil })   # autores sem livros
```

### `includes` — evitar o N+1

```ruby
# N+1: uma consulta para livros + uma por livro para o autor
Livro.all.each { |l| puts l.autor.nome }

# Corrigido: carrega os autores de uma vez
Livro.includes(:autor).each { |l| puts l.autor.nome }
```

`includes` usa *eager loading*: carrega as associações antecipadamente. Use quando for **percorrer** o relacionamento. `joins` quando for **filtrar/ordenar** por ele (podem ser combinados).

### Contadores

```ruby
autor.livros.count          # SQL COUNT
autor.livros.size           # usa cache se já carregado
autor.livros.exists?
```

Para contadores muito usados, use *counter cache*: `belongs_to :autor, counter_cache: true` (com coluna `livros_count` em `autores`).

## Nas views e formulários

```erb
<h2><%= @autor.nome %></h2>
<ul>
  <% @autor.livros.each do |livro| %>
    <li><%= livro.titulo %></li>
  <% end %>
</ul>

<%# Formulário do livro com seleção de autor %>
<%= f.collection_select :autor_id, Autor.order(:nome), :id, :nome,
                        prompt: "Escolha um autor" %>
```

Lembre de permitir `:autor_id` nos strong parameters.

## Rotas e controllers aninhados (resumo)

```ruby
resources :autores do
  resources :livros, only: %i[index new create]
end
```

```ruby
class LivrosController < ApplicationController
  before_action :set_autor

  def create
    @livro = @autor.livros.build(livro_params)
    if @livro.save
      redirect_to @autor
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_autor
    @autor = Autor.find(params[:autor_id])
  end
end
```

## Resumo das associações

| Relação | Quem tem a FK | Declaração |
|---------|---------------|------------|
| Um-para-muitos | Lado "muitos" | `has_many` / `belongs_to` |
| Um-para-um | Lado "dependente" | `has_one` / `belongs_to` |
| Muitos-para-muitos | Tabela intermediária | `has_many :through` |

## Boas práticas

1. Sempre crie a chave estrangeira no banco (`references` ... `foreign_key: true`).
2. Defina `dependent:` conscientemente.
3. Prefira `has_many :through` a HABTM.
4. Evite N+1 com `includes`.
5. Mantenha as associações simétricas (declare os dois lados).

## Resumo

- `belongs_to` fica no model com a chave estrangeira; `has_many`/`has_one` no outro.
- `has_many :through` resolve muitos-para-muitos com uma tabela intermediária.
- `dependent:` define o destino dos filhos ao apagar o pai.
- `joins` filtra; `includes` evita o problema N+1.

## Exercícios

1. Modele `Autor` e `Livro` (um-para-muitos) com migration e models. Crie dados no console.
2. Faça com que apagar um autor apague seus livros e teste.
3. Modele `Aluno`, `Curso` e `Matricula` (com `nota`) usando `has_many :through`.
4. Liste os cursos de um aluno e os alunos de um curso.
5. Encontre os autores que não têm livros.
6. Percorra todos os livros mostrando o nome do autor e compare o log SQL com e sem `includes`.
7. Evite matrículas duplicadas (mesmo aluno e curso) com validação e índice único.
