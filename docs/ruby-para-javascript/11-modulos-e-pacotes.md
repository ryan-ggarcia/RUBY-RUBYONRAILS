# 11 — Módulos, pacotes e ferramentas

## Importando código

```javascript
// ES Modules
import fs from "node:fs";
import { somar } from "./util.js";
export function dobrar(n) { return n * 2; }
export default class Pessoa {}

// CommonJS
const fs = require("fs");
module.exports = { somar };
```

```ruby
require "json"                    # biblioteca padrão ou gem
require_relative "util"           # arquivo do seu projeto (relativo ao arquivo atual)
```

| JavaScript | Ruby |
|-----------|------|
| `import x from "pacote"` | `require "pacote"` |
| `import x from "./arquivo"` | `require_relative "arquivo"` |
| `export` | (não há) — tudo definido no arquivo fica disponível após o `require` |
| `export default` | (não há) |
| Import nomeado `{ a, b }` | (não há) — carrega o arquivo inteiro |
| Import dinâmico `import()` | `require` em qualquer lugar do código / `load` |

🔴 Em Ruby **não existe escopo de módulo por arquivo**: o que um arquivo define (classes, métodos, constantes) fica **global** depois de carregado. Por isso se usam **módulos como namespaces** para organizar e evitar colisões.

```ruby
# loja/produto.rb
module Loja
  class Produto
    def initialize(nome) = @nome = nome
  end
end

# app.rb
require_relative "loja/produto"
Loja::Produto.new("Café")
```

`require` carrega o arquivo **uma única vez**; chamadas repetidas são ignoradas.

## Autoload no Rails (Zeitwerk)

No Rails você **quase nunca escreve `require`** para código seu: a convenção de nomes faz o carregamento automático.

| Classe | Arquivo |
|--------|---------|
| `Pessoa` | `app/models/pessoa.rb` |
| `Admin::Relatorio` | `app/models/admin/relatorio.rb` |

## `module` em Ruby: duas funções

1. **Namespace** (como pastas/escopos): `Loja::Produto`.
2. **Mixin** (compartilhar métodos): `include Comparable`.

```ruby
module Util
  def self.dobrar(n) = n * 2           # chamado como Util.dobrar(3)
end

module Cumprimenta
  def ola = "Olá, #{nome}"
end

class Pessoa
  include Cumprimenta
  attr_reader :nome
  def initialize(nome) = @nome = nome
end
```

`module_function` torna os métodos utilitários chamáveis diretamente:

```ruby
module Util
  module_function
  def dobrar(n) = n * 2
end
Util.dobrar(4)
```

## Pacotes: npm → RubyGems

| | npm / Node | RubyGems / Bundler |
|--|-----------|--------------------|
| Pacote | package | **gem** |
| Registro público | npmjs.com | rubygems.org |
| Manifesto do projeto | `package.json` | `Gemfile` |
| Lockfile | `package-lock.json` | `Gemfile.lock` |
| Instalar tudo | `npm install` | `bundle install` |
| Adicionar | `npm install axios` | `bundle add httparty` |
| Adicionar só dev | `npm i -D jest` | `group :development, :test do ... end` |
| Remover | `npm uninstall x` | `bundle remove x` |
| Atualizar | `npm update` | `bundle update` |
| Desatualizados | `npm outdated` | `bundle outdated` |
| Executar binário local | `npx jest` | `bundle exec rspec` |
| Instalação global | `npm i -g` | `gem install` |
| Pasta de dependências | `node_modules/` (no projeto) | instaladas **fora** do projeto (cache de gems) |
| Versões | `^1.2.3`, `~1.2.3` | `"~> 1.2"`, `">= 1.2"` |

### Exemplo lado a lado

```json
{
  "name": "meu-app",
  "dependencies": {
    "express": "^4.18.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  },
  "scripts": {
    "start": "node app.js",
    "test": "jest"
  }
}
```

```ruby
# Gemfile
source "https://rubygems.org"

ruby "3.3.0"

gem "sinatra", "~> 4.0"
gem "httparty", "~> 0.21"

group :development, :test do
  gem "rspec"
end
```

Não há `scripts` no `Gemfile`: tarefas ficam no **Rakefile** ou em `bin/`:

```ruby
# Rakefile
task :ola do
  puts "olá"
end
```

```bash
bundle exec rake ola
```

### Operador de versão `~>`

| JavaScript | Ruby | Significado |
|-----------|------|-------------|
| `^1.2.3` | `"~> 1.2"` | `>= 1.2` e `< 2.0` |
| `~1.2.3` | `"~> 1.2.3"` | `>= 1.2.3` e `< 1.3` |
| `1.2.3` | `"1.2.3"` | exata |
| `>=1.2` | `">= 1.2"` | no mínimo |

