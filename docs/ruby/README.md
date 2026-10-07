# Ruby — Guia de Estudo

Documentos educacionais sobre a linguagem Ruby, na mesma ordem do slide da aula. Cada arquivo explica um tema com exemplos, armadilhas comuns e exercícios.

## Trilha sugerida

| # | Documento | O que você aprende |
|---|-----------|--------------------|
| 01 | [Origem e filosofia](01-origem-e-filosofia.md) | História, criador, princípios da linguagem |
| 02 | [Instalação e ambiente](02-instalacao-e-ambiente.md) | rbenv/RVM/asdf, irb, rodar arquivos, editores |
| 03 | [Tipos e variáveis](03-tipos-e-variaveis.md) | Tipagem dinâmica, tipos básicos, conversões |
| 04 | [Entrada e saída](04-entrada-e-saida.md) | `puts`, `print`, `p`, `gets.chomp` |
| 05 | [Symbols](05-symbols.md) | O que são, diferença para String, quando usar |
| 06 | [Operadores](06-operadores.md) | Aritméticos, comparação, lógicos, atribuição |
| 07 | [Condicionais](07-condicionais.md) | `if`, `unless`, `case/when`, ternário |
| 08 | [Loops](08-loops.md) | `while`, `until`, `for`, `loop`, `times`, `each` |
| 09 | [Arrays](09-arrays.md) | Listas ordenadas e seus métodos |
| 10 | [Hash](10-hash.md) | Pares chave → valor |
| 11 | [Range](11-range.md) | Intervalos |
| 12 | [Iterações](12-iteracoes.md) | `each`, `map`, `select`, `reduce` e família |
| 13 | [Orientação a objetos](13-orientacao-a-objetos.md) | Classes, objetos, herança, módulos |
| 14 | [Atributos e métodos](14-atributos-e-metodos.md) | `initialize`, métodos de instância e de classe |
| 15 | [Getters e setters](15-getters-e-setters.md) | `attr_reader`, `attr_writer`, `attr_accessor` |
| 16 | [Gems e Bundler](16-gems-e-bundler.md) | Bibliotecas, `Gemfile`, versões |

## Como usar

1. Leia o documento na ordem da trilha.
2. Digite cada exemplo no `irb` (não só copie e cole).
3. Faça os exercícios no final de cada arquivo antes de seguir.

## Convenções dos exemplos

- `# => valor` mostra o resultado de uma expressão.
- `# erro` indica que aquele trecho gera uma exceção.
- Os exemplos assumem Ruby 3.x.
