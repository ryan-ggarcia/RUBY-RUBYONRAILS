# 15 — Armadilhas comuns de quem vem do JavaScript

Lista das pegadinhas mais frequentes, com o sintoma, a causa e a correção.

## 1. `0` e `""` são verdadeiros

```javascript
if (contador) { ... }       // 0 → falso
```

```ruby
if contador                 # 0 → VERDADEIRO
if contador.positive?       # explícito
if !texto.empty?            # ou texto.present? (Rails)
```

Só `false` e `nil` são falsy.

## 2. `i++` não existe

```ruby
i++      # erro de sintaxe
i += 1   # correto
```

## 3. Divisão inteira trunca

```ruby
7 / 2        # => 3
7 / 2.0      # => 3.5
7.fdiv(2)    # => 3.5
```

## 4. Chaves string x symbol

```ruby
h = { nome: "Ana" }
h["nome"]      # => nil  (a chave é :nome)
h[:nome]       # => "Ana"

dados = JSON.parse('{"nome":"Ana"}')
dados[:nome]   # => nil  (JSON.parse devolve chaves string)
dados["nome"]  # => "Ana"
```

Use `JSON.parse(texto, symbolize_names: true)` quando quiser symbols. No Rails, `HashWithIndifferentAccess` (como `params`) aceita os dois.

## 5. Hash não tem "propriedades"

```ruby
h = { nome: "Ana" }
h.nome        # erro: NoMethodError
h[:nome]      # correto
```

Para usar `obj.nome`, crie uma classe, `Struct` ou `OpenStruct`.

## 6. Método não enxerga variáveis externas

```ruby
taxa = 0.1
def calcular(v) = v * taxa     # NameError
```

Passe como parâmetro, use constante (`TAXA`) ou lambda.

## 7. Número de argumentos é estrito

```ruby
def f(a, b); end
f(1)           # ArgumentError
```

Nada de `undefined` silencioso: use valores padrão (`b = nil`).

## 8. Esquecer o `self.` ao atribuir via setter

```ruby
class Pessoa
  attr_accessor :nome
  def renomear(n)
    nome = n        # variável local! (não altera o atributo)
    self.nome = n   # correto
  end
end
```

## 9. Chamar lambda como função

```ruby
dobrar = ->(x) { x * 2 }
dobrar(3)         # NoMethodError (procura um MÉTODO chamado dobrar)
dobrar.call(3)    # => 6
dobrar.(3)        # => 6
dobrar[3]         # => 6
```

## 10. Referências compartilhadas (mutabilidade)

```ruby
a = "oi"
b = a
b << "!"
a                # => "oi!"   (mesmo objeto)

b = a.dup        # cópia

Array.new(3, [])         # => 3 referências ao MESMO array
Array.new(3) { [] }      # correto

Hash.new([])             # valor padrão compartilhado
Hash.new { |h, k| h[k] = [] }   # correto
```

## 11. `and`/`or` não são `&&`/`||`

```ruby
x = true and false     # x => true (precedência baixíssima)
x = true && false      # x => false
```

Use `&&`/`||`/`!` em condições.

## 12. `return` dentro de bloco

```ruby
def achar(lista)
  lista.each { |x| return x if x > 3 }   # sai do MÉTODO inteiro (útil aqui)
  nil
end

lista.each { |x| next if x.odd?; puts x }  # `next` pula só esta iteração
```

Em lambdas, `return` sai da lambda; em blocos/procs, sai do método externo.

## 13. `puts` x `p` x `print`

```ruby
puts "oi"      # oi\n   (usa to_s)
p "oi"         # "oi"\n (usa inspect; devolve o valor)
print "oi"     # oi     (sem quebra de linha)
puts [1, 2]    # imprime 1 e 2 em linhas separadas
```

Para depurar, use `p`/`pp`.

## 14. Operador `==` compara por valor

```ruby
[1, 2] == [1, 2]            # => true
"a" == "a"                  # => true
"a".equal?("a")             # => false (objetos diferentes)
```

## 15. `sort` (e métodos `!`) e valores de retorno

```ruby
[3, 1, 2].sort              # => [1, 2, 3]   (nova array)
a = [3, 1, 2]
a.sort!                     # altera a
[1, 2, 3].uniq!             # => nil (nada mudou!)
```

Não encadeie métodos `!`; eles podem retornar `nil`.

## 16. `map` com Hash devolve Array

