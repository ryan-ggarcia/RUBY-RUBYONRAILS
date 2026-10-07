# 08 — Loops (estruturas de repetição)

Loops repetem um trecho de código várias vezes. Em Ruby, o estilo mais idiomático é **iterar sobre coleções** com `each`, `times` e afins, em vez de contar índices manualmente.

## `while` — enquanto a condição for verdadeira

```ruby
i = 0
while i < 5
  puts i
  i += 1
end
```

Cuidado: se a condição nunca ficar falsa, o loop é infinito.

### `begin ... end while` (executa pelo menos uma vez)

```ruby
tentativas = 0
begin
  tentativas += 1
  puts "Tentativa #{tentativas}"
end while tentativas < 3
```

## `until` — até a condição ser verdadeira

Oposto do `while`:

```ruby
i = 0
until i == 5
  puts i
  i += 1
end
```

## `for` — percorre uma coleção ou intervalo

```ruby
for i in 1..5
  puts i
end

for fruta in ["maçã", "uva"]
  puts fruta
end
```

Observação: o `for` **não cria um novo escopo**. A variável (`i`, `fruta`) continua existindo depois do loop. Por isso muitos rubistas preferem `each`.

## `loop` — repete até um `break`

```ruby
loop do
  print "Digite 'sair': "
  entrada = gets.chomp
  break if entrada == "sair"
  puts "Você digitou #{entrada}"
end
```

Útil para menus e para "repetir até acertar".

## `times` — repete N vezes

```ruby
5.times { puts "Olá!" }

5.times do |i|
  puts "Volta #{i}"    # i vai de 0 a 4
end
```

## `each` — percorre cada elemento

```ruby
[10, 20, 30].each { |n| puts n }

(1..3).each do |n|
  puts n * 2
end

{ a: 1, b: 2 }.each do |chave, valor|
  puts "#{chave} = #{valor}"
end
```

### `each_with_index`

```ruby
%w[a b c].each_with_index do |letra, i|
  puts "#{i}: #{letra}"
end
# 0: a
# 1: b
# 2: c
```

## `upto`, `downto` e `step`

```ruby
1.upto(5) { |n| print n, " " }      # 1 2 3 4 5
5.downto(1) { |n| print n, " " }    # 5 4 3 2 1
0.step(20, 5) { |n| print n, " " }  # 0 5 10 15 20
(0..1).step(0.25) { |x| puts x }    # 0.0 0.25 0.5 0.75 1.0
```

## Controle de fluxo dentro de loops

| Palavra | Efeito |
|---------|--------|
| `break` | Sai do loop imediatamente |
| `next` | Pula para a próxima iteração (equivale a `continue` de outras linguagens) |
| `redo` | Repete a iteração atual sem reavaliar a condição (raro) |
| `retry` | Reexecuta um bloco `begin/rescue` (não é de loop) |

```ruby
(1..10).each do |n|
  next if n.odd?     # pula os ímpares
  break if n > 8     # para depois do 8
  puts n
end
# 2, 4, 6, 8
```

`break` pode devolver um valor:

```ruby
primeiro_multiplo = (1..100).each do |n|
  break n if n % 7 == 0 && n % 5 == 0
end
# => 35
```

## Qual loop usar?

| Situação | Melhor escolha |
|----------|----------------|
| Percorrer coleção | `each` |
| Repetir N vezes | `times` |
| Percorrer com índice | `each_with_index` |
| Repetir até uma condição mudar | `while` / `until` |
| Repetir "para sempre" com saída manual | `loop` + `break` |
| Transformar ou filtrar elementos | `map`, `select` ([doc 12](12-iteracoes.md)) |

## Exemplos práticos

### Tabuada

```ruby
print "Número: "
n = gets.chomp.to_i

1.upto(10) do |i|
  puts "#{n} x #{i} = #{n * i}"
end
```

### Somar até digitar zero

```ruby
soma = 0
loop do
  print "Número (0 para parar): "
  n = gets.chomp.to_i
  break if n.zero?
  soma += n
end
puts "Soma: #{soma}"
```

### Contagem regressiva

```ruby
10.downto(1) { |n| puts n }
puts "Lançamento!"
```

### Loops aninhados

```ruby
1.upto(3) do |linha|
  1.upto(3) do |coluna|
    print "#{linha * coluna}\t"
  end
  puts
end
```

## Armadilhas

1. **Loop infinito** com `while` quando esquece de atualizar a variável de controle.
2. **Alterar o array enquanto o percorre** com `each` (pode pular elementos). Prefira criar um novo array com `select`/`reject`/`map`.
3. **Usar `for` esperando escopo próprio**: a variável vaza para fora.
4. **Confundir `next` com `break`**: `next` pula só a iteração atual; `break` encerra o loop.

## Resumo

- Prefira `each` e `times`; use `while`/`until` quando a condição é o que importa.
- `loop do ... end` + `break` para repetições com saída manual.
- `break` sai, `next` pula a iteração.
- `for` não cria escopo próprio.

## Exercícios

1. Exiba os números de 1 a 10 com `while`.
2. Exiba a tabuada de um número com `times` (ou `upto`).
3. Dado `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`, use `each` para exibir apenas os pares.
4. Faça uma contagem regressiva de 10 a 0 e, ao final, exiba "Lançamento!".
5. Escreva um jogo de adivinhação: sorteie um número de 1 a 20 (`rand(1..20)`), peça palpites num `loop` e diga "maior" ou "menor" até acertar, mostrando o número de tentativas.
6. Calcule o fatorial de um número com `while` e depois com `(1..n).reduce(:*)`.
