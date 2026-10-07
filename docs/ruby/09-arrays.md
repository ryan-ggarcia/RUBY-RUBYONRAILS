# 09 — Arrays

Um **Array** é uma **lista ordenada** de elementos, acessados por **posição** (índice), que começa em **zero**. Pode misturar tipos.

```ruby
frutas = ["maçã", "banana", "uva"]
misto  = ["texto", 10, true, 3.14, [1, 2]]
vazio  = []
```

## Criando arrays

```ruby
[1, 2, 3]                 # literal
%w[maçã banana uva]       # array de strings (sem aspas e vírgulas)
%i[a b c]                 # array de symbols
Array.new(3)              # => [nil, nil, nil]
Array.new(3, 0)           # => [0, 0, 0]
(1..5).to_a               # => [1, 2, 3, 4, 5]
"a b c".split             # => ["a", "b", "c"]
```

### Armadilha: objeto compartilhado

```ruby
a = Array.new(3, [])       # os 3 elementos são o MESMO array
a[0] << "x"
a                          # => [["x"], ["x"], ["x"]]

b = Array.new(3) { [] }    # cada elemento é um array novo (use o bloco)
b[0] << "x"
b                          # => [["x"], [], []]
```

## Acessando elementos

```ruby
frutas = ["maçã", "banana", "uva", "pera"]

frutas[0]        # => "maçã"      (primeiro)
frutas[1]        # => "banana"
frutas[-1]       # => "pera"      (último)
frutas[-2]       # => "uva"
frutas[10]       # => nil         (fora do alcance, sem erro)
frutas.first     # => "maçã"
frutas.last      # => "pera"
frutas.first(2)  # => ["maçã", "banana"]
frutas.last(2)   # => ["uva", "pera"]
frutas[1, 2]     # => ["banana", "uva"]  (início, quantidade)
frutas[1..2]     # => ["banana", "uva"]  (intervalo)
frutas[1..]      # => ["banana", "uva", "pera"]
frutas.fetch(10) # erro: IndexError (use fetch para falhar explicitamente)
frutas.fetch(10, "padrão")  # => "padrão"
```

Acesso aninhado:

```ruby
matriz = [[1, 2], [3, 4]]
matriz[1][0]        # => 3
matriz.dig(1, 0)    # => 3 (seguro: retorna nil se algo faltar)
```

## Adicionando elementos

```ruby
lista = [1, 2, 3]

lista.push(4)        # => [1, 2, 3, 4]    (também: lista << 4)
lista << 5           # => [1, 2, 3, 4, 5]
lista.unshift(0)     # => [0, 1, 2, 3, 4, 5]  (no início)
lista.insert(2, 99)  # => [0, 1, 99, 2, 3, 4, 5]  (na posição 2)
lista.concat([6, 7]) # junta outro array
```

## Removendo elementos

```ruby
lista = [10, 20, 30, 40, 50]

lista.pop            # => 50   remove e retorna o último
lista.shift          # => 10   remove e retorna o primeiro
lista.delete(30)     # remove todas as ocorrências do valor 30
lista.delete_at(0)   # remove pelo índice
lista.clear          # esvazia
```

```ruby
[1, nil, 2, nil].compact          # => [1, 2]   (remove nil)
[1, 2, 2, 3, 3].uniq              # => [1, 2, 3]
[1, 2, 3, 4].delete_if(&:even?)   # => [1, 3]
```

## Consultando

```ruby
lista = [3, 1, 4, 1, 5]

lista.size            # => 5   (também: length, count)
lista.empty?          # => false
lista.include?(4)     # => true
lista.index(4)        # => 2   (posição do primeiro 4)
lista.count(1)        # => 2   (quantas vezes aparece)
lista.min             # => 1
lista.max             # => 5
lista.sum             # => 14
lista.minmax          # => [1, 5]
lista.any? { |n| n > 4 }   # => true
lista.all? { |n| n > 0 }   # => true
lista.none? { |n| n > 9 }  # => true
```

## Transformando

