# 11 — Range (intervalos)

Um **Range** representa um **intervalo de valores** entre um início e um fim. É muito usado em loops, condições e fatiamento de arrays.

```ruby
(1..5)     # inclui o 5  -> 1, 2, 3, 4, 5
(1...5)    # exclui o 5  -> 1, 2, 3, 4
```

Memorize: **dois pontos = inclui o fim; três pontos = exclui o fim**.

## Criando ranges

```ruby
(1..10)              # números
("a".."e")           # letras
(1.0..2.0)           # decimais (não iterável com each)
Range.new(1, 5)      # forma explícita
Range.new(1, 5, true)  # exclusivo, igual a (1...5)
```

Ranges podem ser **sem fim** ou **sem começo** (Ruby 2.6/2.7+):

```ruby
(1..)       # de 1 até o infinito
(..10)      # até 10
```

## Convertendo e percorrendo

```ruby
(1..5).to_a            # => [1, 2, 3, 4, 5]
("a".."e").to_a        # => ["a", "b", "c", "d", "e"]
(1...5).to_a           # => [1, 2, 3, 4]

(1..3).each { |n| puts n }
(1..3).map { |n| n * 2 }       # => [2, 4, 6]
(1..10).select(&:even?)        # => [2, 4, 6, 8, 10]
(1..5).reduce(:+)              # => 15
(1..5).sum                     # => 15
(1..5).reverse_each { |n| print n }   # 54321
```

## Consultando

```ruby
r = (1..10)

r.first        # => 1
r.last         # => 10
r.min          # => 1
r.max          # => 10
r.size         # => 10
r.count        # => 10
r.include?(5)  # => true
r.cover?(5)    # => true
r === 5        # => true
r.begin        # => 1
r.end          # => 10
r.exclude_end? # => false
```

### `include?` vs. `cover?`

- `include?` verifica se o valor é um dos membros do intervalo.
- `cover?` verifica se está entre o início e o fim.

Para números dá no mesmo; a diferença aparece em intervalos de strings:

```ruby
("a".."z").include?("bb")   # => false
("a".."z").cover?("bb")     # => true   ("a" <= "bb" <= "z")
```

## Passos com `step`

```ruby
(0..20).step(5).to_a         # => [0, 5, 10, 15, 20]
(0..1).step(0.25).to_a       # => [0.0, 0.25, 0.5, 0.75, 1.0]
1.step(10, 3).to_a           # => [1, 4, 7, 10]
(1..10) % 3                  # => ((1..10).%(3)) equivalente a step(3)
```

## Ranges em `case`

O `when` usa `===`, que para ranges verifica se o valor está dentro:

```ruby
nota = 8

case nota
when 9..10 then puts "Excelente"
when 7...9 then puts "Bom"
when 5...7 then puts "Regular"
else puts "Insuficiente"
end
```

## Ranges para fatiar arrays e strings

```ruby
letras = %w[a b c d e f]

letras[1..3]     # => ["b", "c", "d"]
letras[1...3]    # => ["b", "c"]
letras[2..]      # => ["c", "d", "e", "f"]
letras[..2]      # => ["a", "b", "c"]
letras[-3..]     # => ["d", "e", "f"]
letras[1..-2]    # => ["b", "c", "d", "e"]

"programação"[0..3]   # => "prog"
```

## Ranges em condições

```ruby
idade = 25
puts "Jovem adulto" if (18..29).include?(idade)
puts "Jovem adulto" if idade.between?(18, 29)   # equivalente
puts "Jovem adulto" if (18..29) === idade       # equivalente
```

## Números aleatórios e sorteios

```ruby
rand(1..6)           # um número de 1 a 6 (dado)
rand(1...6)          # de 1 a 5
[*1..60].sample(6)   # 6 números diferentes entre 1 e 60
```

## Ranges sem fim com iteração preguiçosa

```ruby
(1..Float::INFINITY).lazy.select(&:even?).first(3)   # => [2, 4, 6]
(1..).lazy.map { |n| n * n }.first(4)                # => [1, 4, 9, 16]
```

`lazy` calcula só o necessário; sem ele, um intervalo infinito travaria o programa.

## Ranges de datas

```ruby
require "date"
inicio = Date.new(2026, 1, 1)
fim    = Date.new(2026, 1, 5)
(inicio..fim).each { |d| puts d }
(inicio..fim).count                          # => 5
(inicio..fim).include?(Date.new(2026, 1, 3)) # => true
```

## Limitações

- Não dá para iterar um range de `Float` com `each`: `(1.0..2.0).each` gera `TypeError`. Use `step`.
- `(5..1).to_a` retorna `[]` (range decrescente é vazio). Use `5.downto(1)` ou `(1..5).to_a.reverse`.

## Resumo

- `..` inclui o fim; `...` exclui o fim.
- Use ranges em `each`, `case/when`, fatiamento (`array[1..3]`) e `rand`.
- `include?`/`cover?`/`===` testam se um valor está no intervalo.
- `step` controla o passo; `lazy` permite intervalos infinitos.

## Exercícios

1. Exiba os números pares de 1 a 20 usando um range.
2. Exiba as letras de `"a"` a `"j"`.
3. Verifique se 47 está entre 1 e 100 usando `include?` e depois `between?`.
4. Use `case/when` com ranges para classificar a idade (criança, adolescente, adulto, idoso).
5. Gere `[0, 5, 10, ..., 100]` com `step`.
6. Dado `%w[a b c d e f g]`, extraia do terceiro ao quinto elemento e os dois últimos.
