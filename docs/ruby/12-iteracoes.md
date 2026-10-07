# 12 — Iterações em collections

A força das collections em Ruby está nos **métodos de iteração**. Eles percorrem os elementos **sem você controlar índices manualmente** e recebem um **bloco** com o que fazer em cada elemento.

```ruby
numeros = [4, 8, 15, 16, 23, 42]
numeros.each { |n| puts n }
#          ^ método   ^ bloco: |n| é o parâmetro, o resto é o corpo
```

## Blocos: `{ }` ou `do ... end`

```ruby
numeros.each { |n| puts n }         # uma linha: chaves

numeros.each do |n|                 # várias linhas: do...end
  dobro = n * 2
  puts dobro
end
```

Convenção: chaves para uma linha, `do...end` para várias.

## `each` — percorrer e executar

Executa o bloco para cada elemento e retorna a **própria collection**. Use quando quer **efeitos** (imprimir, salvar), não um novo valor.

```ruby
frutas = %w[maçã uva pera]
frutas.each { |f| puts f.upcase }
```

## `map` — transformar cada elemento

Retorna um **novo array** com o resultado do bloco para cada elemento.

```ruby
[1, 2, 3, 4].map { |n| n * 2 }       # => [2, 4, 6, 8]
%w[ana bia].map { |nome| nome.capitalize }   # => ["Ana", "Bia"]
```