```ruby
lista = [3, 1, 4, 1, 5]

lista.sort                      # => [1, 1, 3, 4, 5]
lista.sort.reverse              # => [5, 4, 3, 1, 1]
lista.sort { |a, b| b <=> a }   # => [5, 4, 3, 1, 1]
lista.reverse                   # => [5, 1, 4, 1, 3]
lista.uniq                      # => [3, 1, 4, 5]
lista.shuffle                   # ordem aleatória
lista.sample                    # elemento aleatório
lista.rotate                    # => [1, 4, 1, 5, 3]
lista.take(2)                   # => [3, 1]
lista.drop(2)                   # => [4, 1, 5]
lista.join("-")                 # => "3-1-4-1-5"
[[1, 2], [3, [4]]].flatten      # => [1, 2, 3, 4]
%w[b a c].sort_by { |l| l }     # => ["a", "b", "c"]
%w[ccc a bb].sort_by(&:length)  # => ["a", "bb", "ccc"]
```

## Operações entre arrays

```ruby
a = [1, 2, 3]
b = [3, 4]

a + b        # => [1, 2, 3, 3, 4]   (concatena)
a - b        # => [1, 2]            (diferença)
a & b        # => [3]               (interseção)
a | b        # => [1, 2, 3, 4]      (união)
a * 2        # => [1, 2, 3, 1, 2, 3]
a.zip(b)     # => [[1, 3], [2, 4], [3, nil]]
a.product([:x, :y])   # => combinações
[1, 2, 3].combination(2).to_a  # => [[1,2],[1,3],[2,3]]
```

## Métodos com `!` (alteram o próprio array)

```ruby
lista = [3, 1, 2]

lista.sort      # => [1, 2, 3]  (lista continua [3, 1, 2])
lista.sort!     # altera a própria lista
lista           # => [1, 2, 3]
```

Padrão: método sem `!` retorna uma **cópia**; com `!` modifica o **original**.

## Iterando

```ruby
frutas.each { |f| puts f }
frutas.each_with_index { |f, i| puts "#{i}: #{f}" }
frutas.each_slice(2) { |par| p par }   # de 2 em 2
frutas.each_cons(2) { |par| p par }    # janelas deslizantes
```

Veja o [doc 12](12-iteracoes.md) para `map`, `select`, `reduce` e outros.

## Desestruturação

```ruby
primeiro, segundo = [10, 20, 30]
primeiro, *resto = [10, 20, 30]     # resto => [20, 30]
*inicio, ultimo = [10, 20, 30]      # ultimo => 30
```

## Igualdade e cópia

```ruby
[1, 2] == [1, 2]       # => true  (compara conteúdo)

a = [1, 2]
b = a                   # mesma referência!
b << 3
a                       # => [1, 2, 3]

c = a.dup               # cópia rasa
c << 4
a                       # => [1, 2, 3]
```

Para copiar arrays aninhados em profundidade, use `Marshal.load(Marshal.dump(a))` ou cópias explícitas de cada nível.

## Resumo

- Arrays são listas ordenadas, indexadas a partir de 0; índices negativos contam do fim.
- Acesso fora do alcance retorna `nil`; `fetch` falha explicitamente.
- `push`/`<<`, `pop`, `shift`, `unshift` adicionam e removem nas pontas.
- Métodos com `!` modificam o original.
- Prefira `Array.new(n) { ... }` ao criar arrays de objetos mutáveis.

## Exercícios

1. Crie um array com 5 frutas. Exiba a primeira e a última, adicione uma ao final, remova a primeira e exiba o resultado.
2. Dado `[3, 7, 12, 15, 20, 25]`, mostre o tamanho e se contém o `15`.
3. Ordene `["Carlos", "Ana", "Bruno", "Diana"]` em ordem alfabética e depois invertida.
4. Remova duplicados e `nil` de `[1, nil, 2, 2, nil, 3, 1]`.
5. Dado `[4, 8, 15, 16, 23, 42]`, mostre o maior, o menor, a soma e a média.
6. Junte `["a", "b", "c"]` em `"a, b, c"`.