```ruby
h = { a: 1, b: 2 }
h.map { |k, v| [k, v * 2] }           # => [[:a, 2], [:b, 4]]   (Array)
h.map { |k, v| [k, v * 2] }.to_h      # => { a: 2, b: 4 }
h.transform_values { |v| v * 2 }      # => { a: 2, b: 4 }
h.select { |_, v| v > 1 }             # => { b: 2 }            (Hash)
```

## 17. Constantes não são imutáveis

```ruby
LISTA = [1, 2]
LISTA << 3                  # permitido!
LISTA.freeze                # agora congela
LISTA = []                  # só um warning (reatribuição)
```

## 18. `^` e `$` em regex são de linha

```ruby
"ok\n<script>" =~ /^ok$/    # casa (primeira linha)
"ok\n<script>" =~ /\Aok\z/  # não casa (string inteira)
```

Use `\A` e `\z` em validações (segurança).

## 19. Strings simples não interpolam

```ruby
nome = "Ana"
"Oi #{nome}"      # => "Oi Ana"
'Oi #{nome}'      # => "Oi \#{nome}"
```

## 20. Sem coerção implícita

```ruby
"1" + 1           # TypeError
"1" + 1.to_s      # => "11"
1 + "1".to_i      # => 2
```

## 21. `nil` não responde a nada (inclusive `length`)

```ruby
nome = nil
nome.length       # NoMethodError: undefined method 'length' for nil
nome&.length      # => nil
nome.to_s.length  # => 0
```

No Rails: `nome.blank?`, `nome.presence`.

## 22. `for` não cria escopo

```ruby
for i in 1..3; end
i                 # => 3 (vazou!)
(1..3).each { |j| }
j                 # NameError
```

## 23. `puts` de objeto sem `to_s`

```ruby
class A; end
puts A.new        # #<A:0x000...>
```

Defina `to_s` (e `inspect`).

## 24. Ranges: `..` x `...`

```ruby
(1..3).to_a       # => [1, 2, 3]
(1...3).to_a      # => [1, 2]
```

Três pontos **excluem** o fim (como `slice` do JS).

## 25. Espaço antes dos parênteses

```ruby
puts (1 + 2) * 3     # avisos e comportamento inesperado: puts((1 + 2)) * 3
puts((1 + 2) * 3)    # => 9
```

Em chamadas com argumentos que começam com parêntese, use parênteses externos.

## 26. Nomes com maiúscula inicial são constantes

```ruby
Pessoa = 5     # constante (e o Ruby estranha se reatribuir)
pessoa = 5     # variável
def Metodo; end # legal, mas confuso: evite
```

## 27. Parâmetros de bloco com `Hash#each`

```ruby
h.each { |par| p par }       # par é [chave, valor]
h.each { |k, v| p k }        # desestruturado
```

## 28. Ordem de definição

Variáveis precisam existir antes do uso, mas **métodos** podem ser chamados de dentro de outros mesmo se definidos depois (basta existirem na hora da chamada). Ao contrário do JS, **não há hoisting** de variáveis.

```ruby
puts x    # NameError (x não definida ainda)
x = 1
```

## Checklist ao depurar código Ruby escrito "à moda JS"

- [ ] Alguma condição depende de `0`/`""` serem falsos?
- [ ] Usei `h.chave` em um Hash ou chaves string vs symbol?
- [ ] Método usa variável externa?
- [ ] Número de argumentos confere?
- [ ] Uso `self.` nos setters dentro da classe?
- [ ] Há `++`, `===`, `!==`, `function`, `=>` de arrow function por engano?
- [ ] Modifiquei uma string/array compartilhada sem `dup`?

## Resumo

- Ruby é mais rígido (argumentos, tipos) e mais explícito (mutação com `!`, symbol x string).
- O **truthiness** (`0` e `""` verdadeiros) é a diferença que mais causa bugs silenciosos.
- Métodos não fecham sobre variáveis externas; blocos e lambdas, sim.
- `Hash` não tem acesso por ponto; `JSON.parse` devolve chaves string.

## Exercícios

1. Para cada armadilha 1 a 10, escreva um trecho curto que reproduza o erro e outro que o corrija.
2. Reescreva em Ruby este código JS "ingênuo" e corrija todas as armadilhas: `let total = 0; for (let i = 0; i < itens.length; i++) { if (itens[i].qtd) total += itens[i].preco * itens[i].qtd; } console.log(total);`
3. Explique ao colega por que `h["nome"]` retorna `nil` depois de `JSON.parse`.
4. Mostre duas formas de evitar `Hash.new([])` compartilhado.
5. Crie sua própria lista de 5 armadilhas que você encontrou ao praticar.
