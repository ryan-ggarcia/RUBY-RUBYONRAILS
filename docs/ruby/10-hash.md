# 10 — Hash

Um **Hash** é uma coleção de pares **chave → valor**, parecida com um dicionário ou um objeto JSON. Em vez de acessar por posição (como no Array), você acessa por uma **chave**.

```ruby
pessoa = { nome: "Ana", idade: 30, cidade: "São Paulo" }
```

## Sintaxes

```ruby
{ nome: "Ana", idade: 30 }            # moderna: chaves symbol (mais usada)
{ :nome => "Ana", :idade => 30 }      # antiga, equivalente
{ "nome" => "Ana", "idade" => 30 }    # chaves String
{ 1 => "um", 2 => "dois" }            # chaves podem ser de qualquer tipo
Hash.new                              # => {}
```

Os **valores** podem ser de qualquer tipo, inclusive arrays e outros hashes:

```ruby
aluno = {
  nome: "Pedro",
  notas: [8.5, 7.0, 9.0],
  endereco: { rua: "Rua A", numero: 10 }
}
```

## Acessando valores

```ruby
pessoa[:nome]              # => "Ana"
pessoa[:email]             # => nil   (chave inexistente, sem erro)
pessoa.fetch(:nome)        # => "Ana"
pessoa.fetch(:email)       # erro: KeyError
pessoa.fetch(:email, "sem email")        # => "sem email"
pessoa.fetch(:email) { |k| "sem #{k}" }  # => "sem email"
pessoa.dig(:endereco, :rua)              # acesso aninhado seguro
```

`[]` retorna `nil` quando a chave não existe; `fetch` falha de forma explícita — útil para pegar erros cedo.

## Adicionando, alterando e removendo

```ruby
pessoa[:profissao] = "Desenvolvedora"   # adiciona
pessoa[:idade] = 31                      # altera
pessoa.delete(:cidade)                   # remove e retorna o valor
pessoa.merge!(email: "ana@x.com")        # adiciona vários (altera o hash)
pessoa.store(:pais, "Brasil")            # equivalente a pessoa[:pais] = ...
```

## Consultando

```ruby
pessoa.keys             # => [:nome, :idade, ...]
pessoa.values           # => ["Ana", 31, ...]
pessoa.size             # => quantidade de pares (também: length, count)
pessoa.key?(:nome)      # => true   (também: has_key?, include?)
pessoa.value?("Ana")    # => true   (também: has_value?)
pessoa.empty?           # => false
pessoa.to_a             # => [[:nome, "Ana"], [:idade, 31], ...]
```

## Iterando

```ruby
pessoa.each do |chave, valor|
  puts "#{chave}: #{valor}"
end

pessoa.each_key { |k| puts k }
pessoa.each_value { |v| puts v }
pessoa.each_with_index { |(chave, valor), i| puts "#{i} #{chave}=#{valor}" }
```

Os hashes **preservam a ordem de inserção**.

## Transformando e filtrando

```ruby
precos = { cafe: 5, pao: 2, leite: 4 }

precos.select { |nome, preco| preco > 3 }     # => { cafe: 5, leite: 4 }
precos.reject { |nome, preco| preco > 3 }     # => { pao: 2 }
precos.map { |nome, preco| [nome, preco * 2] }.to_h   # => { cafe: 10, ... }
precos.transform_values { |v| v * 2 }         # => { cafe: 10, pao: 4, leite: 8 }
precos.transform_keys(&:to_s)                 # => { "cafe" => 5, ... }
precos.min_by { |_, v| v }                    # => [:pao, 2]
precos.max_by { |_, v| v }                    # => [:cafe, 5]
precos.sort_by { |_, v| v }.to_h              # ordena por valor
precos.sum { |_, v| v }                       # => 11
precos.count { |_, v| v > 3 }                 # => 2
precos.find { |_, v| v == 4 }                 # => [:leite, 4]
precos.any? { |_, v| v > 4 }                  # => true
precos.slice(:cafe, :pao)                     # => { cafe: 5, pao: 2 }
precos.except(:pao)                           # => { cafe: 5, leite: 4 }
precos.invert                                 # => { 5 => :cafe, 2 => :pao, ... }
{ a: 1, b: nil }.compact                      # => { a: 1 }
```

## Valores padrão: `Hash.new`

```ruby
contagem = Hash.new(0)
"banana".each_char { |letra| contagem[letra] += 1 }
contagem   # => { "b" => 1, "a" => 3, "n" => 2 }
```

Alternativa mais curta:

```ruby
"banana".chars.tally   # => { "b" => 1, "a" => 3, "n" => 2 }
```

### Armadilha: valor padrão mutável

```ruby
h = Hash.new([])
h[:a] << 1          # altera o array padrão, mas NÃO cria a chave :a
h                   # => {}
h[:b]               # => [1]   (surpresa!)

h = Hash.new { |hash, chave| hash[chave] = [] }   # forma correta
h[:a] << 1
h                   # => { a: [1] }
```

## Agrupando

```ruby
palavras = %w[maçã banana abacate uva bolo]
palavras.group_by { |p| p[0] }
# => { "m" => ["maçã"], "b" => ["banana", "bolo"], "a" => ["abacate"], "u" => ["uva"] }
```

## Symbol vs. String como chave

```ruby
h = { nome: "Ana" }
h[:nome]    # => "Ana"
h["nome"]   # => nil     (chave diferente!)
```

Escolha um padrão e mantenha. Dados de JSON/formulários costumam vir com chaves string.

```ruby
require "json"
JSON.parse('{"nome":"Ana"}')                          # => { "nome" => "Ana" }
JSON.parse('{"nome":"Ana"}', symbolize_names: true)   # => { nome: "Ana" }
{ nome: "Ana" }.to_json                               # => "{\"nome\":\"Ana\"}"
```

## Sintaxe abreviada (Ruby 3.1+)

Quando a variável tem o mesmo nome da chave:

```ruby
nome = "Ana"
idade = 30
{ nome:, idade: }     # => { nome: "Ana", idade: 30 }
```

## Hash como argumento de método

```ruby
def criar_usuario(nome:, idade: 18)
  "#{nome}, #{idade} anos"
end

criar_usuario(nome: "Pedro", idade: 22)
criar_usuario(nome: "Lia")        # idade usa o padrão
```

Esse formato está em todo o Rails: `validates :titulo, presence: true`, `render json: { ok: true }`.

## Resumo

- Hash = pares chave → valor; mantém a ordem de inserção.
- `h[:chave]` devolve `nil` se não existir; `fetch` levanta erro ou aceita padrão.
- Prefira chaves **symbol** para dados internos.
- `Hash.new(0)` ou `tally` para contar; use bloco quando o padrão for mutável.
- `select`, `map`, `transform_values`, `group_by` e `merge` cobrem a maioria das tarefas.

## Exercícios

1. Crie um hash de produto com `:nome`, `:preco` e `:estoque`. Exiba nome e preço, altere o estoque e adicione `:categoria`.
2. Dado `aluno = { nome: "Pedro", idade: 22, curso: "Engenharia" }`, exiba todas as chaves e valores separadamente.
3. Verifique se `:email` existe; se não, adicione um.
4. Conte quantas vezes cada palavra aparece em `"o rato roeu a roupa do rei de roma"`.
5. Dado `{ cafe: 5, pao: 2, leite: 4 }`, aplique 10% de desconto a todos os preços e exiba apenas os itens com preço final acima de 3.
6. Agrupe `%w[ana bia caio carla davi]` pela primeira letra.
