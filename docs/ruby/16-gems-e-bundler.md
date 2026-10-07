# 16 — Gems e Bundler

## O que é uma gem

Uma **gem** é uma biblioteca Ruby empacotada para ser reaproveitada: código pronto para tarefas comuns (acessar APIs, enviar e-mails, formatar dados, criar aplicações web...). O **RubyGems** é o sistema que baixa, instala e gerencia gems, e o **Bundler** gerencia as gems de **cada projeto**.

O Rails, por exemplo, é um conjunto de gems.

Repositório público de gems: **rubygems.org**.

## Comandos do RubyGems (`gem`)

```bash
gem install colorize         # instala uma gem
gem install rails -v 7.1.0   # instala uma versão específica
gem list                     # lista as gems instaladas
gem list rails               # filtra por nome
gem uninstall colorize       # remove
gem update                   # atualiza as gems instaladas
gem search ^rspec            # busca no RubyGems.org
gem info rails               # detalhes de uma gem instalada
```

## Usando uma gem no código: `require`

```ruby
require "colorize"

puts "Sucesso!".green
puts "Erro!".red
```

`require` carrega a biblioteca (uma vez só). Nos projetos com Bundler, a carga costuma ser feita via `Bundler.require`; o Rails já faz isso por você.

### `require`, `require_relative` e `load`

| Comando | Para que serve |
|---------|----------------|
| `require "json"` | Gems e biblioteca padrão (procura nos caminhos do Ruby) |
| `require_relative "util"` | Arquivos do **seu** projeto, a partir da pasta do arquivo atual |
| `load "arquivo.rb"` | Executa o arquivo de novo a cada chamada (raro) |

### Biblioteca padrão (já vem com o Ruby)

Algumas bibliotecas não precisam de instalação, só de `require`:

```ruby
require "json"       # JSON.parse, to_json
require "date"       # Date, DateTime
require "time"       # Time.parse
require "set"        # Set (já carregado nas versões recentes)
require "net/http"   # requisições HTTP
require "csv"        # leitura/escrita de CSV (gem padrão em versões recentes)
require "securerandom"
require "fileutils"
```

## Bundler: gerenciando dependências do projeto

Projetos reais usam muitas gems, cada uma em uma versão específica. O Bundler garante que **todos os desenvolvedores e servidores usem as mesmas versões**.

### O `Gemfile`

Arquivo na raiz do projeto que lista as dependências:

```ruby
source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.1"
gem "pg"
gem "puma"

group :development, :test do
  gem "rspec-rails"
  gem "faker"
end

group :development do
  gem "rubocop", require: false
end
```

### Comandos do Bundler

```bash
bundle install        # instala o que está no Gemfile e gera/atualiza o Gemfile.lock
bundle add faker      # adiciona uma gem ao Gemfile e instala
bundle update         # atualiza gems respeitando as restrições do Gemfile
bundle update rails   # atualiza apenas uma gem
bundle outdated       # mostra gems com versão mais nova
bundle exec rspec     # roda um comando usando as versões do Gemfile.lock
bundle list           # lista as gems do projeto
bundle info rails     # onde a gem está e qual versão
```

### O `Gemfile.lock`

Gerado automaticamente. Registra **a versão exata** de cada gem (e das dependências delas) que foi instalada. Regras:

- **Versione o `Gemfile.lock` no Git** em aplicações (Rails, scripts).
- **Não edite** à mão.
- Quando outra pessoa roda `bundle install`, instala exatamente as mesmas versões.

### `bundle exec`

Garante que o comando use as gems do projeto, não outras versões instaladas na máquina:

```bash
bundle exec rake db:migrate
bundle exec rspec
```

Em projetos Rails, os comandos `bin/rails` e `rails` já cuidam disso.

## Versões: o operador `~>`

| Restrição | Significado |
|-----------|-------------|
| `gem "x"` | Qualquer versão (a mais recente compatível) |
| `gem "x", "1.2.3"` | Exatamente a versão 1.2.3 |
| `gem "x", ">= 1.2"` | 1.2 ou superior |
| `gem "x", "~> 1.2"` | `>= 1.2` e `< 2.0` |
| `gem "x", "~> 1.2.3"` | `>= 1.2.3` e `< 1.3` |

O `~>` (operador "pessimista") permite atualizações **seguras**, aquelas que não mudam o número "maior". Isso vale se a gem seguir o versionamento semântico (MAJOR.MINOR.PATCH).

## Grupos

Gems só para desenvolvimento e testes não precisam ir para produção:

```ruby
group :development, :test do
  gem "pry"
  gem "rspec-rails"
end
```

Em produção: `bundle install --without development test` (ou configure `bundle config set without 'development test'`).

## Opções de gems

```ruby
gem "rubocop", require: false                        # não carrega automaticamente
gem "minha_gem", path: "../minha_gem"                # de uma pasta local
gem "outra", git: "https://github.com/user/outra"    # direto do GitHub
gem "rails", github: "rails/rails", branch: "main"   # de uma branch específica
```

## Gems populares

| Gem | Para que serve |
|-----|----------------|
| `rails` | Framework web |
| `puma` | Servidor web |
| `pg`, `sqlite3`, `mysql2` | Drivers de banco de dados |
| `rspec`, `minitest` | Testes |
| `rubocop` | Análise de estilo e qualidade do código |
| `pry`, `debug` | Depuração |
| `devise` | Autenticação de usuários |
| `sidekiq` | Processamento em segundo plano |
| `faker` | Dados falsos para testes e seeds |
| `nokogiri` | Leitura de HTML/XML |
| `httparty`, `faraday` | Requisições HTTP |
| `colorize` | Cores no terminal |

## Criando sua própria gem (visão geral)

```bash
bundle gem minha_gem
```

Gera a estrutura mínima (`lib/`, `.gemspec`, `Gemfile`). Para publicar: `gem build` e `gem push`.

## Segurança

- Instale gems de fontes confiáveis e confira o histórico de manutenção.
- Mantenha as dependências atualizadas.
- Use a gem `bundler-audit` para verificar vulnerabilidades conhecidas: `bundle audit check --update`.

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| `Could not find gem 'x'` | Falta rodar `bundle install` | `bundle install` |
| `LoadError: cannot load such file` | Falta `require` ou gem fora do Gemfile | Adicione ao Gemfile e rode `bundle install` |
| Conflito de versões | Gems pedem versões incompatíveis | `bundle update` da gem ou ajuste das restrições |
| Erro ao compilar extensão nativa | Faltam bibliotecas do sistema | Instale as dependências de build indicadas no erro |

## Resumo

- Gem = biblioteca Ruby reutilizável; RubyGems instala, Bundler gerencia por projeto.
- `Gemfile` lista as dependências; `Gemfile.lock` fixa as versões exatas.
- `bundle install` instala; `bundle exec` executa com as gems do projeto.
- `~> 7.1` permite atualizar dentro da série 7.x.

## Exercícios

1. Instale a gem `colorize` e imprima uma mensagem verde e outra vermelha.
2. Crie uma pasta com um `Gemfile` contendo `colorize` e `faker`; rode `bundle install` e inspecione o `Gemfile.lock`.
3. Use `require "json"` para converter um Hash em JSON e depois voltar a Hash.
4. Explique a diferença entre `require` e `require_relative` com um exemplo de dois arquivos.
5. Use `bundle outdated` em um projeto e interprete a saída.
