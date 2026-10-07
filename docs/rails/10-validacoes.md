# 10 — Validações e callbacks

**Validações** são regras declaradas no model que impedem dados inválidos de serem gravados. Elas rodam em `save`, `create` e `update`.

## Exemplo básico

```ruby
class Tarefa < ApplicationRecord
  validates :titulo, presence: true
  validates :titulo, length: { minimum: 3, maximum: 100 }
end

t = Tarefa.new(titulo: "")
t.valid?                     # => false
t.save                       # => false (não grava)
t.errors.full_messages       # => ["Titulo não pode ficar em branco", ...]
t.errors[:titulo]            # => ["não pode ficar em branco", ...]
```

(As mensagens em português exigem o locale `pt-BR`, veja a seção de i18n.)

## Validadores prontos

### `presence` — obrigatório

```ruby
validates :nome, :email, presence: true
```

### `length`

```ruby
validates :senha, length: { minimum: 8 }
validates :sigla, length: { is: 2 }
validates :bio,   length: { maximum: 500 }
validates :nome,  length: { in: 3..50 }
```

### `numericality`

```ruby
validates :preco,   numericality: { greater_than: 0 }
validates :estoque, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
validates :nota,    numericality: { in: 0..10 }
```

### `uniqueness`

```ruby
validates :email, uniqueness: true
validates :email, uniqueness: { case_sensitive: false }
validates :sku,   uniqueness: { scope: :loja_id }     # único dentro da loja
```

Não substitui o **índice único** no banco: duas requisições simultâneas podem passar pela validação. Use os dois.

### `format`

```ruby
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :cep,   format: { with: /\A\d{5}-?\d{3}\z/, message: "inválido" }
```

Use `\A` e `\z` (início e fim da string), não `^` e `$`.

### `inclusion` / `exclusion`

```ruby
validates :status, inclusion: { in: %w[pendente pago enviado] }
validates :login,  exclusion: { in: %w[admin root] }
```

### `acceptance` e `confirmation`

```ruby
validates :termos, acceptance: true                 # checkbox "li e aceito"
validates :senha,  confirmation: true               # exige senha_confirmation igual
```

## Opções comuns

```ruby
validates :telefone, presence: true, if: :contato_por_telefone?
validates :cnpj, presence: true, unless: :pessoa_fisica?
validates :apelido, length: { maximum: 20 }, allow_blank: true   # só valida se preenchido
validates :bio, length: { maximum: 500 }, allow_nil: true
validates :titulo, presence: { message: "é obrigatório" }
validates :nome, presence: true, on: :create                      # só ao criar
```

`if:` e `unless:` aceitam símbolo (método), lambda ou proc.

## Validação personalizada

### Método

```ruby
class Tarefa < ApplicationRecord
  validate :prazo_nao_pode_ser_passado

  private

  def prazo_nao_pode_ser_passado
    return if prazo.blank?
    errors.add(:prazo, "não pode estar no passado") if prazo < Date.current
  end
end
```

### Validador reutilizável

```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.to_s.match?(URI::MailTo::EMAIL_REGEXP)
    record.errors.add(attribute, options[:message] || "não é um e-mail válido")
  end
end

class Usuario < ApplicationRecord
  validates :email, email: true
end
```

## Trabalhando com erros

```ruby
t = Tarefa.new
t.valid?
t.errors.any?                 # => true
t.errors.count
t.errors.full_messages        # frases completas
t.errors[:titulo]             # mensagens de um campo
t.errors.add(:base, "Erro geral")   # erro que não é de um campo
```

### `save` x `save!`

```ruby
t.save       # => true/false
t.save!      # levanta ActiveRecord::RecordInvalid
Tarefa.create(...)    # devolve o objeto (talvez inválido)
Tarefa.create!(...)   # levanta se inválido
```

No controller:

