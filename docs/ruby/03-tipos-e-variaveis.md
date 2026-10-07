# 03 — Tipos e variáveis (tipagem dinâmica)

## Tipagem dinâmica

Em Ruby você **não declara o tipo** de uma variável. O tipo pertence ao **valor** e é descoberto na hora da execução.

```ruby
x = 10        # x guarda um Integer
x = "dez"     # agora guarda uma String — sem problema
x = [1, 2]    # agora um Array
```

Para saber o tipo de um valor, use `.class`:

```ruby
x = 10
x.class       # => Integer
```

Ruby também é **fortemente tipada**: ele não converte tipos "na surdina". Misturar tipos incompatíveis gera erro:

```ruby
"idade: " + 25     # erro: TypeError (no implicit conversion of Integer into String)
"idade: " + 25.to_s  # => "idade: 25"
"idade: #{25}"       # => "idade: 25" (interpolação)
```

## Tipos básicos

```ruby
nome    = "Maria"     # String
idade   = 25          # Integer
altura  = 1.65        # Float
ativo   = true        # TrueClass (booleano)
inativo = false       # FalseClass (booleano)
nulo    = nil         # NilClass (ausência de valor)
status  = :ativo      # Symbol
lista   = [1, 2, 3]   # Array
pessoa  = { nome: "Ana" }  # Hash
faixa   = (1..5)      # Range
```

| Tipo | Exemplo | Observações |
|------|---------|-------------|
| `Integer` | `42`, `1_000_000` | Sem limite fixo de tamanho; `_` separa milhares |
| `Float` | `3.14`, `1e3` | Ponto flutuante; cuidado com precisão |
| `String` | `"texto"`, `'texto'` | Mutável; veja interpolação abaixo |
| `Symbol` | `:nome` | Identificador imutável ([doc 05](05-symbols.md)) |
| `true` / `false` | — | Não existe tipo `Boolean` único; são `TrueClass` e `FalseClass` |
| `nil` | — | Único valor da classe `NilClass` |

## Variáveis e nomes

Regras e convenções:

- Nomes em **snake_case**: `nome_completo`, `total_vendas`.
- Começam com letra minúscula ou `_`.
- Não use hífen nem espaço.
- Não existe `let`, `const` ou `var`: basta atribuir.

```ruby
nome_completo = "Maria Silva"
_temp = 10
```

### Tipos de variáveis (pelo prefixo)

| Prefixo | Tipo | Alcance |
|---------|------|---------|
| (nenhum) `x` | Local | Dentro do método/bloco onde foi criada |
| `@x` | De instância | Pertence a um objeto específico |
| `@@x` | De classe | Compartilhada por toda a classe (use com cautela) |
| `$x` | Global | Todo o programa (evite) |
| `X` (maiúscula) | Constante | Valor que "não deve mudar" |

## Constantes

Começam com letra **maiúscula**. Ruby avisa se você reatribuir, mas não impede.

```ruby
PI = 3.14159
EMPRESA = "Acme"

PI = 3         # warning: already initialized constant PI
```

Para impedir alterações de verdade em objetos, use `freeze`:

```ruby
LISTA = ["a", "b"].freeze
LISTA << "c"   # erro: FrozenError (can't modify frozen Array)
```

## Strings

### Aspas simples vs. duplas

```ruby
nome = "Ana"
"Olá, #{nome}!\n"    # => "Olá, Ana!\n"  (interpola e interpreta \n)
'Olá, #{nome}!\n'    # => "Olá, \#{nome}!\\n" (texto literal)
```

Só aspas **duplas** fazem interpolação (`#{...}`) e interpretam escapes como `\n` e `\t`.

### Strings são mutáveis

```ruby
s = "ruby"
s << " on rails"     # modifica a própria string
s                    # => "ruby on rails"

t = s.upcase         # cria uma nova string
s.upcase!            # o "!" indica que altera a própria string
```

### Métodos úteis

