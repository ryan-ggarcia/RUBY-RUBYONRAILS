# 03 — Instalação e `rails new`

## Pré-requisitos

- **Ruby 3.1+** (recomendado 3.2 ou superior; confira a exigência da versão do Rails).
- **Bundler** (já vem com o Ruby).
- **SQLite 3** (banco padrão no desenvolvimento).
- **Git** (o Rails inicializa um repositório).
- **Node.js**: não é obrigatório no Rails 7+ com *import maps* (padrão), mas é necessário se optar por bundlers JS (`esbuild`, `webpack`).

Verifique:

```bash
ruby -v
bundler -v
sqlite3 --version
git --version
```

## Instalando o Ruby

Use um **gerenciador de versões** para trocar de versão por projeto:

| Sistema | Opções |
|---------|--------|
| Linux/macOS | `rbenv`, `asdf`, `mise`, `rvm` |
| Windows | RubyInstaller (com DevKit) ou **WSL2** com Ubuntu (recomendado) |

Exemplo com `rbenv`:

```bash
rbenv install 3.3.0
rbenv global 3.3.0
ruby -v      # => ruby 3.3.0 ...
```

## Instalando o Rails

```bash
gem install rails
rails -v        # => Rails 7.x.x (ou 8.x)
```

Versão específica:

```bash
gem install rails -v 7.1.3
```

## Criando um projeto: `rails new`

```bash
rails new biblioteca
cd biblioteca
```

O comando:

1. Cria a estrutura de pastas.
2. Gera o `Gemfile` e roda `bundle install`.
3. Configura o banco SQLite.
4. Inicializa um repositório Git.

### Opções úteis

| Opção | Efeito |
|-------|--------|
| `-d postgresql` (`--database`) | Usa PostgreSQL (ou `mysql`) em vez de SQLite |
| `--api` | Modo API: sem views/assets, só JSON |
| `--css=tailwind` | Já configura Tailwind CSS (também `bootstrap`, `sass`...) |
| `--javascript=esbuild` | Troca o import maps por esbuild |
| `--skip-git` | Não inicializa o Git |
| `--skip-test` | Não gera a pasta de testes (para usar RSpec) |
| `--minimal` | Projeto enxuto, sem muitos componentes |

Exemplos:

```bash
rails new loja -d postgresql --css=tailwind
rails new minha_api --api -d postgresql
```

Para ver todas: `rails new --help`.

## Rodando a aplicação

```bash
bin/rails server      # ou: rails s
```

Acesse **http://localhost:3000**. Você verá a página inicial do Rails. Para parar, `Ctrl + C`.

Opções: `rails s -p 4000` (porta), `rails s -b 0.0.0.0` (aceitar conexões externas).

## O console do Rails

```bash
bin/rails console     # ou: rails c
```

É um IRB com a aplicação carregada. Você manipula models, testa consultas e explora o sistema:

```ruby
Tarefa.count                   # => 0
Tarefa.create(titulo: "Estudar")
```

Dica: `rails c --sandbox` desfaz todas as alterações no banco ao sair.

## Primeiro "Olá, Rails"

```bash
bin/rails generate controller Welcome index
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "welcome#index"
end
```

```erb
<%# app/views/welcome/index.html.erb %>
<h1>Olá, Rails!</h1>
<p>Agora são <%= Time.current.strftime("%H:%M") %>.</p>
```

Reinicie (se necessário) e abra `http://localhost:3000`.

## Comandos essenciais do dia a dia

| Comando | Para que serve |
|---------|----------------|
| `rails server` | Sobe o servidor |
| `rails console` | Console interativo |
| `rails generate ...` | Gera código (controller, model, scaffold...) |
| `rails destroy ...` | Desfaz um `generate` |
| `rails db:create` | Cria o banco |
| `rails db:migrate` | Executa migrations pendentes |
| `rails db:rollback` | Desfaz a última migration |
| `rails db:seed` | Carrega `db/seeds.rb` |
| `rails routes` | Lista as rotas |
| `rails test` | Roda os testes |
| `rails about` | Mostra versões do ambiente |

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| `command not found: rails` | Gem não instalada ou PATH sem o Ruby | Reinstale; confira o gerenciador de versões |
| Erro ao instalar gem nativa (`sqlite3`, `pg`) | Faltam bibliotecas do sistema | Instale `libsqlite3-dev` / `libpq-dev` e ferramentas de build |
| `Address already in use` | Outro servidor na porta 3000 | Use `-p 3001` ou encerre o processo |
| `Pending migrations` | Falta migrar | `rails db:migrate` |
| `Could not find gem` | Falta `bundle install` | Rode `bundle install` |

## Resumo

- Instale Ruby (com gerenciador de versões) e depois `gem install rails`.
- `rails new nome` cria o projeto; opções definem banco, CSS e modo API.
- `rails server` sobe em `localhost:3000`; `rails console` abre o console.
- Os *generators* e comandos `rails db:*` são seus aliados diários.

## Exercícios

1. Instale o Rails e confirme a versão com `rails -v`.
2. Crie o projeto `biblioteca` e suba o servidor. Acesse no navegador.
3. Gere o controller `Welcome` com a action `index` e faça-a ser a página inicial (`root`).
4. Abra o `rails console` e calcule `Time.current` e `1.day.from_now`.
5. Crie um segundo projeto com `-d postgresql --skip-test` e compare o `Gemfile` com o primeiro.
