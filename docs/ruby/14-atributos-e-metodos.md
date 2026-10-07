# 14 — Atributos e métodos

## `initialize`: o construtor

`initialize` é um método especial executado **automaticamente** sempre que você chama `.new`. Ele prepara o estado inicial do objeto.

```ruby
class Pessoa
  def initialize(nome, idade)
    @nome = nome
    @idade = idade
  end
end

ana = Pessoa.new("Ana", 30)   # chama initialize("Ana", 30)
```

Não se chama `initialize` diretamente. Ele é sempre **privado**.

## Variáveis de instância (`@`)

Atributos de um objeto são guardados em **variáveis de instância**, que começam com `@`.

- Pertencem a **um objeto específico**.
- Existem enquanto o objeto existir.
- São acessíveis em todos os métodos de instância daquele objeto.
- Não inicializadas valem `nil`.

```ruby
class Contador
  def initialize
    @valor = 0
  end

  def incrementar
    @valor += 1
  end

  def valor
    @valor
  end
end

c1 = Contador.new
c2 = Contador.new
c1.incrementar
c1.incrementar
c2.incrementar

c1.valor   # => 2
c2.valor   # => 1   (cada objeto tem o seu)
```

De fora da classe você **não acessa** `@valor` diretamente; use métodos (ou `attr_*`, veja o [doc 15](15-getters-e-setters.md)).

```ruby
c1.@valor   # erro de sintaxe
c1.instance_variable_get(:@valor)   # funciona, mas evite (quebra encapsulamento)
```

## Métodos de instância

São as **ações** que o objeto sabe fazer. Definidos com `def` dentro da classe e chamados no objeto.

```ruby
class Carro
  def initialize(modelo)
    @modelo = modelo
    @velocidade = 0
  end

  def acelerar(quanto = 10)
    @velocidade += quanto
  end

  def parado?
    @velocidade.zero?
  end

  def buzinar
    "Fom fom! Sou um #{@modelo}!"
  end
end

fusca = Carro.new("Fusca")
fusca.parado?       # => true
fusca.acelerar      # => 10
fusca.acelerar(30)  # => 40
fusca.buzinar       # => "Fom fom! Sou um Fusca!"
```

### Retorno implícito

O método devolve o valor da **última expressão avaliada**. `return` só é necessário para sair mais cedo.

```ruby
def dobro(n)
  n * 2          # devolvido automaticamente
end

def classificar(idade)
  return "criança" if idade < 12
  return "adolescente" if idade < 18
  "adulto"
end
```

### Convenções de nome

| Sufixo | Significado | Exemplos |
|--------|-------------|----------|
| `?` | Retorna booleano (pergunta) | `vazio?`, `ativo?` |
| `!` | Versão "perigosa" (altera o objeto ou levanta erro) | `sort!`, `save!` |
| `=` | Setter (atribuição) | `nome=` |

## Parâmetros de métodos

```ruby
# Obrigatórios
def somar(a, b) = a + b

# Valor padrão
def saudar(nome = "visitante") = "Olá, #{nome}!"

# Argumentos nomeados (keyword arguments)
def criar(nome:, idade: 18)
  "#{nome}, #{idade}"
end
criar(nome: "Ana")
criar(idade: 20, nome: "Bia")      # ordem livre

# Quantidade variável (splat)
def soma(*numeros) = numeros.sum
soma(1, 2, 3)                      # => 6

# Hash de opções
def config(**opcoes) = opcoes
config(cor: "azul", tamanho: 3)    # => { cor: "azul", tamanho: 3 }

# Bloco
def repetir(n)
  n.times { |i| yield i }
end
repetir(3) { |i| puts "volta #{i}" }
```

Ruby é **rígido com a quantidade** de argumentos: passar a mais ou a menos gera `ArgumentError`.

Prefira **argumentos nomeados** quando houver mais de dois parâmetros: o código fica autoexplicativo.

## Métodos de classe

Pertencem à **classe**, não aos objetos. São chamados direto na classe, sem `.new`.

```ruby
class Calculadora
  def self.somar(a, b)
    a + b
  end
end

Calculadora.somar(2, 3)    # => 5
```

Outra forma de escrever vários:

