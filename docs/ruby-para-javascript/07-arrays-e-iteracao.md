# 07 — Arrays e iteração

Arrays são parecidos nas duas linguagens. A grande diferença: Ruby tem uma biblioteca de iteração muito mais rica (módulo `Enumerable`) e a maioria dos métodos de transformação **não altera** o array original (os que alteram terminam em `!` ou são `<<`, `push`, `pop`...).

## Criar e acessar

```javascript
const nums = [10, 20, 30];
nums[0];            // 10
nums[nums.length - 1];  // 30
nums.at(-1);        // 30
nums[10];           // undefined
nums.slice(1, 3);   // [20, 30]
Array(3).fill(0);   // [0, 0, 0]
```

```ruby
nums = [10, 20, 30]
nums[0]             # => 10
nums[-1]            # => 30  (índice negativo nativo)
nums.last           # => 30
nums.first          # => 10
nums[10]            # => nil
nums[1, 2]          # => [20, 30]   (início, tamanho)
nums[1..2]          # => [20, 30]   (intervalo)
nums.first(2)       # => [10, 20]
nums.last(2)        # => [20, 30]
Array.new(3, 0)     # => [0, 0, 0]
%w[a b c]           # => ["a", "b", "c"]   (array de strings)
%i[a b c]           # => [:a, :b, :c]      (array de symbols)
(1..5).to_a         # => [1, 2, 3, 4, 5]
```

🔴 Armadilha com objetos mutáveis:

```ruby
Array.new(3, [])           # => [[], [], []] — o MESMO array 3 vezes!
Array.new(3) { [] }        # => três arrays independentes (use o bloco)
```

## Equivalências de métodos

| Tarefa | JavaScript | Ruby |
|--------|-----------|------|
| Tamanho | `arr.length` | `arr.length` / `arr.size` / `arr.count` |
| Adicionar no fim | `push(x)` | `push(x)` / `<< x` |
| Remover do fim | `pop()` | `pop` |
| Adicionar no início | `unshift(x)` | `unshift(x)` / `prepend(x)` |
| Remover do início | `shift()` | `shift` |
| Concatenar | `a.concat(b)` / `[...a, ...b]` | `a + b` / `a.concat(b)` |
| Inserir/remover no meio | `splice` | `insert(i, x)` / `delete_at(i)` / `delete(x)` |
| Existe? | `includes(x)` | `include?(x)` |
| Posição | `indexOf(x)` | `index(x)` |
| Juntar em string | `join(",")` | `join(",")` |
| Inverter | `reverse()` (muta!) | `reverse` (nova) / `reverse!` |
| Ordenar | `sort()` (muta! e como texto) | `sort` (nova) / `sort!` |
| Achatar | `flat()` | `flatten` |
| Copiar | `[...arr]` / `slice()` | `dup` |
| Vazio? | `arr.length === 0` | `empty?` |
| Remover falsy | `filter(Boolean)` | `compact` (só nil) / `select(&:itself)` |
| Duplicados | `[...new Set(arr)]` | `uniq` |
| Aleatório | manual | `sample` / `shuffle` |
| Primeiros N | `slice(0, n)` | `first(n)` / `take(n)` |

🔴 O `sort` do JS ordena **como texto** por padrão (`[10, 9, 1].sort()` → `[1, 10, 9]`). O do Ruby ordena corretamente números e strings.

```ruby
[10, 9, 1].sort              # => [1, 9, 10]
[10, 9, 1].sort.reverse      # => [10, 9, 1]
[10, 9, 1].sort { |a, b| b <=> a }   # decrescente
pessoas.sort_by { |p| p[:idade] }    # por critério
pessoas.sort_by { |p| [-p[:idade], p[:nome]] }   # vários critérios
```

## Iteração: equivalências

| JavaScript | Ruby | Retorna |
|-----------|------|---------|
| `forEach` | `each` | o próprio array |
| `map` | `map` / `collect` | novo array |
| `filter` | `select` / `filter` | novo array |
| (inverso do filter) | `reject` | novo array |
| `find` | `find` / `detect` | elemento ou `nil` |
| `findIndex` | `find_index` / `index { }` | índice ou `nil` |
| `some` | `any?` | booleano |
| `every` | `all?` | booleano |
| (nenhum) | `none?` | booleano |
| `reduce` | `reduce` / `inject` | valor acumulado |
| `flatMap` | `flat_map` | novo array |
| `map` + `filter(Boolean)` | `filter_map` | novo array |
| `entries()` / `forEach((x, i))` | `each_with_index` | |
| `Object.groupBy` | `group_by` | Hash |
| soma manual | `sum` | número |
| `Math.max(...a)` | `max` / `min` / `minmax` | |
| contar ocorrências | `tally` / `count` | Hash / número |
| `slice` em pedaços | `each_slice(n)` | |
| `[...].entries()` | `each_with_index.to_a` | |
| `zip` (manual) | `zip` | array de pares |

```javascript
const nums = [1, 2, 3, 4, 5, 6];
nums.map(n => n * 2);
nums.filter(n => n % 2 === 0);
nums.reduce((acc, n) => acc + n, 0);
nums.find(n => n > 3);
nums.some(n => n > 5);
nums.every(n => n > 0);
nums.forEach((n, i) => console.log(i, n));
```

```ruby
nums = [1, 2, 3, 4, 5, 6]
nums.map { |n| n * 2 }
nums.select(&:even?)
nums.reduce(0) { |acc, n| acc + n }     # ou nums.sum
nums.find { |n| n > 3 }
nums.any? { |n| n > 5 }
nums.all?(&:positive?)
nums.each_with_index { |n, i| puts "#{i}: #{n}" }
```