### Usando gems no código

```ruby
require "bundler/setup"      # restringe às gems do Gemfile
require "httparty"
HTTParty.get("https://exemplo.com")

# ou carregar todas as do Gemfile de uma vez
Bundler.require(:default)
```

Em Rails, isso já é feito automaticamente.

## Ferramentas equivalentes

| Função | JavaScript | Ruby |
|--------|-----------|------|
| Runtime | Node, Deno, Bun | MRI (CRuby), JRuby, TruffleRuby |
| Gerenciador de versões | nvm, fnm, volta | rbenv, rvm, asdf, mise |
| REPL | `node` | `irb`, `pry` |
| Depurador | `node --inspect`, `debugger` | `debug` (`binding.break`), `byebug`, `pry` |
| Testes | Jest, Vitest, Mocha | Minitest, RSpec |
| Linter/formatador | ESLint / Prettier | RuboCop |
| Framework web minimalista | Express, Fastify | Sinatra, Roda |
| Framework web completo | Next.js, NestJS | **Ruby on Rails** |
| ORM | Prisma, Sequelize, TypeORM | **ActiveRecord**, Sequel |
| Template | JSX, EJS, Handlebars | ERB, Haml, Slim |
| Bundler de assets | Webpack, Vite, esbuild | Sprockets, Propshaft, jsbundling |
| Tarefas/scripts | `npm run`, Makefile | **Rake** |
| Tipos | TypeScript | RBS, Sorbet, RBS inline |
| Documentação | JSDoc | YARD, RDoc |
| Processos em segundo plano | BullMQ | Sidekiq, Solid Queue, GoodJob |

## Biblioteca padrão

Ruby inclui bastante coisa sem pacote externo (basta `require`):

| Necessidade | JavaScript | Ruby (stdlib) |
|-------------|-----------|---------------|
| JSON | `JSON` (nativo) | `require "json"` |
| Datas | `Date`, Day.js | `Date`, `Time` (`require "date"`) |
| HTTP | `fetch` | `Net::HTTP` (`require "net/http"`) |
| Arquivos | `fs` | `File`, `Dir`, `FileUtils` |
| CSV | papaparse | `require "csv"` |
| Aleatório/UUID | `crypto.randomUUID()` | `SecureRandom.uuid` |
| Regex | `RegExp` | `Regexp` |
| Set | `Set` | `Set` |
| Argumentos CLI | `process.argv`, commander | `ARGV`, `OptionParser` |
| Variáveis de ambiente | `process.env.X` | `ENV["X"]` |
| Testes | `node:test` | `Minitest` |

## Variáveis de ambiente e arquivos de configuração

```javascript
const porta = process.env.PORT ?? 3000;
```

```ruby
porta = ENV.fetch("PORT", 3000)
ENV["API_KEY"]                     # nil se ausente
ENV.fetch("API_KEY")               # KeyError se ausente
```

Em Rails: `Rails.application.credentials` e a gem `dotenv-rails` para arquivos `.env`.

## Script executável

```javascript
#!/usr/bin/env node
console.log("oi");
```

```ruby
#!/usr/bin/env ruby
puts "oi"

# Executa apenas quando rodado direto (equivale ao `require.main === module`)
if __FILE__ == $PROGRAM_NAME
  puts "rodando como script"
end
```

## Resumo

- `import`/`require` do JS → `require` (gems) e `require_relative` (seus arquivos); não há `export`.
- Não há escopo de módulo por arquivo: use **módulos** como namespace.
- `package.json` → `Gemfile`; `package-lock.json` → `Gemfile.lock`; `npm install` → `bundle install`; `npx` → `bundle exec`.
- Tarefas: `Rakefile`/`bin/` em vez de `scripts`.
- A biblioteca padrão do Ruby é ampla: JSON, datas, HTTP, CSV e testes vêm incluídos.

## Exercícios

1. Crie dois arquivos, `util.rb` e `app.rb`, e use `require_relative` para chamar uma função.
2. Escreva um `Gemfile` com `sinatra` e `rspec` (grupo de testes) e rode `bundle install`.
3. Converta `"^2.5.0"` para a restrição de gem equivalente.
4. Transforme um módulo JS que exporta três funções em um módulo Ruby com `module_function`.
5. Escreva uma tarefa Rake `saudar` e execute-a.
6. Leia uma variável de ambiente com valor padrão em Ruby e em JS.
