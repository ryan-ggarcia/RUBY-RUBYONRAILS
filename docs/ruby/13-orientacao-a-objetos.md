# 13 — Orientação a objetos em Ruby

## O que é POO

**Programação Orientada a Objetos** organiza o código em **objetos**: elementos que reúnem **dados** (características) e **ações** (comportamentos).

Analogia: um **Carro**.

- Características (atributos): cor, modelo, velocidade atual.
- Comportamentos (métodos): acelerar, frear, buzinar.

Uma **classe** é o **molde** (a planta da casa); um **objeto** (instância) é a coisa criada a partir do molde (a casa construída).

```ruby
class Carro
end

fusca = Carro.new      # fusca é um objeto da classe Carro
gol   = Carro.new      # outro objeto, independente do primeiro
fusca.class            # => Carro
fusca.is_a?(Carro)     # => true
```

Em Ruby, **tudo é objeto**: números, strings, `nil`, até as próprias classes (`Carro.class # => Class`).

## Os quatro pilares da POO

1. **Abstração:** modelar só o que importa de uma coisa do mundo real.
2. **Encapsulamento:** esconder os detalhes internos e expor apenas uma interface.
3. **Herança:** uma classe reaproveita o que outra já define.
4. **Polimorfismo:** objetos diferentes respondem à mesma mensagem de formas diferentes.

## Uma classe completa

```ruby
class Carro
  attr_reader :modelo, :velocidade

  def initialize(modelo)
    @modelo = modelo
    @velocidade = 0
  end

  def acelerar(quanto = 10)
    @velocidade += quanto
    self
  end

  def to_s
    "#{@modelo} a #{@velocidade} km/h"
  end
end

c = Carro.new("Fusca")
c.acelerar.acelerar(20)
puts c            # => Fusca a 30 km/h
```

Detalhes de `initialize`, variáveis de instância e métodos estão no [doc 14](14-atributos-e-metodos.md); getters e setters no [doc 15](15-getters-e-setters.md).

## Encapsulamento: `public`, `private`, `protected`

Controla **quem pode chamar** cada método.

```ruby
class ContaBancaria
  def initialize(saldo)
    @saldo = saldo
  end

  def mostrar_saldo          # público (padrão)
    "Saldo: #{formatar(@saldo)}"
  end

  def maior_que?(outra)      # usa protected
    saldo > outra.saldo
  end

  protected

  def saldo                  # só objetos da mesma classe podem chamar
    @saldo
  end

  private

  def formatar(valor)        # só pode ser chamado dentro da própria classe
    "R$ #{'%.2f' % valor}"
  end
end

conta = ContaBancaria.new(1000)
conta.mostrar_saldo          # => "Saldo: R$ 1000.00"
conta.formatar(10)           # erro: NoMethodError (private method)
conta.saldo                  # erro: NoMethodError (protected method)
```

| Nível | Quem pode chamar |
|-------|------------------|
| `public` | Qualquer um (padrão) |
| `protected` | A própria classe e subclasses, **e outros objetos** da mesma classe |
| `private` | Apenas o próprio objeto, sem receptor explícito (`formatar(x)`) |

Observações:

- `private` não é "segurança": é um contrato de design. Com `send` ainda dá para chamar (`conta.send(:formatar, 10)`).
- Também funciona com símbolos: `private :formatar`, ou `private def formatar...`.
- Variáveis de instância (`@saldo`) **sempre** são privadas ao objeto; para acessar de fora, use `attr_*` ou métodos.

## Herança

Uma classe filha herda atributos e métodos da classe pai com `<`.

```ruby
class Veiculo
  attr_reader :velocidade

  def initialize
    @velocidade = 0
  end

  def acelerar
    @velocidade += 10
  end
end

class Carro < Veiculo     # Carro herda de Veiculo
end

class Moto < Veiculo
  def acelerar            # sobrescreve (override)
    @velocidade += 20
  end
end

Carro.new.acelerar        # => 10
Moto.new.acelerar         # => 20
```

### `super`

Chama o método de mesmo nome da classe pai:

```ruby
class Animal
  def initialize(nome)
    @nome = nome
  end

  def apresentar
    "Sou #{@nome}"
  end
end

class Cachorro < Animal
  def initialize(nome, raca)
    super(nome)            # chama Animal#initialize
    @raca = raca
  end

  def apresentar
    super + " e sou da raça #{@raca}"
  end
end

Cachorro.new("Rex", "Labrador").apresentar
# => "Sou Rex e sou da raça Labrador"
```

`super` sem parênteses repassa **todos** os argumentos recebidos; `super()` não repassa nenhum.

### Consultando a hierarquia

```ruby
Cachorro.superclass       # => Animal
Cachorro.ancestors        # => [Cachorro, Animal, Object, Kernel, BasicObject]
rex = Cachorro.new("Rex", "Lab")
rex.is_a?(Animal)         # => true
rex.instance_of?(Animal)  # => false (é instância exata de Cachorro)
```