```ruby
def create
  @tarefa = Tarefa.new(tarefa_params)
  if @tarefa.save
    redirect_to @tarefa, notice: "Tarefa criada."
  else
    render :new, status: :unprocessable_entity   # reexibe o formulário com @tarefa.errors
  end
end
```

Na view, exiba `@tarefa.errors.full_messages` (veja o [doc 07](07-views-e-erb.md)). O `form_with` ainda marca os campos inválidos com a classe `field_with_errors`.

## Validação x restrição do banco

| | Validação no model | Restrição no banco |
|--|--------------------|--------------------|
| Onde | Ruby (antes de gravar) | Banco (`null: false`, `unique`, FK) |
| Mensagem amigável | Sim | Não (gera exceção) |
| Contorna com `update_column`/SQL | Sim | Não |
| Seguro sob concorrência | Não | Sim |

**Use as duas** para dados importantes: model para a experiência, banco para a garantia.

## Callbacks

Métodos executados automaticamente em momentos do ciclo de vida de um objeto.

```ruby
class Usuario < ApplicationRecord
  before_validation :normalizar_email
  before_save       :gerar_slug
  after_create      :enviar_boas_vindas
  after_commit      :atualizar_indice, on: :update

  private

  def normalizar_email
    self.email = email.to_s.strip.downcase
  end

  def gerar_slug
    self.slug = nome.parameterize
  end

  def enviar_boas_vindas
    UsuarioMailer.boas_vindas(self).deliver_later
  end
end
```

Ordem simplificada na criação: `before_validation` → validações → `before_save` → `before_create` → INSERT → `after_create` → `after_save` → `after_commit`.

Principais: `before_validation`, `after_validation`, `before_save`, `after_save`, `before_create`, `after_create`, `before_update`, `after_update`, `before_destroy`, `after_destroy`, `after_commit`.

**Cuidado:** callbacks escondem fluxo e dificultam testes. Use-os para coisas simples e internas ao model (normalizar dados, gerar valores). Para efeitos externos (e-mails, integrações) prefira jobs, e considere *service objects* para orquestração complexa.

## Mensagens em português (i18n)

```ruby
# config/application.rb
config.i18n.default_locale = :"pt-BR"
```

Adicione o arquivo `config/locales/pt-BR.yml` (a gem `rails-i18n` traz as traduções prontas):

```ruby
# Gemfile
gem "rails-i18n"
```

Nomes de atributos amigáveis:

```yaml
# config/locales/pt-BR.yml
pt-BR:
  activerecord:
    attributes:
      tarefa:
        titulo: "Título"
        prazo: "Prazo"
```

Resultado: `"Título não pode ficar em branco"`.

## Boas práticas

1. Valide no model; proteja também no banco (`null: false`, `unique`).
2. Mensagens claras, em português, para o usuário.
3. Regras específicas: validação personalizada isolada em método ou validador.
4. Callbacks apenas para tarefas simples; efeitos externos em jobs.
5. Após falha de validação, `render` com status 422.

## Resumo

- `validates` declara regras: `presence`, `length`, `numericality`, `uniqueness`, `format`, `inclusion`.
- `valid?`/`save` retornam booleano; `errors` guarda as mensagens; `save!` levanta exceção.
- Combine validação com restrições do banco.
- Callbacks (`before_save`, `after_create`...) automatizam passos do ciclo de vida, mas devem ser usados com moderação.

## Exercícios

1. No model `Produto`, exija `nome` (3 a 80 caracteres) e `preco` maior que zero.
2. Faça `estoque` aceitar só inteiros ≥ 0.
3. Torne o `email` de `Cliente` único (case-insensitive) e adicione o índice único via migration.
4. Escreva uma validação personalizada que recusa `prazo` no passado.
5. Use `before_validation` para remover espaços e converter o e-mail para minúsculas.
6. No console, tente salvar um objeto inválido e imprima `errors.full_messages`.
7. Configure o locale `pt-BR` e verifique as mensagens traduzidas.
