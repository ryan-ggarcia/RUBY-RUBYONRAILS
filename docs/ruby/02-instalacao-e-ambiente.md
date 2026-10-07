# 02 — Instalação e ambiente de desenvolvimento

## O que você precisa

1. O **Ruby** (interpretador).
2. Um **gerenciador de versões** (recomendado).
3. Um **editor de código** ou IDE.
4. O **Bundler** e as **gems** (instalados junto com o Ruby ou depois).

## Passo 1 — Gerenciador de versões

Projetos diferentes podem exigir versões diferentes do Ruby. Um gerenciador de versões permite instalar várias e escolher uma por projeto.

| Ferramenta | Característica |
|------------|----------------|
| **rbenv** | Leve e simples; troca de versão por pasta (arquivo `.ruby-version`) |
| **RVM** | Mais completo; gerencia também conjuntos de gems (gemsets) |
| **asdf** | Gerenciador único para várias linguagens (Ruby, Node, Python...) |
| **mise** | Alternativa moderna ao asdf, também multi-linguagem |

No **Windows**, a forma mais comum é o **RubyInstaller** (rubyinstaller.org) ou usar o **WSL** (Linux dentro do Windows) com rbenv.

## Passo 2 — Instalar o Ruby (exemplo com rbenv)

```bash
# Listar as versões disponíveis
rbenv install --list

# Instalar uma versão (substitua pela versão estável que você escolher)
rbenv install 3.3.0

# Definir a versão padrão da máquina
rbenv global 3.3.0

# Ou definir só para o projeto atual (cria o arquivo .ruby-version)
rbenv local 3.3.0
```

## Passo 3 — Verificar a instalação

```bash
ruby -v      # mostra a versão do Ruby
gem -v       # mostra a versão do RubyGems
bundle -v    # mostra a versão do Bundler
```

Se `ruby -v` mostrar a versão que você instalou, o ambiente está pronto.

## Passo 4 — Executando código Ruby

Existem três formas principais.

### 1. O console interativo: `irb`

```bash
irb
```

```ruby
irb(main):001> 2 + 3
=> 5
irb(main):002> "ruby".upcase
=> "RUBY"
```

O `irb` é ideal para testar ideias rapidamente. Saia com `exit`.

### 2. Rodando um arquivo `.rb`

Crie `ola.rb`:

```ruby
puts "Olá, Ruby!"
```

Execute:

```bash
ruby ola.rb
```

### 3. Uma linha direto no terminal

```bash
ruby -e 'puts 10 * 5'
```

## Passo 5 — Editor de código

| Opção | Observações |
|-------|-------------|
| **RubyMine** (JetBrains) | IDE completa para Ruby e Rails; paga, com período de teste |
| **VS Code** | Gratuito; instale a extensão **Ruby LSP** para autocompletar e navegação |
| **Sublime Text, Vim, Neovim** | Leves; exigem configuração manual de plugins |

Recomendação para quem está começando: **VS Code + Ruby LSP** (gratuito) ou RubyMine se tiver acesso à licença.

## Passo 6 — Bundler e gems

O Bundler normalmente já vem com o Ruby. Para verificar:

```bash
gem install bundler   # instala/atualiza se necessário
```

Para o Rails (usado na segunda parte da aula):

```bash
gem install rails
rails -v
```

Veja mais em [16 — Gems e Bundler](16-gems-e-bundler.md).

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| `ruby: command not found` | Gerenciador não configurado no PATH | Reinicie o terminal; revise a configuração do rbenv no `~/.bashrc` ou `~/.zshrc` |
| `ruby -v` mostra uma versão antiga | Ruby do sistema sendo usado | Rode `rbenv versions` e confirme a versão ativa |
| Erro ao compilar uma gem | Faltam bibliotecas de sistema | Instale as dependências de build (compilador, `libssl`, `libyaml`) |
| `Permission denied` ao instalar gems | Usando o Ruby do sistema | Use um gerenciador de versões em vez de `sudo gem install` |

## Resumo

- Use um **gerenciador de versões** (rbenv, RVM ou asdf).
- Verifique com `ruby -v`.
- Teste ideias no `irb` e rode scripts com `ruby arquivo.rb`.
- VS Code + Ruby LSP ou RubyMine são boas escolhas de editor.

## Exercícios

1. Instale o Ruby e confirme a versão com `ruby -v`.
2. Crie `meu_nome.rb` que imprime seu nome e rode com `ruby meu_nome.rb`.
3. No `irb`, calcule `2 ** 10` e `"ruby" * 3`.
4. Use `rbenv local` (ou o equivalente da sua ferramenta) numa pasta de teste e observe o arquivo `.ruby-version`.
