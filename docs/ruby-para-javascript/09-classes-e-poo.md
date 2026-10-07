# 09 — Classes e orientação a objetos

JavaScript é baseado em **protótipos** (a sintaxe `class` é açúcar sobre eles). Ruby é baseado em **classes** de verdade, com módulos para compartilhar comportamento.

## Declarando uma classe

```javascript
class Pessoa {
  constructor(nome, idade) {
    this.nome = nome;
    this.idade = idade;
  }

  apresentar() {
    return `Sou ${this.nome}, tenho ${this.idade} anos`;
  }
}

const ana = new Pessoa("Ana", 30);
ana.apresentar();
```

```ruby
class Pessoa
  def initialize(nome, idade)
    @nome = nome
    @idade = idade
  end

  def apresentar
    "Sou #{@nome}, tenho #{@idade} anos"
  end
end

ana = Pessoa.new("Ana", 30)
ana.apresentar
```

| JavaScript | Ruby |
|-----------|------|
| `constructor` | `initialize` |
| `new Pessoa()` | `Pessoa.new` (`new` é método da classe) |
| `this.nome` | `@nome` |
| `this` | `self` |
| `extends` | `<` |
| `super(...)` | `super(...)` |
| `static` | `def self.metodo` |
| `#privado` | `private` |
| `get nome() {}` | `attr_reader :nome` / `def nome` |
| `set nome(v) {}` | `attr_writer :nome` / `def nome=(v)` |
| `instanceof` | `is_a?` |
| `toString()` | `to_s` |

## Atributos: sem propriedades públicas

🔴 Em JS, `ana.nome` lê a propriedade diretamente. Em Ruby, as variáveis de instância (`@nome`) são **sempre privadas**; o acesso externo é por **métodos** (getters/setters).

```javascript
ana.nome = "Bia";     // propriedade pública por padrão
```

```ruby
class Pessoa
  attr_accessor :nome        # cria nome e nome=
  attr_reader   :idade       # só leitura
  attr_writer   :senha       # só escrita
end

ana.nome = "Bia"             # chama o método nome=
ana.nome                     # => "Bia"
ana.idade = 5                # erro: NoMethodError
```

`attr_accessor` equivale aos `get`/`set` do JS, em uma linha.

🔴 Dentro da classe, **ao atribuir** usando setter é preciso `self.`:

```ruby
def renomear(novo)
  nome = novo         # cria variável LOCAL (não altera o atributo!)
  self.nome = novo    # chama o setter (correto)
  @nome = novo        # atribuição direta (correto)
end
```

## `this` x `self`

🔴 `this` do JS muda conforme **como a função é chamada** (e perde o contexto em callbacks). Em Ruby, `self` é sempre o objeto dono do método em execução, e métodos não "perdem" o `self`:

```javascript
class Botao {
  constructor() { this.cliques = 0; }
  clicar() { this.cliques++; }
}
const b = new Botao();
const f = b.clicar;
f();                       // erro: this é undefined
setTimeout(b.clicar, 0);   // perde o this
```

```ruby
class Botao
  def initialize = @cliques = 0
  def clicar = @cliques += 1
end

b = Botao.new
f = b.method(:clicar)      # Method object: guarda o receptor
f.call                     # funciona
```

Não existe o problema de `.bind(this)` em Ruby.

## Herança

```javascript
class Animal {
  constructor(nome) { this.nome = nome; }
  falar() { return "..."; }
}
class Cachorro extends Animal {
  constructor(nome, raca) {
    super(nome);
    this.raca = raca;
  }
  falar() { return super.falar() + " Au!"; }
}
```

```ruby
class Animal
  attr_reader :nome

  def initialize(nome)
    @nome = nome
  end

  def falar = "..."
end

class Cachorro < Animal
  def initialize(nome, raca)
    super(nome)
    @raca = raca
  end

  def falar = super + " Au!"
end
```

- `super` sem parênteses repassa **todos** os argumentos recebidos; `super()` não passa nenhum.
- Herança **simples** nas duas linguagens.
- Em Ruby tudo herda de `Object` (que herda de `BasicObject`).

## Métodos de classe, constantes e variáveis de classe

```javascript
class Matematica {
  static PI = 3.14;
  static dobro(n) { return n * 2; }
}
Matematica.dobro(2);
```

```ruby
class Matematica
  PI = 3.14

  def self.dobro(n) = n * 2

  class << self                 # agrupa vários métodos de classe
    def triplo(n) = n * 3
  end
end

Matematica.dobro(2)
Matematica::PI
```

Contador de instâncias:

```ruby
class Pessoa
  @total = 0                   # variável de instância da classe

  class << self
    attr_accessor :total
  end

  def initialize
    self.class.total += 1
  end
end
```

(`@@variavel` existe, mas é compartilhada com subclasses; muitos a evitam.)

## Visibilidade

```javascript
class Conta {
  #saldo = 0;                  // campo privado
  #validar() {}                // método privado
  depositar(v) { this.#saldo += v; }
}
```

