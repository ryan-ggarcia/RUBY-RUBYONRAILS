# 01 — Origem e filosofia do Ruby

## Visão geral

Ruby é uma linguagem de programação **interpretada**, **dinâmica**, **open source** e **totalmente orientada a objetos**. Foi criada para que escrever código seja agradável e produtivo.

## Quem criou e quando

- **Criador:** Yukihiro Matsumoto, conhecido como **Matz**, no Japão.
- **Primeira versão pública:** 1995.
- **Motivação:** Matz queria uma linguagem mais poderosa que Perl e mais orientada a objetos que Python. A frase que resume essa ideia é frequentemente atribuída a ele:

> "Eu queria uma linguagem interpretada que fosse mais poderosa do que Perl e mais orientada a objetos do que Python."

## De onde vêm as ideias

Ruby combina características de várias linguagens:

| Influência | O que Ruby herdou |
|------------|-------------------|
| Smalltalk | Tudo é objeto; troca de mensagens entre objetos |
| Perl | Praticidade para texto e scripts |
| Lisp | Funções como valores, blocos, programação funcional |
| Eiffel e Ada | Ideias de tratamento de exceções e legibilidade |

O resultado é uma linguagem **multiparadigma**: você pode escrever de forma orientada a objetos, funcional ou imperativa, conforme o problema.

## Tudo é objeto

Até valores que em outras linguagens são "primitivos" são objetos em Ruby, e têm métodos:

```ruby
5.class          # => Integer
3.14.class       # => Float
"texto".class    # => String
:simbolo.class   # => Symbol
nil.class        # => NilClass
true.class       # => TrueClass

5.even?          # => false
-7.abs           # => 7
"ruby".upcase    # => "RUBY"
nil.to_a         # => []
```

Isso torna a linguagem muito consistente: para saber o que você pode fazer com um valor, basta perguntar quais métodos ele tem (`5.methods`).

## A filosofia: felicidade do programador

Matz projetou Ruby pensando primeiro em **pessoas**, não em máquinas. Os pilares:

1. **Felicidade do programador** — escrever código deve ser prazeroso.
2. **Simplicidade** — sintaxe limpa, com pouca cerimônia (sem ponto e vírgula, parênteses opcionais).
3. **Produtividade** — fazer mais com menos código.
4. **Legibilidade** — o código se lê quase como uma frase.
5. **Elegância** — soluções expressivas e naturais.

### Princípio da menor surpresa

A linguagem tenta se comportar do jeito que o programador espera depois de se acostumar com ela. Por isso muitos métodos têm nomes intuitivos e perguntas terminam com `?`:

```ruby
[1, 2, 3].empty?     # => false
"ruby".include?("u") # => true
10.zero?             # => false
```

### Código que se lê como texto

Compare a mesma ideia em duas formas:

```ruby
# Estilo "tradicional"
if !(idade >= 18)
  puts "menor de idade"
end

# Estilo Ruby
puts "menor de idade" unless idade >= 18

# Repetição
5.times { puts "Olá!" }
```

## Como Ruby é executado

- É **interpretada**: você escreve o código e o interpretador o executa direto, sem passo manual de compilação.
- A implementação oficial é o **CRuby** (também chamada MRI).
- Existem outras, como **JRuby** (roda na JVM) e **TruffleRuby**.
- Tem **tipagem dinâmica**: o tipo é do valor, não da variável.

## Onde Ruby é usado

- **Web:** Ruby on Rails (usado por empresas como Shopify, GitHub e Basecamp).
- **Automação e DevOps:** scripts, Homebrew, Chef, Puppet.
- **Testes:** RSpec, Capybara.
- **Sites estáticos:** Jekyll.
- **Ferramentas de desenvolvimento:** Fastlane e vários utilitários de linha de comando.

## Pontos fortes e limitações

| Pontos fortes | Limitações |
|---------------|-----------|
| Sintaxe expressiva e legível | Em geral mais lenta que linguagens compiladas |
| Ecossistema de gems maduro | Consumo de memória maior em alguns cenários |
| Rails acelera muito o desenvolvimento web | Tipagem dinâmica exige disciplina e testes |
| Comunidade acolhedora | Menos usada em áreas como ciência de dados e mobile |

## Resumo

- Criada por **Matz**, lançada em **1995**.
- **Tudo é objeto**; linguagem multiparadigma e interpretada.
- Filosofia central: **felicidade do programador**, simplicidade e legibilidade.

## Exercícios

1. Abra o `irb` e descubra a classe de: `42`, `4.2`, `"42"`, `:quarenta_e_dois`, `nil`, `[42]`, `{ a: 42 }` e `(1..42)`.
2. Use `42.methods.sort.first(10)` para ver alguns métodos de um número. Escolha três e teste.
3. Reescreva em estilo Ruby: `if !(x == 0) then puts "diferente" end`.
