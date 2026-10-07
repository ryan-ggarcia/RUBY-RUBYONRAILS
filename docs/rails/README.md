# Ruby on Rails — Material educacional

Guia em português para aprender **Ruby on Rails** do zero até um CRUD completo. Pressupõe que você já passou pela trilha de [Ruby](../ruby/README.md) (ao menos classes, hashes, blocos e gems).

> Versão de referência: **Rails 7.1+ / Ruby 3.x**. Os comandos e o código funcionam também no Rails 8 com pequenas diferenças (indicadas quando relevante).

## Índice

| # | Documento | Assunto |
|---|-----------|---------|
| 01 | [O que é Rails](01-o-que-e-rails.md) | Visão geral, filosofia, quando usar |
| 02 | [MVC e o caminho de uma requisição](02-mvc.md) | Model, View, Controller |
| 03 | [Instalação e `rails new`](03-instalacao-e-rails-new.md) | Ambiente e criação do projeto |
| 04 | [Estrutura de pastas](04-estrutura-de-pastas.md) | Onde fica cada coisa |
| 05 | [Rotas](05-rotas.md) | `routes.rb`, `resources`, helpers |
| 06 | [Controllers](06-controllers.md) | Actions, params, strong params, filtros |
| 07 | [Views e ERB](07-views-e-erb.md) | Templates, partials, layouts, helpers |
| 08 | [Models e ActiveRecord](08-models-e-activerecord.md) | Consultas e persistência |
| 09 | [Migrations](09-migrations.md) | Versionando o banco |
| 10 | [Validações e callbacks](10-validacoes.md) | Regras de integridade |
| 11 | [Associações](11-associacoes.md) | `belongs_to`, `has_many`, `has_many :through` |
| 12 | [CRUD completo](12-crud.md) | As 7 ações RESTful |
| 13 | [Prática: lista de tarefas](13-pratica-lista-de-tarefas.md) | Projeto guiado passo a passo |

## Trilha sugerida

1. **Entender** (01–02): por que Rails existe e como as peças se encaixam.
2. **Montar** (03–04): criar o projeto e se orientar nele.
3. **Construir as camadas** (05–08): rotas, controllers, views, models.
4. **Persistir e relacionar** (09–11): banco, validações, associações.
5. **Juntar tudo** (12–13): CRUD e projeto prático.

## Convenções deste material

- `# =>` mostra o resultado de uma expressão.
- Blocos `bash` são comandos de terminal; blocos `ruby` e `erb` são código.
- Caminhos de arquivo aparecem como comentário na primeira linha do bloco (ex.: `# app/models/tarefa.rb`).
- Cada documento termina com **Resumo** e **Exercícios**.