```ruby
class Calculadora
  class << self
    def somar(a, b) = a + b
    def subtrair(a, b) = a - b
  end
end
```

Usos comuns: **fábricas** e utilitários.

```ruby
class Pessoa
  attr_reader :nome

  def initialize(nome) = @nome = nome

  def self.anonima
    new("Anônimo")       # dentro de um método de classe, `new` é Pessoa.new
  end
end

Pessoa.anonima.nome      # => "Anônimo"
```

## Variáveis de classe e constantes

### `@@variavel` (variável de classe)

Compartilhada entre a classe **e todas as suas subclasses**.

```ruby
class Contador
  @@total = 0

  def initialize
    @@total += 1
  end

  def self.total = @@total
end

Contador.new
Contador.new
Contador.total      # => 2
```

Cuidado: variáveis de classe `@@` são compartilhadas com subclasses, o que causa efeitos inesperados. Muitos preferem uma **variável de instância de classe**:

```ruby
class Contador
  @total = 0                       # pertence ao objeto Contador (a classe)

  class << self
    attr_accessor :total
  end

  def initialize
    self.class.total += 1
  end
end
```

### Constantes

```ruby
class Pedido
  STATUS = %i[pendente pago enviado].freeze
  TAXA = 0.05
end

Pedido::STATUS        # => [:pendente, :pago, :enviado]
```

## O papel do `self`

`self` é "o objeto atual". Seu significado muda conforme o contexto:

```ruby
class Exemplo
  puts self             # => Exemplo (aqui self é a classe)

  def instancia
    self                # => o objeto que recebeu a chamada
  end

  def self.da_classe
    self                # => Exemplo
  end
end
```

Retornar `self` permite encadear chamadas (**interface fluente**):

```ruby
class Builder
  def initialize = @partes = []

  def adicionar(parte)
    @partes << parte
    self
  end

  def to_s = @partes.join(" ")
end

Builder.new.adicionar("a").adicionar("b").to_s   # => "a b"
```

## `to_s`, `inspect` e `==`

```ruby
class Produto
  attr_reader :nome, :preco

  def initialize(nome, preco)
    @nome = nome
    @preco = preco
  end

  def to_s
    "#{nome} (R$ #{preco})"        # usado por puts e interpolação
  end

  def ==(outro)
    outro.is_a?(Produto) && nome == outro.nome && preco == outro.preco
  end
end

p1 = Produto.new("Café", 5)
puts p1                            # => Café (R$ 5)
puts "Item: #{p1}"                 # => Item: Café (R$ 5)
p1 == Produto.new("Café", 5)       # => true
```

Sem `to_s`, `puts p1` mostra algo como `#<Produto:0x000...>`.

## Visibilidade de métodos

```ruby
class Exemplo
  def publico; end

  private

  def interno; end       # tudo abaixo de `private` fica privado

  public

  def outro_publico; end
end
```

Detalhes no [doc 13](13-orientacao-a-objetos.md).

## Boas práticas

1. Mantenha os métodos **curtos** e com uma única responsabilidade.
2. Inicialize **todas** as variáveis de instância no `initialize`.
3. Prefira argumentos nomeados quando houver vários parâmetros.
4. Nomeie métodos booleanos com `?`.
5. Evite expor mais do que o necessário (`private` por padrão).

## Resumo

- `initialize` prepara o objeto; `@variavel` guarda seu estado.
- Métodos de instância (`def nome`) agem sobre um objeto; de classe (`def self.nome`) agem sobre a classe.
- O retorno é a última expressão avaliada.
- `?` para perguntas, `!` para versões perigosas, `=` para setters.
- Implemente `to_s` para dar uma boa representação textual.

## Exercícios

1. Crie `Produto` com `nome` e `preco` e um método `aplicar_desconto(percentual)`.
2. Crie `Contador` que conta quantos objetos já foram criados (variável de classe ou de instância de classe).
3. Crie a classe `Retangulo(largura, altura)` com `area`, `perimetro` e `quadrado?`.
4. Faça `Pessoa` com método de classe `self.de_hash(hash)` que cria uma pessoa a partir de um Hash.
5. Implemente `to_s` e `==` em uma classe `Ponto` com `x` e `y`.
6. Crie um método com argumentos nomeados `enviar(para:, assunto:, urgente: false)`.
