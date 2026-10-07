# 03 — Tipos e valores

## Quadro de tipos

| JavaScript | Ruby | Observação |
|-----------|------|-----------|
| `number` (inteiro e decimal) | `Integer` e `Float` | Ruby separa inteiro de decimal |
| `bigint` | `Integer` | Ruby tem inteiros de precisão arbitrária nativamente |
| `string` | `String` | **Mutável** em Ruby |
| `boolean` | `true` / `false` (`TrueClass`/`FalseClass`) | |
| `null` / `undefined` | `nil` | Só existe um "vazio" |
| `symbol` | `Symbol` (`:nome`) | Uso muito mais comum em Ruby |
| `Array` | `Array` | |
| `Object` (`{}`) | `Hash` | Objeto "dicionário" |
| `Map` | `Hash` | Hash é ordenado e aceita qualquer chave |
| `Set` | `Set` | |
| `Date` | `Time`, `Date` | |
| `RegExp` | `Regexp` | |
| `function` | `Proc`, `Lambda`, `Method` | |
| — | `Range` (`1..5`) | Sem equivalente nativo no JS |

## Números

🔴 **Divisão de inteiros** é a surpresa clássica:

```javascript
7 / 2          // 3.5
Math.floor(7 / 2)   // 3
```

```ruby
7 / 2          # => 3     (Integer / Integer = Integer)
7 / 2.0        # => 3.5
7.fdiv(2)      # => 3.5
7.divmod(2)    # => [3, 1]
7 % 2          # => 1
```

Mais diferenças:

```javascript
0.1 + 0.2                 // 0.30000000000000004
2 ** 100                  // 1.2676506002282294e+30 (perde precisão)
Number.MAX_SAFE_INTEGER   // 9007199254740991
```

```ruby
0.1 + 0.2                 # => 0.30000000000000004 (mesmo IEEE 754)
2 ** 100                  # => 1267650600228229401496703205376 (exato!)
(0.1r + 0.2r)             # => (3/10)  (Rational)
require "bigdecimal"
BigDecimal("0.1") + BigDecimal("0.2")   # => 0.3e0
```

Para dinheiro: use `BigDecimal`, `Rational` ou inteiros em centavos.

Conversões:

```javascript
Number("42")       // 42
parseInt("42px")   // 42
parseFloat("3.5")  // 3.5
Number("abc")      // NaN
```

```ruby
"42".to_i          # => 42
"42px".to_i        # => 42   (lê até onde der)
"abc".to_i         # => 0
"3.5".to_f         # => 3.5
Integer("42")      # => 42
Integer("abc")     # erro: ArgumentError (conversão estrita)
Float("3.5")       # => 3.5
42.to_s            # => "42"
```

Não existe `NaN` "contaminando" contas como no JS: `Integer("abc")` explode; `0.0 / 0` dá `NaN`; `1 / 0` levanta `ZeroDivisionError`.

Separador de milhar para legibilidade: `1_000_000`.

## Strings

```javascript
const s = "ruby";
s[0]                   // "r"
s.toUpperCase()
s.includes("ub")
s.slice(1, 3)
s.split("")
s.padStart(6, "*")
s.replace("r", "R")    // 1ª ocorrência
s.replaceAll("r", "R")
s.trim()
```

```ruby
s = "ruby"
s[0]                   # => "r"
s.upcase
s.include?("ub")
s[1, 2]                # => "ub"  (início, tamanho)  |  s[1..2]
s.chars                # => ["r", "u", "b", "y"]
s.rjust(6, "*")        # => "**ruby"
s.sub("r", "R")        # 1ª ocorrência
s.gsub("r", "R")       # todas
s.strip
```

Equivalências de métodos de string:

| JavaScript | Ruby |
|-----------|------|
| `length` | `length` / `size` |
| `toUpperCase()` / `toLowerCase()` | `upcase` / `downcase` |
| `charAt(i)` / `[i]` | `[i]` |
| `indexOf("x")` | `index("x")` |
| `startsWith` / `endsWith` | `start_with?` / `end_with?` |
| `includes` | `include?` |
| `trim()` | `strip` |
| `split(",")` | `split(",")` |
| `repeat(3)` | `"ab" * 3` |
| `concat` / `+` | `+` / `<<` |
| `padStart` / `padEnd` | `rjust` / `ljust` |
| `replace` / `replaceAll` | `sub` / `gsub` |
| `slice` / `substring` | `[a, n]` / `[a..b]` |
| `localeCompare` | `<=>` |
| `.match(/re/)` | `.match(/re/)` / `=~` |
| capitalizar (manual) | `capitalize` |

🔴 **Strings são mutáveis** em Ruby:

```ruby
a = "oi"
b = a
b << " mundo"     # altera o MESMO objeto
a                 # => "oi mundo"

c = a.dup         # cópia independente
```

Em JS, strings são imutáveis (primitivos). Por isso a convenção `# frozen_string_literal: true`, que congela literais.

🔴 **Sem coerção automática** (tipagem forte):

```javascript
"1" + 1       // "11"
"3" * 2       // 6
```

