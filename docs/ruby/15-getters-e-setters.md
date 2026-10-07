# 15 — Getters e setters (`attr_reader`, `attr_writer`, `attr_accessor`)

## O problema

As variáveis de instância (`@nome`) são **privadas**: de fora da classe você não consegue lê-las nem alterá-las.

```ruby
class Pessoa
  def initialize(nome)
    @nome = nome
  end
end

ana = Pessoa.new("Ana")
ana.nome            # erro: NoMethodError (undefined method 'nome')
```

Para expor os dados, você precisa de métodos:

- **Getter:** método que **lê** o valor.
- **Setter:** método que **altera** o valor (termina com `=`).

## Escrevendo à mão

```ruby
class Pessoa
  def initialize(nome)
    @nome = nome
  end

  def nome           # getter
    @nome
  end

  def nome=(valor)   # setter
    @nome = valor
  end
end

ana = Pessoa.new("Ana")
ana.nome            # => "Ana"
ana.nome = "Ana Maria"   # chama o método nome=
```

Escrever isso para todo atributo é repetitivo. Por isso Ruby oferece atalhos.

## Os três atalhos

| Método | Cria | Permite |
|--------|------|---------|
| `attr_reader :nome` | Getter `nome` | **Ler** |
| `attr_writer :nome` | Setter `nome=` | **Alterar** |
| `attr_accessor :nome` | Getter e setter | **Ler e alterar** |

```ruby
class Pessoa
  attr_reader   :cpf             # só leitura
  attr_writer   :senha           # só escrita
  attr_accessor :nome, :idade    # leitura e escrita

  def initialize(nome, idade, cpf, senha)
    @nome = nome
    @idade = idade
    @cpf = cpf
    @senha = senha
  end
end

p = Pessoa.new("Ana", 30, "123", "segredo")

p.nome              # => "Ana"
p.nome = "Bia"      # ok
p.cpf               # => "123"
p.cpf = "999"       # erro: NoMethodError (não há setter)
p.senha = "nova"    # ok
p.senha             # erro: NoMethodError (não há getter)
```

Os parâmetros são **symbols** (veja [05 — Symbols](05-symbols.md)). `attr_accessor :nome` define dois métodos para você: `nome` e `nome=`.

### Quando usar cada um

- `attr_reader`: o valor é definido no construtor e **não deve mudar** de fora (ex.: `id`, `cpf`, `criado_em`).
- `attr_writer`: raro; o valor pode ser definido mas não lido (ex.: senha).
- `attr_accessor`: o valor pode ser lido e alterado livremente.

Dica: comece com `attr_reader` e só use `attr_accessor` se realmente precisar alterar de fora. Quanto menos você expõe, melhor.

## Dentro da classe: `@nome` ou `nome`?

Dentro dos métodos, você pode usar a variável direto ou o getter:

```ruby
class Pessoa
  attr_reader :nome

  def initialize(nome)
    @nome = nome
  end

  def apresentar
    "Olá, sou #{nome}"      # usa o getter
    # "Olá, sou #{@nome}"   # equivalente
  end
end
```

Usar o getter facilita mudanças futuras (se `nome` passar a ser calculado, só um método muda).

## A armadilha do `self` com setters

Ao **atribuir** usando um setter dentro da própria classe, é obrigatório usar `self.`:

```ruby
class Pessoa
  attr_accessor :nome

  def renomear(novo)
    nome = novo          # cria uma VARIÁVEL LOCAL chamada nome! O atributo não muda.
    self.nome = novo     # chama o setter nome= (correto)
    @nome = novo         # altera a variável de instância diretamente (também correto)
  end
end
```

Sem `self.`, Ruby interpreta como criação de uma variável local. Para **ler**, `self.` não é necessário.

## Setters personalizados (validação)

Quando precisar de lógica, escreva o setter manualmente em vez de `attr_writer`:

```ruby
class Produto
  attr_reader :preco

  def initialize(preco)
    self.preco = preco       # reaproveita a validação
  end

  def preco=(valor)
    raise ArgumentError, "preço não pode ser negativo" if valor.negative?
    @preco = valor
  end
end

Produto.new(10)       # ok
Produto.new(-5)       # erro: ArgumentError (preço não pode ser negativo)
```

Note que `initialize` usa `self.preco = ...` para passar pela validação.

## Getters personalizados (valores calculados)

```ruby
class Retangulo
  attr_accessor :largura, :altura

  def initialize(largura, altura)
    @largura = largura
    @altura = altura
  end

  def area                 # atributo "derivado": não tem variável própria
    largura * altura
  end
end

r = Retangulo.new(3, 4)
r.area                     # => 12
r.largura = 5
r.area                     # => 20
```

## Valor padrão e leitura "preguiçosa"

```ruby
class Relatorio
  def itens
    @itens ||= []          # cria o array na primeira chamada
  end
end

Relatorio.new.itens << "a"
```

## Atributos privados

Se o atributo é só para uso interno, deixe privado:

```ruby
class Conta
  def initialize(saldo)
    @saldo = saldo
  end

  def mostrar = "Saldo: #{saldo}"

  private

  attr_reader :saldo       # getter privado: só dentro da classe
end

Conta.new(100).mostrar     # => "Saldo: 100"
Conta.new(100).saldo       # erro: NoMethodError (private method)
```

Também é possível escrever `private attr_reader :saldo` (Ruby 3+).

## Alternativas modernas: `Struct` e `Data`

Para classes que são **apenas dados**, há atalhos:

```ruby
Ponto = Struct.new(:x, :y)         # tem getters e setters
p = Ponto.new(1, 2)
p.x              # => 1
p.x = 10

Coordenada = Data.define(:lat, :lng)   # imutável (Ruby 3.2+)
c = Coordenada.new(lat: -23.5, lng: -46.6)
c.lat            # => -23.5
c.lat = 0        # erro: NoMethodError (Data é imutável)
```

## Resumo visual

```
attr_reader   :x   →  def x; @x; end
attr_writer   :x   →  def x=(v); @x = v; end
attr_accessor :x   →  os dois acima
```

## Boas práticas

1. Exponha o mínimo: comece com `attr_reader`.
2. Use `self.atributo = valor` ao atribuir dentro da classe.
3. Valide em setters personalizados quando a regra for importante.
4. Prefira métodos de comportamento (`depositar`) a expor um `saldo=` livre.
5. Atributos internos: `private attr_reader`.

## Resumo

- `attr_reader` cria o getter, `attr_writer` o setter, `attr_accessor` ambos.
- Setters terminam com `=`; ao usá-los dentro da classe, escreva `self.nome = ...`.
- Escreva getters/setters manualmente quando precisar de validação ou cálculo.

## Exercícios

1. Crie `Pessoa` com `nome` e `idade` (leitura e escrita) e `cpf` (somente leitura).
2. Tente alterar o `cpf` de fora e observe o erro.
3. Crie `Produto` com setter de `preco` que recusa valores negativos.
4. Crie `Retangulo` com `largura` e `altura` e um getter calculado `area`.
5. Demonstre o erro de esquecer o `self.` em um setter dentro de um método.
6. Transforme `Ponto` de uma classe comum para `Struct` e compare o código.
