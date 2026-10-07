# 06 — Funções, métodos e blocos

Em JS, funções são valores de primeira classe e existem soltas. Em Ruby, o que você define com `def` é um **método** (pertence a um objeto); os "valores função" são **blocos**, **procs** e **lambdas**.

## Definindo funções/métodos

```javascript
function somar(a, b) {
  return a + b;
}
const somar2 = (a, b) => a + b;
```

```ruby
def somar(a, b)
  a + b              # retorno implícito da última expressão
end

def somar2(a, b) = a + b      # método de uma linha (Ruby 3+)
```

- Sem `return` explícito, devolve a **última expressão avaliada**.
- Parênteses opcionais na chamada: `somar 1, 2` (mas use-os quando houver ambiguidade).
- `return` é usado para **saída antecipada**.

```ruby
def classificar(n)
  return "negativo" if n < 0
  return "zero" if n.zero?
  "positivo"
end
```

## Parâmetros

| Recurso | JavaScript | Ruby |
|---------|-----------|------|
| Valor padrão | `function f(a = 1)` | `def f(a = 1)` |
| Rest/varargs | `function f(...args)` | `def f(*args)` |
| Parâmetros nomeados | objeto desestruturado `f({ a, b })` | `def f(a:, b: 2)` (keyword arguments) |
| Resto nomeado | `f({ a, ...resto })` | `def f(a:, **resto)` |
| Spread na chamada | `f(...lista)` | `f(*lista)` |
| Nº de argumentos | **Flexível** (ignora extras) | **Rígido** (`ArgumentError`) |

🔴 Ruby **exige o número exato** de argumentos:

```javascript
function f(a, b) {}
f(1);            // b = undefined (sem erro)
f(1, 2, 3);      // ignora o 3
```

```ruby
def f(a, b); end
f(1)             # erro: ArgumentError (given 1, expected 2)
f(1, 2, 3)       # erro: ArgumentError (given 3, expected 2)
```

### Argumentos nomeados (*keyword arguments*)

Substituem o padrão JS de passar um objeto de opções:

```javascript
function criarUsuario({ nome, idade = 18, ativo = true }) {
  return { nome, idade, ativo };
}
criarUsuario({ nome: "Ana", idade: 30 });
```

```ruby
def criar_usuario(nome:, idade: 18, ativo: true)
  { nome: nome, idade: idade, ativo: ativo }
end

criar_usuario(nome: "Ana", idade: 30)
criar_usuario(idade: 30, nome: "Ana")     # ordem livre
criar_usuario                              # erro: ArgumentError (missing keyword: :nome)
criar_usuario(nome: "Ana", cor: "azul")    # erro: unknown keyword: :cor
```

`nome:` sem valor é **obrigatório**; com valor é opcional.

### Splat

```ruby
def soma(*numeros) = numeros.sum
soma(1, 2, 3)               # => 6

lista = [1, 2, 3]
soma(*lista)                # espalha o array

def opcoes(**kwargs) = kwargs
opcoes(a: 1, b: 2)          # => { a: 1, b: 2 }

h = { nome: "Ana" }
criar_usuario(**h)          # espalha o hash como argumentos nomeados
```

## Valores de retorno múltiplos

```javascript
function minMax(arr) { return [Math.min(...arr), Math.max(...arr)]; }
const [min, max] = minMax([3, 1, 2]);
```

```ruby
def min_max(arr)
  [arr.min, arr.max]
end
min, max = min_max([3, 1, 2])
# ou: arr.minmax
```

## Blocos: o recurso mais "Ruby"

Um **bloco** é um pedaço de código passado para um método, entre `{ }` ou `do...end`. Equivale ao *callback* do JS, mas é parte da sintaxe da chamada.

```javascript
[1, 2, 3].forEach(n => console.log(n));
[1, 2, 3].map(n => n * 2);
setTimeout(() => console.log("oi"), 1000);
```

```ruby
[1, 2, 3].each { |n| puts n }
[1, 2, 3].map { |n| n * 2 }
```

- `{ ... }` para uma linha; `do ... end` para várias.
- Parâmetros do bloco entre barras `|a, b|`.
- Um método recebe **no máximo um bloco**, sempre como último "argumento" (fora dos parênteses).

```ruby
[1, 2, 3].each do |n|
  dobro = n * 2
  puts dobro
end
```

### Escrevendo métodos que recebem blocos: `yield`

```javascript
function repetir(n, fn) {
  for (let i = 0; i < n; i++) fn(i);
}
repetir(3, i => console.log(i));
```

```ruby
def repetir(n)
  n.times { |i| yield i }
end
repetir(3) { |i| puts i }

def com_log
  puts "início"
  resultado = yield              # executa o bloco
  puts "fim"
  resultado
end
com_log { 42 }                   # => 42

def opcional
  return "sem bloco" unless block_given?
  yield
end
```