```ruby
"1" + 1       # erro: TypeError (no implicit conversion of Integer into String)
"1" + 1.to_s  # => "11"
"1".to_i + 1  # => 2
"3" * 2       # => "33"  (repetição de string!)
```

Heredoc (texto multilinha):

```ruby
texto = <<~TEXTO
  Linha 1
  Linha 2 com #{interpolacao}
TEXTO
```

## `nil`: um único "vazio"

JS tem `null` **e** `undefined`; Ruby só tem `nil`.

```javascript
let x;                // undefined
const o = {};
o.chave               // undefined
null ?? "padrão"      // "padrão"
```

```ruby
x = nil
h = {}
h[:chave]             # => nil
nil.to_a              # => []
nil.to_s              # => ""
x.nil?                # => true
x || "padrão"         # => "padrão"
```

Acesso a atributo/método de `nil` gera erro (`NoMethodError`), como `TypeError` no JS. Navegação segura: `x&.metodo` (equivale a `x?.metodo`).

Variável **não definida** não é `nil`: dá `NameError`.

## Verdadeiro e falso (truthiness)

🔴 Uma das diferenças mais importantes:

| Valor | JavaScript | Ruby |
|-------|-----------|------|
| `false` | falsy | falsy |
| `nil` / `null` / `undefined` | falsy | falsy |
| `0` | **falsy** | **truthy** |
| `""` (string vazia) | **falsy** | **truthy** |
| `[]` (array vazio) | truthy | truthy |
| `{}` | truthy | truthy |
| `NaN` | falsy | — (`NaN` é truthy) |

Em Ruby **só `false` e `nil` são falsy**. Tudo o mais é truthy.

```javascript
if (0) {}            // não executa
if ("") {}           // não executa
```

```ruby
puts "executa" if 0         # imprime!
puts "executa" if ""        # imprime!
```

Teste de vazio explícito:

```ruby
"".empty?          # => true
[].empty?          # => true
{}.empty?          # => true
0.zero?            # => true
x.nil?             # => true
x.blank?           # (Rails) nil, "", "  ", [], {}
x.present?         # (Rails) o oposto
```

## Symbols

Um **symbol** (`:nome`) é um identificador **imutável e único** (a mesma instância na memória). Usado como chave de hash, nome de método, opções.

```javascript
// JS: usamos strings para chaves e nomes
const status = "ativo";
obj["nome"];
```

```ruby
status = :ativo
hash[:nome]
```

| String | Symbol |
|--------|--------|
| `"ativo"` | `:ativo` |
| Mutável, nova instância a cada literal | Imutável, mesma instância |
| Para **dados de texto** | Para **identificadores/rótulos** |

```ruby
"a".object_id == "a".object_id    # => false
:a.object_id == :a.object_id      # => true
:ativo.to_s                       # => "ativo"
"ativo".to_sym                    # => :ativo
```

(`Symbol` do JS é outra coisa: um valor único usado como chave "privada". O symbol do Ruby é mais próximo de uma "string interna e imutável".)

## Checagem de tipo

```javascript
typeof x === "string"
x instanceof Array
Array.isArray(x)
Number.isInteger(x)
```

```ruby
x.is_a?(String)
x.is_a?(Array)
x.instance_of?(Integer)
x.class                    # => Integer
x.respond_to?(:each)       # duck typing: preferível
x.integer?                 # para números
```

Em Ruby, prefira **perguntar o comportamento** (`respond_to?`) à classe (*duck typing*).

## Conversões resumidas

| Para | JavaScript | Ruby |
|------|-----------|------|
| String | `String(x)` / `x.toString()` | `x.to_s` |
| Inteiro | `parseInt(x)` | `x.to_i` / `Integer(x)` |
| Decimal | `parseFloat(x)` | `x.to_f` / `Float(x)` |
| Array | `Array.from(x)` / `[...x]` | `x.to_a` |
| Booleano | `Boolean(x)` / `!!x` | `!!x` |
| Objeto/Hash a partir de pares | `Object.fromEntries(p)` | `p.to_h` |
| Symbol | — | `x.to_sym` |

## Resumo

- Ruby separa `Integer` e `Float`; a divisão de inteiros **trunca**.
- Strings são mutáveis; não há coerção implícita (`"1" + 1` é erro).
- Só existe `nil` (sem `undefined`).
- **Só `false` e `nil` são falsy**: `0` e `""` são verdadeiros.
- Symbols são identificadores imutáveis, muito usados como chaves.

## Exercícios

1. Calcule `7 / 2`, `7 / 2.0`, `-7 / 2` e `-7 % 3`; compare com o JS.
2. Calcule `2 ** 200` em Ruby e em JS e compare.
3. Converta `"12abc"` para número em Ruby de duas formas (leniente e estrita) e observe a diferença.
4. Escreva um teste mostrando que `0` e `""` são truthy em Ruby.
5. Prove que strings são mutáveis (crie `b = a`, altere `b` e imprima `a`). Depois evite o efeito com `dup`.
6. Explique quando usar String e quando usar Symbol.
