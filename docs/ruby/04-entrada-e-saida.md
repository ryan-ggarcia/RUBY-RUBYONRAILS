# 04 — Entrada e saída de dados

Um programa interativo recebe dados do usuário (**entrada**), processa e mostra o resultado (**saída**).

```
Usuário digita  →  programa processa  →  tela exibe o resultado
   gets.chomp                              puts / print / p
```

## Saída

### `puts` — imprime e pula linha

```ruby
puts "Olá, mundo!"
puts 42
puts "a", "b"      # cada argumento em uma linha
puts [1, 2, 3]     # cada elemento do array em uma linha
puts nil           # linha em branco
```

### `print` — imprime sem pular linha

```ruby
print "Digite seu nome: "
print "Ruby"
print "\n"          # pula linha manualmente
```

### `p` — imprime a representação "técnica" (para depuração)

```ruby
p "texto"          # => "texto"  (com aspas)
p :simbolo         # => :simbolo
p nil              # => nil
p [1, "a", :b]     # => [1, "a", :b]
```

Diferença importante:

```ruby
puts "oi"          # oi
p    "oi"          # "oi"
puts nil           # (linha vazia)
p    nil           # nil
```

`p` também **retorna** o valor impresso, o que ajuda a depurar sem quebrar o código:

```ruby
total = p(10 + 5)  # imprime 15 e guarda 15 em total
```

### Resumo das saídas

| Método | Pula linha | Mostra aspas/estrutura | Uso típico |
|--------|-----------|------------------------|-----------|
| `puts` | Sim | Não | Mensagens para o usuário |
| `print` | Não | Não | Prompts na mesma linha |
| `p` | Sim | Sim | Depuração |

### Formatando a saída

```ruby
nome = "Ana"
idade = 30
puts "Nome: #{nome}, idade: #{idade}"        # interpolação
puts "Preço: R$ %.2f" % 19.5                 # => Preço: R$ 19.50
puts format("%05d", 42)                      # => 00042
puts "Ruby".center(20, "*")                  # => ********Ruby********
puts "Item".ljust(10) + "Preço".rjust(8)
```

## Entrada

### `gets` — lê uma linha do teclado

```ruby
puts "Digite seu nome:"
nome = gets
puts "Olá, #{nome}"
```

Problema: `gets` **mantém a quebra de linha** no final. Se o usuário digitar `Ana` e apertar Enter, o valor é `"Ana\n"`.

### `gets.chomp` — lê e remove a quebra de linha

```ruby
print "Digite seu nome: "
nome = gets.chomp      # => "Ana"
puts "Olá, #{nome}!"
```

`chomp` remove a quebra de linha (ou o `\n`) do final da string.

## Tudo que vem do teclado é String

```ruby
print "Digite um número: "
n = gets.chomp
puts n + 1             # erro: TypeError (no implicit conversion of Integer into String)
```

Converta antes de usar:

```ruby
print "Digite um número: "
n = gets.chomp.to_i
puts n + 1
```

| Conversão | Resultado |
|-----------|-----------|
| `.to_i` | Inteiro |
| `.to_f` | Decimal |
| `Integer(...)` | Inteiro, com erro se inválido |
| `Float(...)` | Decimal, com erro se inválido |

### Validando entrada

```ruby
print "Idade: "
entrada = gets.chomp

begin
  idade = Integer(entrada)
  puts "Você tem #{idade} anos."
rescue ArgumentError
  puts "Digite apenas números."
end
```

## Exemplo completo

```ruby
print "Seu nome: "
nome = gets.chomp

print "Sua idade: "
idade = gets.chomp.to_i

puts "Olá, #{nome}! Em 10 anos você terá #{idade + 10} anos."
```

## Lendo vários valores de uma vez

```ruby
print "Digite dois números separados por espaço: "
a, b = gets.chomp.split.map(&:to_i)
puts "Soma: #{a + b}"
```

## Observações

- `gets` retorna `nil` se não houver mais entrada (por exemplo, em um arquivo redirecionado). Para scripts que leem muitas linhas, use `STDIN.each_line`.
- Em programas com Rails, a entrada vem de formulários e requisições HTTP, não de `gets`. Aqui o objetivo é treinar a lógica.

## Resumo

- Saída: `puts` (pula linha), `print` (não pula), `p` (depuração).
- Entrada: `gets`; use `gets.chomp` para remover a quebra de linha.
- A entrada é sempre **String**: converta com `to_i`/`to_f`.

## Exercícios

1. Peça o nome e imprima `Olá, <nome>!`.
2. Peça dois números e imprima a soma, a subtração, a multiplicação e a divisão (com decimais).
3. Peça a temperatura em Celsius e mostre em Fahrenheit (`F = C * 9 / 5 + 32`).
4. Peça uma idade e valide com `Integer()`, tratando o erro com `rescue`.
5. Mostre a diferença entre `puts` e `p` para os valores `"oi"`, `nil` e `[1, 2]`.
