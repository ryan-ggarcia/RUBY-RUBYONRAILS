# 09 — Migrations

**Migrations** são arquivos Ruby que descrevem **mudanças no esquema do banco** (criar tabela, adicionar coluna...). Funcionam como um "Git para o banco": cada mudança é versionada, repetível e reversível, e toda a equipe fica com o mesmo esquema.

## Anatomia

```bash
bin/rails generate migration CreateTarefas titulo:string concluida:boolean
```

```ruby
# db/migrate/20250115120000_create_tarefas.rb
class CreateTarefas < ActiveRecord::Migration[7.1]
  def change
    create_table :tarefas do |t|
      t.string  :titulo
      t.boolean :concluida

      t.timestamps          # created_at e updated_at
    end
  end
end
```

- O nome do arquivo começa com um **carimbo de data/hora** (a "versão").
- O `id` (chave primária) é criado automaticamente.
- `change` descreve a mudança; o Rails sabe **desfazê-la** automaticamente na maioria dos casos.

## Executando

```bash
bin/rails db:migrate            # executa as pendentes
bin/rails db:rollback           # desfaz a última
bin/rails db:rollback STEP=3    # desfaz as três últimas
bin/rails db:migrate:status     # mostra quais rodaram (up/down)
bin/rails db:migrate:redo       # rollback + migrate da última
bin/rails db:reset              # recria o banco do schema + seeds (apaga dados!)
bin/rails db:setup              # create + schema + seed
```

O Rails registra as versões executadas na tabela `schema_migrations` e atualiza `db/schema.rb`.

## Gerando por convenção de nome

O nome da migration orienta o que o gerador escreve:

```bash
# Criar tabela
bin/rails g migration CreateProdutos nome:string preco:decimal

# Adicionar colunas (AddXToY)
bin/rails g migration AddEstoqueToProdutos estoque:integer

# Remover colunas (RemoveXFromY)
bin/rails g migration RemoveEstoqueFromProdutos estoque:integer

# Referência (chave estrangeira)
bin/rails g migration AddCategoriaToProdutos categoria:references
```

O `generate model` já cria a migration de criação junto.

## Comandos do `create_table`

```ruby
create_table :produtos do |t|
  t.string  :nome,    null: false
  t.text    :descricao
  t.decimal :preco,   precision: 10, scale: 2, default: 0
  t.integer :estoque, default: 0
  t.boolean :ativo,   default: true
  t.references :categoria, foreign_key: true   # cria categoria_id + índice + FK
  t.timestamps
end
```

Opções frequentes: `null: false` (obrigatório), `default:`, `limit:`, `index: true`, `unique: true` (em `add_index`).

## Alterando tabelas existentes

```ruby
class AjustarProdutos < ActiveRecord::Migration[7.1]
  def change
    add_column    :produtos, :sku, :string
    remove_column :produtos, :legado, :string        # informe o tipo para ser reversível
    rename_column :produtos, :nome, :titulo
    change_column_default :produtos, :ativo, from: true, to: false
    change_column_null    :produtos, :nome, false

    add_index :produtos, :sku, unique: true
    add_reference :produtos, :marca, foreign_key: true

    rename_table :produtos, :itens
  end
end
```

### `up` e `down`: quando `change` não consegue reverter

Algumas operações (ex.: `change_column`, SQL cru) não têm reversão automática. Descreva as duas direções:

```ruby
class ConverterPrecoParaCentavos < ActiveRecord::Migration[7.1]
  def up
    add_column :produtos, :preco_centavos, :integer
    execute "UPDATE produtos SET preco_centavos = ROUND(preco * 100)"
    remove_column :produtos, :preco
  end

  def down
    add_column :produtos, :preco, :decimal, precision: 10, scale: 2
    execute "UPDATE produtos SET preco = preco_centavos / 100.0"
    remove_column :produtos, :preco_centavos
  end
end
```

Ou use `reversible do |dir| dir.up { ... } dir.down { ... } end` dentro de `change`.

## Índices e chaves estrangeiras

- **Índice** acelera buscas: crie em colunas usadas em `where`, `order` e chaves estrangeiras.
- **Chave estrangeira** (`foreign_key: true`) garante integridade: não deixa referenciar um registro inexistente.
- **Unique** impede duplicados no nível do banco (valida o que o `uniqueness` do model não garante sob concorrência).

```ruby
add_index :usuarios, :email, unique: true
```

## `schema.rb`

Arquivo **gerado** com o estado atual completo do banco:

```ruby
ActiveRecord::Schema[7.1].define(version: 2025_01_15_120000) do
  create_table "tarefas", force: :cascade do |t|
    t.string "titulo"
    t.boolean "concluida"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
```

- Não edite à mão.
- **Versione no Git**: um colega novo roda `rails db:schema:load` (ou `db:setup`) e obtém o banco sem executar dezenas de migrations.

## Regras de ouro

1. **Nunca edite uma migration que já foi compartilhada** (já está no Git/produção). Crie **uma nova** migration corrigindo.
2. Pode editar a migration **somente** se ainda não foi enviada a ninguém: faça `rails db:rollback`, edite e `db:migrate` de novo.
3. Uma migration, uma mudança lógica.
4. Em dados grandes, cuidado com migrations que travam a tabela.
5. Teste o `rollback` localmente.

## Seeds x migrations

| Migration | Seed |
|-----------|------|
| Muda a **estrutura** | Cria **dados iniciais** |
| Roda uma vez por ambiente | Pode rodar várias vezes (escreva idempotente: `find_or_create_by`) |

```ruby
# db/seeds.rb
Categoria.find_or_create_by!(nome: "Geral")
```

## Problemas comuns

| Sintoma | Causa | Solução |
|---------|-------|---------|
| `Migrations are pending` | Não rodou `db:migrate` | `bin/rails db:migrate` |
| `PG::UndefinedTable` / `no such table` | Migration não executada naquele ambiente | `db:migrate` (`RAILS_ENV=test` para testes) |
| `IrreversibleMigration` no rollback | Operação sem reversão em `change` | Use `up`/`down` ou `reversible` |
| Conflito de `schema.rb` no Git | Duas pessoas migraram | Resolva rodando `db:migrate` e conferindo o schema final |

## Resumo

- Migrations versionam o esquema do banco em arquivos Ruby com carimbo de data.
- `rails db:migrate` aplica, `rails db:rollback` desfaz; `schema.rb` é o retrato final.
- Use convenções de nome (`AddXToY`) e `change` para ser reversível; `up`/`down` quando necessário.
- Nunca altere migrations já compartilhadas.

## Exercícios

1. Crie uma migration para a tabela `clientes` (`nome` obrigatório, `email` único).
2. Adicione a coluna `telefone:string` a `clientes` com outra migration.
3. Rode `rails db:migrate:status` e interprete a saída.
4. Desfaça a última migration e refaça.
5. Adicione `categoria:references` a `produtos` e inspecione o `schema.rb`.
6. Explique por que não se deve editar uma migration já enviada ao repositório.