```ruby
class Conta
  def depositar(v)
    validar(v)
    @saldo = (@saldo || 0) + v
  end

  private

  def validar(v)               # tudo abaixo de private fica privado
    raise ArgumentError, "valor inválido" unless v.positive?
  end

  protected                    # acessível por outras instâncias da mesma classe

  def saldo = @saldo
end
```

| Nível | Quem chama |
|-------|-----------|
| `public` | Qualquer um (padrão) |
| `protected` | Instâncias da mesma classe (ou subclasses) |
| `private` | Só o próprio objeto, sem receptor explícito |

🔴 `private` em Ruby **não é inviolável**: `obj.send(:metodo_privado)` ainda funciona. É uma convenção de design.

🔴 Em JS, tudo é público por padrão; em Ruby, **atributos de instância são sempre privados** e métodos são públicos por padrão.

## Mixins: módulos (substituem herança múltipla)

JS usa composição por objetos ou *mixins* manuais. Ruby tem **módulos**:

```javascript
const Voador = Base => class extends Base { voar() { return "voando"; } };
class Passaro extends Voador(Animal) {}
```

```ruby
module Voador
  def voar = "#{nome} está voando"
end

class Passaro < Animal
  include Voador              # métodos viram de instância
end

Passaro.new("Piu").voar
```

| | O que faz |
|--|-----------|
| `include M` | Métodos de M viram métodos de **instância** |
| `extend M` | Métodos de M viram métodos de **classe** (ou do objeto) |
| `prepend M` | Como `include`, mas M vem **antes** da classe na busca |

Módulos prontos poderosos: `Comparable` (defina `<=>`) e `Enumerable` (defina `each`).

```ruby
class Pilha
  include Enumerable
  def initialize(*itens) = @itens = itens
  def each(&bloco) = @itens.each(&bloco)
end

Pilha.new(3, 1, 2).sort        # => [1, 2, 3]
Pilha.new(3, 1, 2).map { |x| x * 2 }
```

## Duck typing e `respond_to?`

Não há interfaces explícitas. Se o objeto responde ao método, serve:

```ruby
[Cachorro.new("Rex", "Lab"), Passaro.new("Piu")].each { |a| puts a.falar }
obj.respond_to?(:falar)
```

## Classes abertas (*monkey patching*)

Em Ruby, qualquer classe pode ser **reaberta**, inclusive as nativas (em JS seria alterar `Array.prototype`):

```javascript
String.prototype.vogais = function () { return this.match(/[aeiou]/gi)?.length ?? 0; };
```

```ruby
class String
  def vogais = count("aeiouAEIOU")
end

"programação".vogais   # => 4
```

Poderoso, mas use com cuidado. Alternativa mais segura: **refinements** (`refine String do ... end`).

## `toString` e igualdade

```javascript
class Ponto {
  constructor(x, y) { this.x = x; this.y = y; }
  toString() { return `(${this.x}, ${this.y})`; }
}
```

```ruby
class Ponto
  attr_reader :x, :y

  def initialize(x, y) = (@x, @y = x, y)

  def to_s = "(#{x}, #{y})"
  def inspect = "#<Ponto #{x},#{y}>"

  def ==(outro) = outro.is_a?(Ponto) && x == outro.x && y == outro.y
  alias_method :eql?, :==
  def hash = [x, y].hash
end

puts Ponto.new(1, 2)         # => (1, 2)
Ponto.new(1, 2) == Ponto.new(1, 2)   # => true
```

Em JS, `==`/`===` de objetos compara referência; em Ruby, você pode definir `==`.

## Introspecção

| JavaScript | Ruby |
|-----------|------|
| `obj.constructor.name` | `obj.class.name` |
| `Object.keys(obj)` | `obj.instance_variables` |
| `typeof obj.metodo === "function"` | `obj.respond_to?(:metodo)` |
| `Object.getPrototypeOf(obj)` | `obj.class.superclass` / `obj.class.ancestors` |
| `obj[metodo]()` | `obj.send(:metodo)` / `obj.public_send(:metodo)` |
| `Object.getOwnPropertyNames(proto)` | `Classe.instance_methods(false)` |

## Resumo

- `constructor` → `initialize`; `this.x` → `@x`; `extends` → `<`; `static` → `def self.`.
- Atributos de instância são **sempre privados**; exponha com `attr_reader/writer/accessor`.
- `self.` é obrigatório ao **atribuir** por setter dentro da classe.
- Herança simples + **módulos** (`include`, `extend`, `Comparable`, `Enumerable`).
- Visibilidade: `public` (padrão), `protected`, `private`; classes abertas permitem estender até as nativas.

## Exercícios

1. Traduza a classe JS `Carro` (com `constructor`, `acelerar()` e um getter `velocidade`) para Ruby.
2. Crie `Animal` e `Cachorro < Animal` com `super` em `initialize` e em `falar`.
3. Implemente um método de classe `Pessoa.criar_anonima`.
4. Demonstre o erro de esquecer `self.` ao atribuir via setter.
5. Faça uma classe `Temperatura` que inclui `Comparable` e compare duas instâncias.
6. Crie `Playlist` incluindo `Enumerable` e use `map` e `select`.
7. Reabra `Integer` para criar `dobro` e explique os riscos do monkey patching.