🔴 Em `reduce`, o **valor inicial** é o argumento e o **acumulador vem primeiro** no bloco (igual ao JS, mas a ordem dos parâmetros na chamada difere: `reduce(inicial) { |acc, x| }`).

```ruby
[1, 2, 3].reduce(:+)           # => 6   (símbolo de operador)
[1, 2, 3].sum                  # => 6
[[1, 2], [3]].sum([])          # => [1, 2, 3]
```

### Mais métodos que o JS não tem

```ruby
nums = [1, 2, 3, 4, 5, 6]
nums.partition(&:even?)               # => [[2, 4, 6], [1, 3, 5]]
nums.group_by { |n| n % 3 }           # => { 1 => [1, 4], 2 => [2, 5], 0 => [3, 6] }
nums.each_slice(2).to_a               # => [[1, 2], [3, 4], [5, 6]]
nums.each_cons(2).to_a                # => [[1,2],[2,3],[3,4],[4,5],[5,6]]
nums.take_while { |n| n < 4 }         # => [1, 2, 3]
nums.drop_while { |n| n < 4 }         # => [4, 5, 6]
nums.min_by { |n| (n - 4).abs }       # => 4
nums.sum { |n| n * 2 }                # => 42
nums.zip(%w[a b c d e f])
nums.each_with_object({}) { |n, h| h[n] = n * n }
nums.cycle.first(8)                   # repete infinitamente (lazy)
(1..Float::INFINITY).lazy.map { |n| n * 2 }.first(3)   # => [2, 4, 6]
```

### Encadeamento

```javascript
const total = produtos
  .filter(p => p.estoque > 0)
  .map(p => p.preco * p.estoque)
  .reduce((a, b) => a + b, 0);
```

```ruby
total = produtos
  .select { |p| p[:estoque] > 0 }
  .map { |p| p[:preco] * p[:estoque] }
  .sum
```

## Mutação x não mutação

| Não muta (devolve novo) | Muta (altera o original) |
|-------------------------|--------------------------|
| `map`, `select`, `sort`, `reverse`, `uniq`, `compact`, `flatten` | `map!`, `select!`, `sort!`, `reverse!`, `uniq!`, `compact!`, `flatten!` |
| `+`, `-`, `&`, `\|` | `<<`, `push`, `pop`, `shift`, `unshift`, `concat`, `delete`, `clear` |

🔴 Muitos métodos `!` retornam `nil` quando nada muda (`[1,2].uniq!` → `nil`). Não encadeie métodos `!`.

Em JS, `sort`, `reverse`, `splice`, `push` **mutam**; `map`, `filter`, `slice` não. Em Ruby, o sufixo `!` deixa a mutação explícita.

## Desestruturação e *splat*

```javascript
const [a, b, ...resto] = [1, 2, 3, 4];
const copia = [...nums, 7];
Math.max(...nums);
```

```ruby
a, b, *resto = [1, 2, 3, 4]
copia = [*nums, 7]
nums.max                    # não precisa de splat
```

Em blocos com pares:

```ruby
[[1, :a], [2, :b]].each { |num, letra| puts "#{num}#{letra}" }
[[1, [2, 3]]].each { |a, (b, c)| puts a + b + c }
```

## Arrays multidimensionais

```ruby
matriz = [[1, 2], [3, 4]]
matriz[1][0]                 # => 3
matriz.transpose             # => [[1, 3], [2, 4]]
matriz.flatten               # => [1, 2, 3, 4]
matriz.map { |linha| linha.sum }   # => [3, 7]
```

## Ranges (não existem no JS)

```ruby
(1..5).to_a          # => [1, 2, 3, 4, 5]   (inclusivo)
(1...5).to_a         # => [1, 2, 3, 4]      (exclusivo no fim)
('a'..'e').to_a      # => ["a", "b", "c", "d", "e"]
(1..10).step(3).to_a # => [1, 4, 7, 10]
(1..).first(3)       # => [1, 2, 3]   (sem fim)
(1..5).sum           # => 15
(1..5).each { |n| puts n }
```

Substituem o clássico `Array.from({length: n}, (_, i) => i)`.

## Resumo

- Mesma ideia do JS, vocabulário parecido: `map`, `select` (filter), `reduce`, `find`, `any?` (some), `all?` (every).
- Índices negativos funcionam nativamente; `nil` em vez de `undefined`.
- Métodos sem `!` não alteram o original; com `!` alteram.
- `sort` ordena números corretamente; `sort_by` ordena por critério.
- Ruby oferece `group_by`, `partition`, `tally`, `each_slice`, `zip`, `sum`, `Range` e iteração *lazy*.

## Exercícios

1. Converta para Ruby: `[1,2,3,4].filter(n => n % 2).map(n => n ** 2)`.
2. Dado `[3, 10, 2, 33]`, ordene em Ruby e compare com o resultado de `.sort()` no JS.
3. Agrupe palavras por tamanho usando `group_by` e conte-as com `tally`.
4. Implemente o equivalente de `Object.fromEntries(arr.map(...))` com `to_h`.
5. Mostre a armadilha de `Array.new(3, [])` e corrija.
6. Calcule a soma dos quadrados de 1 a 100 usando um `Range` e `sum`.
7. Com `produtos` (array de hashes), liste os nomes dos que têm estoque, do mais caro ao mais barato.
