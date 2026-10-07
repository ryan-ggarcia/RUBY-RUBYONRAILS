# 04 — Operadores

## Aritméticos

| Operação | JavaScript | Ruby |
|----------|-----------|------|
| Soma, subtração, multiplicação | `+ - *` | `+ - *` |
| Divisão | `/` (sempre decimal) | `/` (**inteira se ambos inteiros**) |
| Resto | `%` (sinal do dividendo) | `%` (**sinal do divisor**) |
| Potência | `**` | `**` |
| Incremento | `i++`, `++i` | `i += 1` (**não existe `++`**) |
| Decremento | `i--` | `i -= 1` |
| Divisão e resto | — | `divmod` |

```javascript
-7 % 3         // -1
i++;
```

```ruby
-7 % 3         # => 2
-7.remainder(3)   # => -1  (comportamento do JS)
-7 / 2         # => -4   (arredonda para baixo)
-7.fdiv(2)     # => -3.5
i += 1
```

🔴 `i++` em Ruby é **erro de sintaxe**. Use `i += 1`.

## Atribuição composta

Igual ao JS: `+=`, `-=`, `*=`, `/=`, `%=`, `**=`, `||=`, `&&=`.

```javascript
let x = null;
x ||= 10;       // ES2021
x ??= 10;
```

```ruby
x = nil
x ||= 10        # atribui se x for nil/false (idiomático!)
x &&= x + 1     # atribui se x for truthy
```

`||=` é muito usado para **memoização** e valores padrão:

```ruby
def config
  @config ||= carregar_config   # calcula só na primeira vez
end
```

## Comparação

| | JavaScript | Ruby |
|--|-----------|------|
| Igualdade de valor | `===` (use sempre) | `==` |
| Igualdade "frouxa" | `==` (coage tipos; evitar) | **não existe** |
| Diferença | `!==` | `!=` |
| Identidade de objeto | `Object.is(a, b)` | `a.equal?(b)` |
| Igualdade estrita (hash/eql) | — | `a.eql?(b)` |
| Maior/menor | `< > <= >=` | `< > <= >=` |
| Comparação de ordenação | — | `<=>` (retorna -1, 0, 1 ou `nil`) |

```javascript
"1" == 1        // true  (coerção!)
"1" === 1       // false
[1, 2] === [1, 2]   // false (referências diferentes)
```

```ruby
"1" == 1              # => false
1 == 1.0              # => true
[1, 2] == [1, 2]      # => true   (compara conteúdo!)
{ a: 1 } == { a: 1 }  # => true
"a".equal?("a")       # => false  (objetos diferentes)
1.eql?(1.0)           # => false
1 <=> 2               # => -1
"b" <=> "a"           # => 1
```

🔴 Em Ruby, `==` em arrays e hashes compara **por valor**; no JS compara por referência.

Intervalo e padrão:

```javascript
n >= 1 && n <= 10
```

```ruby
(1..10).include?(n)
(1..10) === n          # => true/false
n.between?(1, 10)
n.clamp(1, 10)         # força para dentro do intervalo
```

## Lógicos

| | JavaScript | Ruby |
|--|-----------|------|
| E | `&&` | `&&` (e `and`) |
| Ou | `\|\|` | `\|\|` (e `or`) |
| Não | `!` | `!` (e `not`) |
| Coalescência nula | `??` | `\|\|` (⚠ trata `false` também) |

Os dois funcionam com *short-circuit* e **retornam um dos operandos**, não necessariamente booleano:

```ruby
nil || "padrão"       # => "padrão"
"ana" && "bia"        # => "bia"
nome = params[:nome] || "visitante"
```

🔴 `and`, `or`, `not` têm **precedência muito baixa** e servem para *fluxo de controle*, não para condições:

```ruby
a = true && false     # a => false
a = true and false    # a => true   (lido como (a = true) and false)
```

Use `&&`, `||`, `!` nas condições.

🔴 Não existe `??` com o mesmo significado: `||` considera `false` como vazio.

```javascript
const v = valor ?? "padrão";    // só null/undefined
```