### Capturando o bloco como objeto: `&bloco`

```ruby
def aplicar(lista, &fn)
  lista.map(&fn)
end
aplicar([1, 2, 3]) { |n| n * 10 }    # => [10, 20, 30]
```

### `&:símbolo` — atalho para o caso comum

```javascript
nomes.map(n => n.toUpperCase());
```

```ruby
nomes.map { |n| n.upcase }
nomes.map(&:upcase)           # idiomático
```

## Procs e lambdas (funções como valores)

| | JavaScript | Ruby |
|--|-----------|------|
| Arrow function | `const f = x => x * 2` | `f = ->(x) { x * 2 }` (lambda) |
| Chamar | `f(3)` | `f.call(3)` / `f.(3)` / `f[3]` |
| Passar como argumento | `arr.map(f)` | `arr.map(&f)` |

```javascript
const dobrar = x => x * 2;
dobrar(4);                       // 8
[1, 2].map(dobrar);
const compose = (f, g) => x => f(g(x));
```

```ruby
dobrar = ->(x) { x * 2 }
dobrar.call(4)                   # => 8
dobrar.(4)                       # => 8
dobrar[4]                        # => 8
[1, 2].map(&dobrar)              # => [2, 4]

compose = ->(f, g) { ->(x) { f.(g.(x)) } }
(dobrar >> ->(x) { x + 1 }).call(3)    # composição: 7
```

Você **não** chama uma lambda apenas escrevendo `dobrar(4)`: isso procuraria um *método* chamado `dobrar`.

### Lambda x Proc

| | `lambda` / `->` | `Proc.new` / `proc` |
|--|----------------|---------------------|
| Verifica nº de argumentos | **Sim** (estrito, como método) | Não (flexível, como o JS) |
| `return` | Sai **da lambda** | Sai do **método** que a cercou |

```ruby
l = ->(a, b) { a + b }
l.call(1)                  # ArgumentError

p = proc { |a, b| [a, b] }
p.call(1)                  # => [1, nil]
```

Na prática, use **lambdas** quando precisar de um valor-função e **blocos** para callbacks.

### Referenciar um método existente

```javascript
const f = Math.sqrt;
[4, 9].map(Math.sqrt);
```

```ruby
f = Math.method(:sqrt)
[4, 9].map(&Math.method(:sqrt))    # => [2.0, 3.0]
```

## Closures

Blocos, procs e lambdas **capturam** as variáveis do escopo onde nasceram (como closures JS). Métodos `def` **não**.

```javascript
function contador() {
  let c = 0;
  return () => ++c;
}
```

```ruby
def contador
  c = 0
  -> { c += 1 }
end

prox = contador
prox.call   # => 1
prox.call   # => 2
```

## Funções soltas: onde elas vivem?

Um `def` no nível principal do arquivo cria um método **privado em `Object`**, acessível em todo lugar (parecido com função global). Em programas organizados, métodos ficam dentro de **classes** ou **módulos**:

```ruby
module Matematica
  def self.quadrado(n) = n * n
end

Matematica.quadrado(4)   # => 16
```

## Métodos com `?`, `!` e `=`

```ruby
def par?(n) = n.even?         # pergunta: retorna booleano
def normalizar!(texto) = texto.strip!   # "perigoso": altera o objeto
def nome=(valor); @nome = valor; end    # setter
```

## Recursão e valor padrão calculado

```ruby
def fatorial(n) = n <= 1 ? 1 : n * fatorial(n - 1)

def saudar(nome, saudacao = "Olá #{nome}")   # padrões podem usar parâmetros anteriores
  "#{saudacao}!"
end
```

## Resumo

- `def ... end` define **métodos**; a última expressão é o retorno.
- Ruby é rígido com o **número de argumentos**; use `*args`, `**opts` e argumentos nomeados (`nome:`).
- **Blocos** (`{ |x| ... }`) são os callbacks; `yield` os executa; `&:metodo` é o atalho.
- Para funções como valores use **lambdas** (`->(x) { }`) e chame com `.call`/`.()`.
- Blocos/lambdas fecham sobre o escopo (closure); `def` não.

## Exercícios

1. Converta `const mult = (a, b = 2) => a * b;` para um método Ruby com valor padrão.
2. Escreva `def criar_pedido(cliente:, itens:, desconto: 0)` e chame-o em ordens diferentes.
3. Implemente `repetir(n) { |i| ... }` usando `yield`.
4. Transforme `['a','b'].map(s => s.toUpperCase())` em Ruby de duas formas (bloco e `&:`).
5. Crie uma lambda `somar_n = ->(n) { ->(x) { x + n } }` e use-a com `map`.
6. Demonstre a diferença de `ArgumentError` entre lambda e proc.
7. Explique por que o código `taxa = 0.1; def calc(v) = v * taxa` falha.