Ruby tem **herança simples**: uma classe só pode ter uma superclasse. Para compartilhar comportamento entre classes sem relação, use **módulos**.

## Polimorfismo e duck typing

Objetos diferentes respondem ao mesmo método. Em Ruby, o que importa é **se o objeto sabe responder**, não de qual classe ele é ("se anda como pato e grasna como pato...").

```ruby
class Cachorro
  def emitir_som = "Au au!"
end

class Gato
  def emitir_som = "Miau!"
end

class Robo
  def emitir_som = "Bip bop"
end

[Cachorro.new, Gato.new, Robo.new].each { |s| puts s.emitir_som }
```

Nenhuma herança foi necessária. Para checar capacidade: `objeto.respond_to?(:emitir_som)`.

## Módulos e mixins

Um **módulo** é um conjunto de métodos que não pode ser instanciado, mas pode ser **misturado** (`include`) em classes.

```ruby
module Flutuante
  def flutuar
    "Estou flutuando!"
  end
end

class Barco
  include Flutuante
end

class Pato
  include Flutuante
end

Barco.new.flutuar    # => "Estou flutuando!"
Pato.new.flutuar     # => "Estou flutuando!"
```

| Forma | O que faz |
|-------|-----------|
| `include Modulo` | Métodos viram métodos de **instância** |
| `extend Modulo` | Métodos viram métodos de **classe** (ou de um objeto específico) |
| `prepend Modulo` | O módulo é consultado **antes** da classe (útil para "envolver" métodos) |

### Módulos prontos importantes

```ruby
class Versao
  include Comparable           # exige definir <=>
  attr_reader :numero

  def initialize(numero) = @numero = numero
  def <=>(outra) = numero <=> outra.numero
end

Versao.new(2) > Versao.new(1)           # => true
Versao.new(3).between?(Versao.new(1), Versao.new(5))   # => true
```

```ruby
class Playlist
  include Enumerable           # exige definir each

  def initialize(*musicas) = @musicas = musicas
  def each(&bloco) = @musicas.each(&bloco)
end

p = Playlist.new("a", "bb", "ccc")
p.map(&:length)       # => [1, 2, 3]
p.select { |m| m.size > 1 }
p.sort_by(&:size)
```

Com `Enumerable`, sua classe ganha `map`, `select`, `sort_by`, `reduce` e dezenas de métodos de graça.

### Módulos como namespace

```ruby
module Loja
  class Produto; end
  class Cliente; end
end

Loja::Produto.new
```

É assim que o Rails organiza código (`Admin::UsuariosController`).

## Composição vs. herança

Regra prática: use herança para **"é um"** (Cachorro **é um** Animal) e composição para **"tem um"** (Carro **tem um** Motor).

```ruby
class Motor
  def ligar = "vrum"
end

class Carro
  def initialize
    @motor = Motor.new     # composição
  end

  def ligar = @motor.ligar
end
```

Prefira composição quando a relação não for claramente "é um"; hierarquias profundas ficam difíceis de manter.

## Métodos úteis para inspecionar objetos

```ruby
obj.class                  # a classe
obj.is_a?(Classe)          # instância da classe ou de subclasse?
obj.respond_to?(:metodo)   # sabe responder a este método?
obj.methods - Object.instance_methods   # métodos próprios
obj.instance_variables     # => [:@modelo, :@velocidade]
obj.inspect                # representação técnica
obj.to_s                   # representação "amigável"
```

## Classes abertas

Em Ruby, classes podem ser **reabertas** a qualquer momento, inclusive as nativas:

```ruby
class String
  def vogais
    count("aeiouáéíóúãõâêô")
  end
end

"programação".vogais       # => 4
```

É poderoso, mas pode causar conflitos. Use com moderação (o Rails faz uso disso em extensões como `5.days.ago`).

## Resumo

- **Classe** é o molde; **objeto** é a instância.
- **Encapsulamento:** `public`, `protected`, `private`.
- **Herança** com `<` e `super`; só uma superclasse.
- **Módulos/mixins** compartilham comportamento sem herança (`include`, `extend`).
- **Duck typing:** o que importa é o que o objeto sabe fazer.
- Prefira composição quando a relação não for "é um".

## Exercícios

1. Crie `Animal` com `nome` e `emitir_som`; crie `Cachorro` e `Gato` sobrescrevendo `emitir_som`.
2. Crie `Funcionario` com `salario` e `calcular_bonus` (10%); crie `Gerente` com bônus de 20% usando herança.
3. Crie um módulo `Voador` com `voar` e inclua em `Passaro` e `Aviao`.
4. Faça uma classe `ContaBancaria` com método privado `validar_valor` usado em `depositar` e `sacar`.
5. Crie uma classe `Temperatura` que inclua `Comparable` e compare duas temperaturas.
6. Crie uma coleção `Turma` que inclua `Enumerable` e liste os alunos aprovados com `select`.
