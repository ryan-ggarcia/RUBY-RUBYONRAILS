# 02 — Sintaxe e variáveis

## Estrutura básica

| | JavaScript | Ruby |
|--|-----------|------|
| Fim de instrução | `;` (opcional via ASI) | Quebra de linha |
| Blocos | `{ ... }` | `... end` |
| Parênteses em chamadas | Obrigatórios | Opcionais |
| Indentação | Convenção | Convenção (2 espaços) |
| Comentário de linha | `// texto` | `# texto` |
| Comentário de bloco | `/* ... */` | `=begin ... =end` (raro) |

```javascript
function saudar(nome) {
  if (nome) {
    console.log(`Olá, ${nome}`);
  }
}
```

```ruby
def saudar(nome)
  if nome
    puts "Olá, #{nome}"
  end
end
```

## Declaração de variáveis

JS tem `var`, `let` e `const`. Ruby **não declara**: basta atribuir.

```javascript
let idade = 30;
idade = 31;
const PI = 3.14;
```

```ruby
idade = 30
idade = 31
PI = 3.14        # constante (começa com maiúscula)
```

Ruby não diferencia "criar" e "reatribuir". Cuidado com erros de digitação: `idadee = 5` cria **outra** variável silenciosamente.

### Constantes

🔴 Em JS, `const` impede **reatribuição**. Em Ruby, constante (nome em MAIÚSCULAS) emite apenas um **aviso** se você reatribuir, e **não impede mutação** do objeto:

```javascript
const lista = [1, 2];
lista.push(3);        // permitido (mutação)
lista = [];           // TypeError
```

```ruby
LISTA = [1, 2]
LISTA << 3            # permitido
LISTA = []            # warning: already initialized constant
LISTA.freeze          # agora a mutação também falha
```

Para congelar de verdade: `.freeze` (ou `# frozen_string_literal: true` no topo do arquivo).

## Convenções de nome

| Tipo | JavaScript | Ruby |
|------|-----------|------|
| Variável / função | `camelCase` | `snake_case` |
| Classe | `PascalCase` | `PascalCase` (CamelCase) |
| Constante | `UPPER_SNAKE` | `UPPER_SNAKE` |
| Método booleano | `isAtivo()` | `ativo?` |
| Método perigoso | — | `salvar!` |
| Arquivo | `meu-arquivo.js` | `meu_arquivo.rb` |

```javascript
const nomeCompleto = "Ana Silva";
function calcularTotal() {}
```

```ruby
nome_completo = "Ana Silva"
def calcular_total; end
```

## Escopo de variáveis

Os prefixos do Ruby indicam o escopo:

| Prefixo | Escopo | Equivalente aproximado em JS |
|---------|--------|------------------------------|
| `nome` | Local (método/bloco) | `let` dentro de função |
| `@nome` | Variável de instância (do objeto) | `this.nome` |
| `@@nome` | Variável de classe | `static` (aproximado) |
| `$nome` | Global | `window.nome` / `globalThis.nome` (evite!) |
| `NOME` | Constante | `const NOME` |

🔴 **Método não enxerga variáveis de fora** (diferença grande!). Em JS, funções "fecham" sobre variáveis externas (closure). Em Ruby, `def` cria um **novo escopo isolado**:

```javascript
const taxa = 0.1;
function calcular(v) { return v * taxa; }   // funciona (closure)
```

```ruby
taxa = 0.1
def calcular(v)
  v * taxa            # NameError: undefined local variable 'taxa'
end
```

Soluções: passar como parâmetro, usar constante (`TAXA`), ou usar **bloco/lambda** (esses sim fecham sobre o escopo):

```ruby
taxa = 0.1
calcular = ->(v) { v * taxa }    # lambda: closure
calcular.call(100)                # => 10.0
```

Blocos (`do...end`) também enxergam o escopo externo.

## Atribuição múltipla e desestruturação

```javascript
let [a, b] = [1, 2];
[a, b] = [b, a];                  // troca
const [primeiro, ...resto] = [1, 2, 3];
```

```ruby
a, b = 1, 2
a, b = b, a                       # troca
primeiro, *resto = [1, 2, 3]
primeiro   # => 1
resto      # => [2, 3]
x, (y, z) = 1, [2, 3]             # aninhado
```

## Interpolação de strings

```javascript
const msg = `Olá, ${nome}! Você tem ${idade} anos.`;
```

```ruby
msg = "Olá, #{nome}! Você tem #{idade} anos."
```

🔴 Só **aspas duplas** interpolam. Aspas simples são literais:

```ruby
'Olá, #{nome}'    # => "Olá, \#{nome}"  (sem interpolação)
```

## Expressões e retorno

Em Ruby quase tudo devolve um valor:

```javascript
let tipo;
if (n > 0) tipo = "positivo"; else tipo = "não positivo";
const t2 = n > 0 ? "positivo" : "não positivo";
```

```ruby
tipo = if n > 0 then "positivo" else "não positivo" end
t2   = n > 0 ? "positivo" : "não positivo"
```

## Impressão

| | JavaScript | Ruby |
|--|-----------|------|
| Imprimir com quebra | `console.log(x)` | `puts x` |
| Sem quebra | `process.stdout.write(x)` | `print x` |
| Depuração (mostra a estrutura) | `console.log(obj)` / `console.dir` | `p obj` / `pp obj` |

```ruby
puts [1, 2, 3]     # imprime 1, 2 e 3 em linhas separadas
p [1, 2, 3]        # => [1, 2, 3]   (e devolve o valor)
puts nil           # linha vazia
p nil              # nil
```

## Entrada

```javascript
// Node
const readline = require("readline");
```

```ruby
nome = gets.chomp        # lê uma linha e remove o \n
idade = gets.to_i
```

## Resumo

- Sem `;`, sem `let/const`, blocos terminam com `end`; parênteses são opcionais.
- Nomes: `snake_case` para variáveis e métodos, `PascalCase` para classes.
- Prefixos `@`, `@@`, `$` indicam escopo; **métodos não veem variáveis externas**.
- Constantes não impedem mutação; use `.freeze`.
- Interpolação com `#{}` apenas em aspas duplas.

## Exercícios

1. Converta para Ruby: `const taxaJuros = 0.05; function jurosSimples(p, t) { return p * taxaJuros * t; }` (cuidado com o escopo!).
2. Troque os valores de `x` e `y` sem variável auxiliar.
3. Mostre a diferença entre `puts` e `p` para `"texto"`.
4. Teste: o que acontece ao reatribuir uma constante? E ao fazer `LISTA << 4` em uma lista congelada?
5. Escreva em Ruby a mensagem `Total: R$ 10,50` usando interpolação e `format("%.2f", ...)`.
