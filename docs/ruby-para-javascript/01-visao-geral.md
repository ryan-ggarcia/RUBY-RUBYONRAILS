# 01 — Visão geral e mentalidade

## Duas linguagens parecidas, duas filosofias

Ruby e JavaScript são ambas **dinâmicas**, **interpretadas** (JS também é compilada JIT), com **garbage collector**, funções de ordem superior e muita flexibilidade. A diferença está no desenho:

| | JavaScript | Ruby |
|--|-----------|------|
| Criação | 1995 (Brendan Eich) | 1995 (Yukihiro "Matz" Matsumoto) |
| Foco original | Scripts no navegador | Felicidade do programador, expressividade |
| Paradigma | Multiparadigma, **baseado em protótipos** | **Orientado a objetos puro** (+ funcional) |
| Tipagem | Dinâmica, **fraca** (coerção implícita) | Dinâmica, **forte** (sem coerção implícita) |
| Execução | Navegador, Node.js, Deno, Bun | Interpretador `ruby` (MRI/YARV) |
| Concorrência | Event loop de thread única + async | Threads, Fibers, Ractors (GVL na MRI) |
| Web típico | Express, Next.js, Nest | **Rails**, Sinatra |
| Gerenciador de pacotes | npm / yarn / pnpm | RubyGems + Bundler |

## "Tudo é objeto" em Ruby

Em JS, números, strings e booleanos são **primitivos** (embrulhados em objetos quando necessário). Em Ruby, **tudo** é objeto, inclusive `nil`, números e classes:

```javascript
(5).toString()           // funciona por "boxing"
typeof null              // "object" (bug histórico)
```

```ruby
5.to_s                   # => "5"
5.class                  # => Integer
nil.class                # => NilClass
true.class               # => TrueClass
Integer.class            # => Class
5.times { |i| puts i }   # número com método de iteração
```

Em Ruby você **chama métodos em tudo**, o que dá aquele estilo "fluente":

```ruby
3.times.map { |i| i * 2 }       # => [0, 2, 4]
"ruby".capitalize.center(10, "*")
10.clamp(1, 5)                   # => 5
```

## Ruby é "mensagens para objetos"

Chamar `obj.metodo` em Ruby é **enviar uma mensagem** ao objeto. Isso explica:

- Operadores são métodos: `1 + 2` é `1.+(2)`.
- Parênteses são opcionais: `puts "oi"` = `puts("oi")`.
- Não há "propriedades" públicas: o acesso é sempre por método (`pessoa.nome` chama o método `nome`).

```ruby
1 + 2          # => 3
1.+(2)         # => 3   (idêntico)
[1, 2, 3].send(:sum)   # => 6   (enviar mensagem dinamicamente)
```

## Execução e ferramentas

| Tarefa | Node/JS | Ruby |
|--------|---------|------|
| Rodar arquivo | `node app.js` | `ruby app.rb` |
| REPL | `node` | `irb` (ou `pry`) |
| Instalar pacote | `npm install lodash` | `gem install nokogiri` / `bundle add nokogiri` |
| Instalar deps do projeto | `npm install` | `bundle install` |
| Manifesto | `package.json` | `Gemfile` |
| Lockfile | `package-lock.json` | `Gemfile.lock` |
| Rodar scripts do projeto | `npm run dev` | `bin/rails server`, `bundle exec rake ...` |
| Testes | Jest, Vitest | Minitest, RSpec |
| Linter/formatador | ESLint, Prettier | RuboCop |
| Gerenciar versões | nvm, fnm | rbenv, asdf, mise |
| Documentação | MDN | ruby-doc.org, `ri` |

## "Hello, world"

```javascript
console.log("Olá, mundo!");
```

```ruby
puts "Olá, mundo!"
```

Sem ponto e vírgula, sem parênteses obrigatórios, sem `console.`.

## Princípios do Ruby que ajudam

1. **Princípio da menor surpresa** (para o Matz): o código deve fazer o que você espera.
2. **Legibilidade**: métodos terminados em `?` (perguntas) e `!` (cuidado), blocos `do...end`.
3. **Há mais de uma forma de fazer** (TIMTOWTDI): `map` / `collect`, `select` / `filter`.
4. **Convenção sobre configuração** (traço forte no Rails).
5. **Retorno implícito**: a última expressão é o valor devolvido.
6. **Quase tudo é expressão**: `if`, `case`, `begin` retornam valores.

```ruby
nota = 7
situacao = if nota >= 6 then "aprovado" else "reprovado" end
situacao   # => "aprovado"
```

## Quadro de equivalências rápidas

| JavaScript | Ruby |
|-----------|------|
| `console.log(x)` | `puts x` / `p x` |
| `let x = 1` | `x = 1` |
| `const PI = 3.14` | `PI = 3.14` (constante) |
| `null`, `undefined` | `nil` |
| `===` | `==` (e `.equal?` para identidade) |
| `&&`, `\|\|`, `!` | `&&`, `\|\|`, `!` (e `and`, `or`, `not`) |
| `` `Olá ${nome}` `` | `"Olá #{nome}"` |
| `[1,2].map(x => x*2)` | `[1,2].map { \|x\| x * 2 }` |
| `{ a: 1 }` | `{ a: 1 }` (**Hash**, não objeto) |
| `function f(a) { }` | `def f(a) ... end` |
| `class A extends B` | `class A < B` |
| `this` | `self` |
| `try/catch/finally` | `begin/rescue/ensure` |
| `import x from "y"` | `require "y"` |
| `typeof x` | `x.class` |
| `arr.length` | `arr.length` / `arr.size` |

Os detalhes de cada linha estão nos próximos documentos.

## Resumo

- Ruby é orientado a objetos "até o fim": tudo é objeto, chamar método é enviar mensagem.
- Tipagem forte: não há coerção implícita entre tipos (`"1" + 1` dá erro).
- Sem `;`, `{}` de bloco de código, `let/const`; usa `end`.
- A última expressão é o retorno; `if`/`case` são expressões.
- O ferramental espelha o do JS (REPL, gerenciador de pacotes, lockfile, linter).

## Exercícios

1. No `irb`, descubra a classe de `5`, `5.0`, `"a"`, `:a`, `nil`, `[]`, `{}` e `1..3`.
2. Reescreva em Ruby: `console.log([1,2,3].map(n => n * 2))`.
3. Demonstre que `1 + 2` e `1.+(2)` são equivalentes.
4. Explique em uma frase a diferença entre tipagem fraca (JS) e forte (Ruby), com o exemplo `"1" + 1`.
5. Use `if` como expressão para atribuir `"par"` ou `"ímpar"` a uma variável.
