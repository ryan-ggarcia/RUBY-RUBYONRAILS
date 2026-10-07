# Ruby para JavaScript

Guia comparativo para quem já programa em **JavaScript** e quer aprender **Ruby**. Cada documento mostra o código JS ao lado do equivalente em Ruby, destaca as **diferenças que causam bugs** e explica o "jeito Ruby" de fazer.

> Referências: JavaScript moderno (ES2022+) e Ruby 3.x.

## Índice

| # | Documento | Assunto |
|---|-----------|---------|
| 01 | [Visão geral e mentalidade](01-visao-geral.md) | Filosofia, execução, ferramentas, quadro de equivalências |
| 02 | [Sintaxe e variáveis](02-sintaxe-e-variaveis.md) | Declaração, constantes, comentários, nomes |
| 03 | [Tipos e valores](03-tipos-e-valores.md) | Números, strings, `nil`, truthiness, símbolos |
| 04 | [Operadores](04-operadores.md) | Aritmética, comparação, lógicos, `?.`, `??` |
| 05 | [Controle de fluxo](05-controle-de-fluxo.md) | `if`, `switch` → `case`, loops |
| 06 | [Funções, métodos e blocos](06-funcoes-metodos-e-blocos.md) | Parâmetros, retorno, arrow functions → blocos/lambdas |
| 07 | [Arrays e iteração](07-arrays-e-iteracao.md) | `map`, `filter`, `reduce` e companhia |
| 08 | [Objetos e Hashes](08-objetos-e-hashes.md) | `{}` JS vs Hash, symbols, desestruturação |
| 09 | [Classes e orientação a objetos](09-classes-e-poo.md) | `class`, herança, módulos, `this` → `self` |
| 10 | [Erros e exceções](10-erros-e-excecoes.md) | `try/catch` → `begin/rescue` |
| 11 | [Módulos, pacotes e ferramentas](11-modulos-e-pacotes.md) | `import`, npm → gems, `package.json` → `Gemfile` |
| 12 | [Assincronia e I/O](12-assincronia-e-io.md) | Promises/async vs threads/Fibers, console, arquivos, JSON |
| 13 | [Express/Node → Rails](13-node-para-rails.md) | Mapa mental para o desenvolvimento web |
| 14 | [Cheat sheet](14-cheat-sheet.md) | Tabela de consulta rápida |
| 15 | [Armadilhas comuns](15-armadilhas.md) | Erros típicos de quem vem do JS |

## Como usar

- Leia o **01** primeiro (mentalidade) e o **14** como consulta.
- Os documentos 02–10 podem ser lidos em qualquer ordem.
- Rode os exemplos de Ruby no `irb`; os de JS no console do navegador ou no `node`.

## Convenções

- Blocos `javascript` ao lado de blocos `ruby`.
- `# =>` e `// =>` indicam o resultado de uma expressão.
- 🔴 marca diferenças que costumam causar bugs.
