# 05 — Controle de fluxo

## `if` / `else`

```javascript
if (nota >= 7) {
  console.log("aprovado");
} else if (nota >= 5) {
  console.log("recuperação");
} else {
  console.log("reprovado");
}
```

```ruby
if nota >= 7
  puts "aprovado"
elsif nota >= 5          # note: elsif (não "else if")
  puts "recuperação"
else
  puts "reprovado"
end
```

Diferenças:

- Sem parênteses nem chaves; fecha com `end`.
- `elsif` (uma palavra, sem o segundo `e`).
- `if` **é uma expressão** e devolve valor.

```ruby
situacao = if nota >= 7 then "aprovado" else "reprovado" end
```

### Modificadores de uma linha

```ruby
puts "maior" if idade >= 18
puts "menor" unless idade >= 18
```

### `unless` (se não)

```ruby
unless usuario.admin?
  puts "acesso negado"
end
```

Evite `unless` com `else` ou condições compostas: fica confuso.

## `switch` → `case`

```javascript
switch (dia) {
  case "sab":
  case "dom":
    console.log("fim de semana");
    break;
  case "seg":
    console.log("começo");
    break;
  default:
    console.log("dia útil");
}
```

```ruby
case dia
when "sab", "dom"
  puts "fim de semana"
when "seg"
  puts "começo"
else
  puts "dia útil"
end
```

Diferenças importantes:

- **Sem `break`**: não há *fall-through*. Cada `when` termina sozinho.
- Vários valores no mesmo `when`, separados por vírgula.
- `case` também é expressão.
- Usa `===` por baixo, então aceita **intervalos, classes, regex, lambdas**:

```ruby
nota_conceito = case nota
                when 9..10 then "A"
                when 7...9 then "B"
                when 5...7 then "C"
                else "D"
                end

case valor
when Integer then "inteiro"
when String  then "texto"
when nil     then "nulo"
when /^\d+$/ then "só dígitos"
when ->(x) { x.respond_to?(:each) } then "iterável"
end
```

`case` sem argumento funciona como cadeia de `if`:

```ruby
case
when idade < 12 then "criança"
when idade < 18 then "adolescente"
else "adulto"
end
```

## Pattern matching (Ruby 3+)

Equivalente a desestruturação condicional:

```ruby
config = { nome: "Ana", papel: "admin" }

case config
in { papel: "admin", nome: }
  puts "Admin #{nome}"
in { papel: "user" }
  puts "Usuário"
end

case [1, [2, 3]]
in [a, [b, *resto]]
  puts a, b, resto
end
```

## Laços

### `for` e `while`

```javascript
for (let i = 0; i < 5; i++) { console.log(i); }

let n = 0;
while (n < 3) { n++; }

do { n--; } while (n > 0);
```

```ruby
5.times { |i| puts i }                # idiomático
(0...5).each { |i| puts i }
0.upto(4) { |i| puts i }
0.step(10, 2) { |i| puts i }          # de 2 em 2

n = 0
while n < 3
  n += 1
end

until n.zero?                         # "até que"
  n -= 1
end

begin                                 # equivalente a do...while
  n += 1
end while n < 3
```

`for` existe em Ruby, mas é **raramente usado**:

```ruby
for i in 0..4
  puts i
end
```

🔴 O `for` **não cria escopo**: a variável `i` continua existindo depois do laço. Prefira `each`.

### `for...of` → `each`

```javascript
for (const fruta of frutas) { console.log(fruta); }
frutas.forEach((f, i) => console.log(i, f));
for (const i in obj) {}            // chaves
for (const [k, v] of Object.entries(obj)) {}
```

```ruby
frutas.each { |fruta| puts fruta }
frutas.each_with_index { |f, i| puts "#{i}: #{f}" }
hash.each { |chave, valor| puts "#{chave}=#{valor}" }
hash.each_pair { |k, v| ... }
```

### `loop` infinito

```javascript
while (true) { ... if (x) break; }
```

```ruby
loop do
  linha = gets
  break if linha.nil?
end
```

### `break`, `next` (= `continue`), `redo`

| JavaScript | Ruby |
|-----------|------|
| `break` | `break` |
| `continue` | `next` |
| `return` (de função) | `return` |

```javascript
for (const n of nums) {
  if (n % 2 === 0) continue;
  if (n > 7) break;
  console.log(n);
}
```

```ruby
nums.each do |n|
  next if n.even?
  break if n > 7
  puts n
end
```

🔴 Dentro de um **bloco**, `return` sai do **método** que o contém, não só do bloco. Para sair apenas da iteração atual use `next`.

`break` com valor:

```ruby
primeiro = [1, 4, 9].each { |n| break n if n > 3 }   # => 4
```

## Iteração sem laços

O estilo Ruby evita laços manuais e usa métodos de coleção. Veja o [doc 07](07-arrays-e-iteracao.md).

```javascript
const dobros = [];
for (const n of nums) dobros.push(n * 2);
```

```ruby
dobros = nums.map { |n| n * 2 }
```

## Operador ternário e `&&` como controle de fluxo

```ruby
x > 0 ? "positivo" : "não positivo"
usuario && usuario.salvar         # só salva se existir (forma antiga)
usuario&.salvar                   # forma moderna
```

## Ranges em condições

```ruby
puts "adulto" if (18..64).cover?(idade)
```

## Resumo

- Sem parênteses/chaves; `end` fecha; `elsif` em vez de `else if`.
- `unless` e modificadores (`... if cond`) deixam o código legível.
- `case/when` não tem `break`, aceita vírgulas, intervalos, classes, regex; usa `===`.
- Prefira `each`, `times`, `map` a `for`/`while`.
- `continue` → `next`; `return` dentro de bloco sai do método.

## Exercícios

1. Traduza um `switch` de dias da semana (com *fall-through* para sábado e domingo) para `case/when`.
2. Classifique uma nota (0–10) em A/B/C/D com `case` e intervalos.
3. Imprima os números de 1 a 20 que são múltiplos de 3, usando `next`.
4. Reescreva um laço `for` com `push` usando `map`.
5. Use pattern matching para tratar `{ tipo: "circulo", raio: r }` e `{ tipo: "retangulo", l:, a: }` calculando a área.
6. Explique por que `return` dentro de `each` dentro de um método encerra o método.