Forma curta com `&:método` (Symbol#to_proc):

```ruby
%w[ana bia].map(&:upcase)            # => ["ANA", "BIA"]
["1", "2", "3"].map(&:to_i)          # => [1, 2, 3]
```

## `select` / `filter` — manter os que atendem

```ruby
[1, 2, 3, 4, 5, 6].select { |n| n.even? }    # => [2, 4, 6]
[1, 2, 3, 4, 5, 6].filter(&:odd?)            # => [1, 3, 5]
```

## `reject` — remover os que atendem

```ruby
[1, 2, 3, 4, 5, 6].reject { |n| n.even? }    # => [1, 3, 5]
```

## `find` / `detect` — o primeiro que atende

```ruby
[4, 8, 15, 16, 23].find { |n| n > 10 }       # => 15
[4, 8].find { |n| n > 10 }                   # => nil (nenhum encontrado)
```

`find_all` é um sinônimo de `select`.

## `reduce` / `inject` — combinar tudo em um valor

```ruby
[1, 2, 3, 4].reduce(0) { |acumulador, n| acumulador + n }   # => 10
[1, 2, 3, 4].reduce(:+)                                     # => 10
[1, 2, 3, 4].reduce(1) { |produto, n| produto * n }         # => 24
[3, 7, 2].reduce { |maior, n| n > maior ? n : maior }       # => 7
```

O primeiro parâmetro do bloco é o **acumulador**; o argumento do `reduce` é o valor **inicial**. Sem valor inicial, o primeiro elemento é usado.

Para soma simples, prefira `sum`:

```ruby
[1, 2, 3].sum                      # => 6
produtos.sum { |p| p[:preco] }     # soma de um atributo
```

## `sort_by`, `min_by`, `max_by`

```ruby
pessoas = [
  { nome: "Ana", idade: 30 },
  { nome: "Bruno", idade: 20 },
  { nome: "Carla", idade: 25 }
]

pessoas.sort_by { |p| p[:idade] }          # ordena por idade crescente
pessoas.sort_by { |p| -p[:idade] }         # decrescente
pessoas.min_by { |p| p[:idade] }           # => { nome: "Bruno", idade: 20 }
pessoas.max_by { |p| p[:idade] }[:nome]    # => "Ana"
```

## `each_with_index` e `map.with_index`

```ruby
%w[a b c].each_with_index { |letra, i| puts "#{i}: #{letra}" }

%w[a b c].map.with_index(1) { |letra, i| "#{i}. #{letra}" }
# => ["1. a", "2. b", "3. c"]
```

## `each_with_object` — montar um resultado

```ruby
palavras = %w[ana bia ana caio bia ana]

contagem = palavras.each_with_object(Hash.new(0)) do |p, h|
  h[p] += 1
end
# => { "ana" => 3, "bia" => 2, "caio" => 1 }
```

## `group_by`, `partition`, `tally`

```ruby
numeros = (1..10).to_a

numeros.group_by { |n| n % 3 }
# => { 1 => [1, 4, 7, 10], 2 => [2, 5, 8], 0 => [3, 6, 9] }

pares, impares = numeros.partition(&:even?)
# pares => [2, 4, 6, 8, 10]; impares => [1, 3, 5, 7, 9]

%w[a b a c a].tally     # => { "a" => 3, "b" => 1, "c" => 1 }
```

## Perguntas sobre a collection

```ruby
numeros = [4, 8, 15, 16, 23, 42]

numeros.any? { |n| n > 40 }     # => true   (algum atende?)
numeros.all? { |n| n > 0 }      # => true   (todos atendem?)
numeros.none? { |n| n > 100 }   # => true   (nenhum atende?)
numeros.count { |n| n.even? }   # => 4
numeros.include?(15)            # => true
```

## Outros métodos úteis

```ruby
[[1, 2], [3]].flat_map { |a| a }       # => [1, 2, 3]
[1, 2, 3, 4].take_while { |n| n < 3 }  # => [1, 2]
[1, 2, 3, 4].drop_while { |n| n < 3 }  # => [3, 4]
[1, nil, 2].filter_map { |n| n&.*(2) } # => [2, 4]  (map + remove nil/false)
[1, 2, 3].zip([:a, :b, :c])            # => [[1, :a], [2, :b], [3, :c]]
(1..6).each_slice(2).to_a              # => [[1, 2], [3, 4], [5, 6]]
```

## Encadeando métodos

Cada método retorna uma collection; dá para encadear de forma legível:

```ruby
produtos = [
  { nome: "Notebook", preco: 3500, estoque: 5 },
  { nome: "Mouse",    preco: 50,   estoque: 20 },
  { nome: "Teclado",  preco: 120,  estoque: 0 },
  { nome: "Monitor",  preco: 900,  estoque: 8 }
]

valor_total = produtos
  .select { |p| p[:estoque] > 0 }
  .map    { |p| p[:preco] * p[:estoque] }
  .sum
# => 3500*5 + 50*20 + 900*8 = 25700

nomes_baratos = produtos
  .select { |p| p[:preco] < 1000 }
  .sort_by { |p| p[:preco] }
  .map { |p| p[:nome] }
# => ["Mouse", "Teclado", "Monitor"]
```

## Qual método usar?

| Quero... | Use |
|----------|-----|
| Fazer algo com cada elemento (imprimir, salvar) | `each` |
| Transformar cada elemento em outro | `map` |
| Ficar só com alguns | `select` / `filter` |
| Descartar alguns | `reject` |
| Achar o primeiro que atende | `find` |
| Reduzir a um único valor | `reduce` / `sum` |
| Contar quantos atendem | `count` |
| Ordenar por critério | `sort_by` |
| Agrupar por critério | `group_by` |
| Dividir em dois grupos | `partition` |

## Erros comuns

1. **Usar `each` quando queria `map`:** `each` não devolve os valores transformados.
2. **Esquecer o valor inicial em `reduce`** com collections vazias: `[].reduce(:+)` retorna `nil`; `[].sum` retorna `0`.
3. **Modificar a collection durante a iteração.**
4. **Esquecer que `select` em Hash retorna Hash**, e `map` em Hash retorna Array.

## Hashes e iteração

```ruby
precos = { cafe: 5, pao: 2 }
precos.each { |produto, preco| puts "#{produto}: #{preco}" }
precos.map { |produto, preco| "#{produto}=#{preco}" }   # => ["cafe=5", "pao=2"]
precos.select { |_, preco| preco > 3 }                  # => { cafe: 5 }
```

## Resumo

- Itere com métodos, não com contadores: `each`, `map`, `select`, `reject`, `reduce`, `find`.
- `each` executa; `map` transforma; `select` filtra; `reduce` combina.
- `&:metodo` é um atalho para blocos simples.
- Encadeie métodos para expressar transformações complexas de forma legível.

## Exercícios

Use `numeros = [4, 8, 15, 16, 23, 42, 7, 3, 10]`.

1. Exiba cada número multiplicado por 3 (`each`).
2. Crie um array com o quadrado de cada número (`map`).
3. Liste apenas os maiores que 10 (`select`).
4. Liste os que **não** são pares (`reject`).
5. Calcule a soma total com `reduce` e depois com `sum`.
6. Encontre o primeiro número maior que 20 (`find`).
7. Separe pares e ímpares com `partition`.

Desafio: com o array de `produtos` acima, liste os nomes dos produtos em estoque ordenados do mais caro ao mais barato e calcule o valor total em estoque.
