# 07 — Estruturas condicionais

Condicionais permitem que o programa tome decisões: executar um trecho **apenas se** uma condição for verdadeira.

Lembre-se: em Ruby, só `false` e `nil` são falsos. `0`, `""` e `[]` são **verdadeiros**.

## `if`, `elsif`, `else`

```ruby
idade = 15

if idade >= 18
  puts "Adulto"
elsif idade >= 12
  puts "Adolescente"
else
  puts "Criança"
end
```

Pontos importantes:

- Termina com `end`.
- É `elsif` (sem o segundo "e").
- Não há parênteses obrigatórios nem chaves.
- Opcionalmente, você pode usar `then` para escrever em uma linha: `if x > 0 then puts "positivo" end`.

### `if` é uma expressão (retorna valor)

```ruby
categoria = if idade >= 18
              "adulto"
            else
              "menor"
            end
```

## `unless` — "a não ser que"

É o oposto do `if`: executa quando a condição é **falsa**.

```ruby
unless usuario_ativo
  puts "Usuário inativo"
end

# equivalente a:
if !usuario_ativo
  puts "Usuário inativo"
end
```

Boas práticas:

- Use `unless` para condições simples e negativas.
- Evite `unless ... else` e condições complexas com `unless`; fica difícil de ler. Prefira `if`.

## Forma de modificador (uma linha)

```ruby
puts "Maior de idade" if idade >= 18
puts "Sem acesso" unless autorizado
```

Ótimo para checagens curtas. Evite se a linha ficar longa.

### Cláusula de guarda

Sair cedo de um método reduz aninhamento:

```ruby
def desconto(preco, cliente)
  return 0 if cliente.nil?
  return 0 unless cliente.ativo?

  preco * 0.1
end
```

## Operador ternário

```ruby
mensagem = idade >= 18 ? "Pode entrar" : "Acesso negado"
```

Formato: `condição ? valor_se_verdadeiro : valor_se_falso`. Use para casos simples; não aninhe ternários.

## `case` / `when`

Compara um valor com várias opções. É a alternativa a muitos `elsif`.

```ruby
dia = 3

case dia
when 1
  puts "Domingo"
when 2
  puts "Segunda"
when 3
  puts "Terça"
else
  puts "Outro dia"
end
```

Diferenças em relação ao `switch` de outras linguagens:

- **Não precisa de `break`**: só um `when` é executado.
- Aceita **vários valores** por `when`, **intervalos**, **classes**, **regex** e mais.
- O `case` também **retorna um valor**.

### Vários valores

```ruby
case dia
when 1, 7
  puts "Fim de semana"
when 2..6
  puts "Dia útil"
end
```

### Intervalos (muito comum)

```ruby
nota = 7.5

conceito = case nota
           when 9..10 then "A"
           when 7...9 then "B"
           when 5...7 then "C"
           else "D"
           end
# => "B"
```

### Por classe

```ruby
valor = 42

case valor
when Integer then puts "número inteiro"
when String  then puts "texto"
when nil     then puts "nada"
end
```

### Por expressão regular

```ruby
email = "ana@exemplo.com"

case email
when /@gmail\.com\z/ then puts "Gmail"
when /@exemplo\.com\z/ then puts "Exemplo"
end
```

### `case` sem valor

```ruby
case
when idade < 12 then puts "criança"
when idade < 18 then puts "adolescente"
else puts "adulto"
end
```

### Como funciona por baixo

O `when` usa o operador `===`. Por isso `(1..5) === 3` é `true` e `Integer === 3` é `true`.

## Pattern matching (`case ... in`)

Disponível desde o Ruby 3, permite "desmontar" estruturas:

```ruby
pedido = { cliente: "Ana", itens: 3 }

case pedido
in { cliente: String => nome, itens: Integer => n } if n > 0
  puts "#{nome} comprou #{n} itens"
else
  puts "pedido inválido"
end
```

Útil para processar dados aninhados (como respostas de API). Não é necessário dominar agora.

## Métodos que ajudam nas condições

```ruby
nil.nil?          # => true
"".empty?         # => true
[].empty?         # => true
5.zero?           # => false
5.positive?       # => true
5.between?(1, 10) # => true
"ruby".start_with?("ru")  # => true
[1, 2].any? { |n| n > 1 } # => true
```

## Armadilhas

### Atribuição em vez de comparação

```ruby
if x = 5      # atribui 5 a x (e é sempre verdadeiro) — Ruby avisa
if x == 5     # compara
```

### Truthiness diferente de outras linguagens

```ruby
puts "executa" if 0      # executa
puts "executa" if ""     # executa
puts "não executa" if nil
```

### `elsif`, não `else if`

`else if` abriria um novo `if` aninhado que exigiria outro `end`.

## Resumo

| Estrutura | Quando usar |
|-----------|-------------|
| `if / elsif / else` | Decisões com várias condições |
| `unless` | Condição simples negativa |
| Modificador (`x if y`) | Checagens curtas de uma linha |
| Ternário | Escolher entre dois valores |
| `case / when` | Comparar um valor com várias opções |

## Exercícios

1. Peça a idade e informe: criança (até 11), adolescente (12–17) ou adulto (18+).
2. Peça uma nota de 0 a 10 e informe: aprovado (≥ 7), recuperação (5 a 6.9) ou reprovado (< 5).
3. Com `unless`, informe "Número inválido" se o valor digitado for negativo; senão, exiba o número.
4. Com `case/when`, peça um número de 1 a 7 e mostre o dia da semana.
5. Crie um menu de lanchonete com `case` (1 = Hambúrguer, 2 = Pizza, 3 = Suco, outro = "Opção inválida").
6. Reescreva o exercício 2 usando `case` com intervalos.
