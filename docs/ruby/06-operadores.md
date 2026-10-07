# 06 — Operadores

Operadores combinam valores para produzir um resultado. Em Ruby, a maioria dos operadores é, na verdade, **um método** com sintaxe especial: `2 + 3` equivale a `2.+(3)`.

## Aritméticos

| Operador | Operação | Exemplo | Resultado |
|----------|----------|---------|-----------|
| `+` | Soma | `7 + 2` | `9` |
| `-` | Subtração | `7 - 2` | `5` |
| `*` | Multiplicação | `7 * 2` | `14` |
| `/` | Divisão | `7 / 2` | `3` (inteira!) |
| `%` | Resto (módulo) | `7 % 2` | `1` |
| `**` | Potência | `2 ** 10` | `1024` |

### Divisão de inteiros

```ruby
7 / 2          # => 3     (Integer / Integer = Integer)
7.0 / 2        # => 3.5
7 / 2.0        # => 3.5
7.fdiv(2)      # => 3.5
7.divmod(2)    # => [3, 1]  (quociente e resto)
```

### Números negativos

A divisão de inteiros arredonda **para baixo** e o resto acompanha o sinal do divisor:

```ruby
-7 / 2         # => -4
-7 % 3         # => 2
-7.remainder(3) # => -1 (resto "estilo C")
```

### Precisão de decimais

```ruby
0.1 + 0.2              # => 0.30000000000000004
(0.1 + 0.2).round(2)   # => 0.3
```

Para dinheiro, evite `Float`. Use inteiros (centavos) ou `BigDecimal`.

### Precedência (resumo)

`**` → `*`, `/`, `%` → `+`, `-`. Use parênteses para deixar claro:

```ruby
2 + 3 * 4      # => 14
(2 + 3) * 4    # => 20
-2 ** 2        # => -4   (potência acontece antes do sinal)
```

## Comparação

| Operador | Significado | Exemplo | Resultado |
|----------|-------------|---------|-----------|
| `==` | Igual (valor) | `5 == 5.0` | `true` |
| `!=` | Diferente | `5 != 3` | `true` |
| `>` | Maior | `5 > 3` | `true` |
| `<` | Menor | `5 < 3` | `false` |
| `>=` | Maior ou igual | `5 >= 5` | `true` |
| `<=` | Menor ou igual | `5 <= 4` | `false` |
| `<=>` | Comparação ("spaceship") | `5 <=> 3` | `1` |
| `===` | Igualdade de caso | `(1..5) === 3` | `true` |
| `eql?` | Igual e do mesmo tipo | `1.eql?(1.0)` | `false` |
| `equal?` | Mesmo objeto | `"a".equal?("a")` | `false` |

### O operador `<=>`

Retorna `-1`, `0` ou `1` (ou `nil` se não comparáveis). É a base da ordenação:

```ruby
1 <=> 2        # => -1
2 <=> 2        # => 0
3 <=> 2        # => 1
"a" <=> "b"    # => -1
1 <=> "a"      # => nil
```

### `==`, `eql?` e `equal?`

```ruby
a = "ruby"
b = "ruby"

a == b         # => true   (mesmo conteúdo)
a.eql?(b)      # => true   (mesmo conteúdo e tipo)
a.equal?(b)    # => false  (objetos diferentes)

1 == 1.0       # => true
1.eql?(1.0)    # => false
```

Na prática, use `==` na maior parte dos casos.

## Lógicos

| Operador | Significado |
|----------|-------------|
| `&&` | E (and) |
| `\|\|` | Ou (or) |
| `!` | Negação (not) |

```ruby
idade = 20
tem_documento = true

idade >= 18 && tem_documento    # => true
idade < 18 || tem_documento     # => true
!tem_documento                  # => false
```

### Curto-circuito e valores retornados

`&&` e `||` **retornam um dos operandos**, não apenas `true`/`false`:

```ruby
nil || "padrão"      # => "padrão"
"valor" || "padrão"  # => "valor"
nil && "x"           # => nil
"a" && "b"           # => "b"
```

Isso permite o idioma de valor padrão:

```ruby
nome = params_nome || "Visitante"
```

### `and`, `or`, `not`

Fazem o mesmo, mas têm **precedência muito baixa**. Evite em expressões; use para controle de fluxo:

```ruby
x = true and false     # x é true! (lê-se: (x = true) and false)
x = (true && false)    # x é false
```

Regra prática: use `&&`, `||` e `!` em expressões.

### Convertendo para booleano

```ruby
!!nil          # => false
!!0            # => true   (0 é verdadeiro em Ruby)
!!"texto"      # => true
```

## Atribuição

```ruby
x = 10
x += 5     # x = x + 5   => 15
x -= 3     # => 12
x *= 2     # => 24
x /= 4     # => 6
x **= 2    # => 36
x %= 5     # => 1
```

Não existe `x++` nem `x--` em Ruby. Use `x += 1`.

### Atribuição condicional: `||=` e `&&=`

```ruby
cache ||= calcular   # só atribui se cache for nil ou false
nome ||= "Anônimo"

contador = 5
contador &&= contador + 1   # só atribui se contador for verdadeiro
```

`||=` é muito comum para valores padrão e "memoização".

## Navegação segura: `&.`

Chama o método só se o objeto não for `nil`:

```ruby
usuario = nil
usuario.nome       # erro: NoMethodError
usuario&.nome      # => nil

usuario&.endereco&.cidade   # encadeia com segurança
```

## Operadores de string e array

```ruby
"ru" + "by"        # => "ruby"
"ruby" * 2         # => "rubyruby"
"ruby" << "!"      # => "ruby!" (altera a string)
"a=%d" % 5         # => "a=5"

[1, 2] + [3]       # => [1, 2, 3]
[1, 2, 3] - [2]    # => [1, 3]
[1, 2] * 2         # => [1, 2, 1, 2]
[1, 2] & [2, 3]    # => [2]      (interseção)
[1, 2] | [2, 3]    # => [1, 2, 3] (união)
```

## Intervalos e outros

```ruby
1..5       # Range inclusivo
1...5      # Range exclusivo (sem o 5)
x ? a : b  # ternário
defined?(x) # => "local-variable" ou nil
```

## Tabela de verdade rápida

| `a` | `b` | `a && b` | `a \|\| b` |
|-----|-----|----------|-----------|
| true | true | true | true |
| true | false | false | true |
| false | true | false | true |
| false | false | false | false |

## Resumo

- `/` entre inteiros dá inteiro; use `fdiv` ou `Float` para decimais.
- `==` compara valores; `equal?` compara identidade; `<=>` ordena.
- `&&`, `||`, `!` retornam operandos, o que permite valores padrão.
- `||=` atribui só se o valor atual for `nil`/`false`.
- `&.` evita `NoMethodError` em `nil`.
- Não há `++`/`--`.

## Exercícios

1. Calcule `17 / 5`, `17 % 5`, `17.fdiv(5)` e `17.divmod(5)`.
2. Verifique se `ano` é bissexto usando `%`, `&&` e `||`.
3. Mostre o resultado de `nil || "x"`, `false || nil` e `0 || "x"` e explique.
4. Use `||=` para definir um valor padrão em uma variável que pode ser `nil`.
5. Explique por que `x = true and false` deixa `x` como `true`.