```ruby
"ruby".length          # => 4
"ruby".upcase          # => "RUBY"
"RUBY".downcase        # => "ruby"
"ruby".capitalize      # => "Ruby"
"ruby".reverse         # => "ybur"
"ruby".include?("u")   # => true
"ruby on rails".split  # => ["ruby", "on", "rails"]
"  oi  ".strip         # => "oi"
"ruby" * 3             # => "rubyrubyruby"
"ruby"[0]              # => "r"
"ruby"[1..2]           # => "ub"
```

### Heredoc (texto de várias linhas)

```ruby
texto = <<~TEXTO
  Linha 1
  Linha 2
TEXTO
```

## Números

```ruby
10 / 3        # => 3     (divisão inteira!)
10.0 / 3      # => 3.3333333333333335
10 % 3        # => 1
2 ** 8        # => 256
10.fdiv(3)    # => 3.3333333333333335
10.divmod(3)  # => [3, 1]
7.5.round     # => 8
7.456.round(2) # => 7.46
```

Cuidado: `Integer / Integer` resulta em `Integer`. Para ter decimais, ao menos um lado precisa ser `Float`.

## Conversões de tipo

| Método | Converte para | Exemplo |
|--------|---------------|---------|
| `to_i` | Integer | `"42".to_i # => 42` |
| `to_f` | Float | `"3.5".to_f # => 3.5` |
| `to_s` | String | `42.to_s # => "42"` |
| `to_sym` | Symbol | `"ativo".to_sym # => :ativo` |
| `to_a` | Array | `(1..3).to_a # => [1, 2, 3]` |

Conversão "tolerante" vs. "estrita":

```ruby
"abc".to_i          # => 0 (não falha)
"12abc".to_i        # => 12
Integer("abc")      # erro: ArgumentError
Integer("42")       # => 42
Float("3.5")        # => 3.5
```

Use `Integer()` e `Float()` quando quiser validar a entrada do usuário.

## Verdadeiro e falso (truthiness)

Em Ruby, **apenas `false` e `nil` são falsos**. Todo o resto é verdadeiro, inclusive `0` e `""`.

```ruby
puts "0 é verdadeiro" if 0       # imprime
puts "vazio é verdadeiro" if ""  # imprime
puts "nil é falso" if nil        # não imprime
```

Essa é uma das maiores diferenças em relação a outras linguagens (como JavaScript, onde `0` e `""` são falsos).

## `nil`

`nil` representa "nenhum valor". É um objeto e tem métodos:

```ruby
nil.to_a       # => []
nil.to_s       # => ""
nil.nil?       # => true
nil.upcase     # erro: NoMethodError (undefined method 'upcase' for nil)
```

O erro `undefined method ... for nil` é o mais comum em Ruby. Para se proteger, use a navegação segura `&.`:

```ruby
usuario = nil
usuario&.nome      # => nil (não gera erro)
```

## Atribuição múltipla

```ruby
a, b = 1, 2
a, b = b, a        # troca os valores
primeiro, *resto = [10, 20, 30]
primeiro           # => 10
resto              # => [20, 30]
```

## Resumo

- Tipagem **dinâmica** e **forte**.
- Tipos básicos: `Integer`, `Float`, `String`, `Symbol`, `true`/`false`, `nil`.
- Variáveis em `snake_case`; constantes em MAIÚSCULAS.
- Só `false` e `nil` são falsos.
- Use `.class` para descobrir o tipo e `to_i`, `to_f`, `to_s` para converter.

## Exercícios

1. Crie variáveis `nome`, `idade` e `altura` e imprima: `Maria tem 25 anos e 1.65m de altura` usando interpolação.
2. Descubra a classe de `10`, `10.0`, `"10"`, `:dez`, `nil`, `true` e `[10]`.
3. Calcule a média de `7`, `8` e `10` com resultado decimal (dica: `fdiv` ou `.to_f`).
4. Converta `"123abc"` com `to_i` e com `Integer()` e explique a diferença.
5. Teste no `irb` se `0`, `""`, `[]` e `nil` são verdadeiros ou falsos em um `if`.