```ruby
v = valor.nil? ? "padrão" : valor    # equivale a ??  (só troca nil)
v = valor || "padrão"                # troca também false
```

Em Rails: `valor.presence || "padrão"`.

## Navegação segura (`?.`)

```javascript
const cidade = usuario?.endereco?.cidade;
const len = lista?.[0]?.nome;
fn?.();
```

```ruby
cidade = usuario&.endereco&.cidade
nome   = lista&.first&.nome
hash.dig(:usuario, :endereco, :cidade)    # navega em Hash/Array aninhados
```

`dig` é excelente para estruturas aninhadas (JSON).

## Ternário

Idêntico ao JS:

```ruby
idade >= 18 ? "adulto" : "menor"
```

Para múltiplas condições prefira `if/elsif` ou `case` — evite ternários encadeados.

## Operadores de string, array e hash

| Operação | JavaScript | Ruby |
|----------|-----------|------|
| Concatenar strings | `a + b` | `a + b` (cria nova) / `a << b` (altera) |
| Repetir | `"ab".repeat(3)` | `"ab" * 3` |
| Adicionar ao array | `arr.push(x)` | `arr << x` / `arr.push(x)` |
| Concatenar arrays | `[...a, ...b]` | `a + b` |
| Diferença de arrays | filtro manual | `a - b` |
| Interseção | filtro manual | `a & b` |
| União | `[...new Set([...a, ...b])]` | `a \| b` |
| Spread de objeto | `{ ...a, ...b }` | `a.merge(b)` / `{ **a, **b }` |

```ruby
[1, 2, 3] + [4]          # => [1, 2, 3, 4]
[1, 2, 3] - [2]          # => [1, 3]
[1, 2] & [2, 3]          # => [2]
[1, 2] | [2, 3]          # => [1, 2, 3]
[0] * 3                  # => [0, 0, 0]
```

## Precedência e `unless`

Ruby tem a negação lida como linguagem natural:

```ruby
unless usuario.ativo?     # "a menos que"
  bloquear
end

bloquear unless usuario.ativo?
```

`if` e `unless` também funcionam como **modificadores** no final da linha, para condições simples.

## Operadores exclusivos do Ruby

| Operador | Uso | Exemplo |
|----------|-----|---------|
| `<=>` | Comparação "nave espacial" | `[3,1,2].sort { \|a, b\| b <=> a }` |
| `..` e `...` | Faixas inclusiva e exclusiva | `(1..5)`, `(1...5)` |
| `=~` e `!~` | Casamento de regex | `"abc" =~ /b/ # => 1` |
| `&.` | Navegação segura | `a&.b` |
| `**` em chamadas | Splat de hash | `f(**opcoes)` |
| `*` em chamadas | Splat de array | `f(*args)` |
| `&` | Bloco como parâmetro | `map(&:upcase)` |
| `::` | Escopo de constante | `Math::PI` |
| `\|\|=` | Atribui se nil/false | `@x \|\|= 1` |

## Resumo

- Mesma base que o JS, com diferenças-chave: sem `++`, divisão inteira, `%` com sinal do divisor.
- Só existe `==` (por valor, inclusive para arrays/hashes); identidade é `equal?`.
- `||` e `&&` retornam operandos; não há `??` equivalente exato.
- `&.` equivale a `?.`; `dig` navega estruturas aninhadas.
- `and`/`or`/`not` têm precedência baixa; prefira `&&`/`||`/`!`.

## Exercícios

1. Reescreva `let i = 0; i++; i *= 2;` em Ruby.
2. Compare `-7 % 3` com `-7.remainder(3)`.
3. Mostre que `[1,2] == [1,2]` é `true` em Ruby e `false` com `===` no JS.
4. Traduza `const nome = entrada ?? "visitante";` de forma que `false` e `""` não sejam trocados.
5. Escreva `dados.dig(:usuario, :endereco, :cep)` e explique o que acontece se `:endereco` não existir.
6. Dados `a = [1,2,3,4]` e `b = [3,4,5]`, obtenha a união, a interseção e a diferença com operadores.
7. Explique por que `x = true and false` deixa `x` verdadeiro.
