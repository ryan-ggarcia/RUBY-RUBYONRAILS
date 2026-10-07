# 08 — Objetos e Hashes

O `{}` do JavaScript faz três papéis: **dicionário**, **estrutura de dados** e **objeto com métodos**. Em Ruby esses papéis são separados:

| Papel | JavaScript | Ruby |
|-------|-----------|------|
| Dicionário / dados | `{ nome: "Ana" }` | `Hash`: `{ nome: "Ana" }` |
| Registro com campos fixos | objeto literal | `Struct` / `Data` / classe |
| Objeto com comportamento | objeto ou classe | **instância de classe** |
| Mapa com qualquer chave | `Map` | `Hash` |

## Literais

```javascript
const pessoa = { nome: "Ana", idade: 30, "e-mail": "ana@x.com" };
```

```ruby
pessoa = { nome: "Ana", idade: 30, "e-mail": "ana@x.com" }
# chaves symbol: nome:, idade:, "e-mail": (symbol com hífen)

antigo = { :nome => "Ana", "cidade" => "SP", 1 => "um" }   # "hash rocket": qualquer tipo de chave
```

🔴 A sintaxe `{ nome: "Ana" }` em Ruby cria a chave como **Symbol** (`:nome`), enquanto em JS a chave é uma **string**:

```ruby
pessoa[:nome]       # => "Ana"
pessoa["nome"]      # => nil   (chave string é outra coisa!)
```

## Acessar e alterar

```javascript
pessoa.nome;
pessoa["nome"];
pessoa.cidade = "SP";
delete pessoa.idade;
"nome" in pessoa;
pessoa.inexistente;      // undefined
```

```ruby
pessoa[:nome]                # => "Ana"
pessoa[:cidade] = "SP"       # adiciona
pessoa.delete(:idade)        # remove (devolve o valor)
pessoa.key?(:nome)           # => true   (has_key?, include?)
pessoa[:inexistente]         # => nil
pessoa.fetch(:nome)          # => "Ana"
pessoa.fetch(:x)             # erro: KeyError
pessoa.fetch(:x, "padrão")   # => "padrão"
pessoa.dig(:endereco, :rua)  # navegação segura em aninhados
```

🔴 Não existe `pessoa.nome` em Hash (isso é para objetos de classe). Use `[]`.

## Equivalências de métodos

| Tarefa | JavaScript | Ruby |
|--------|-----------|------|
| Chaves | `Object.keys(o)` | `h.keys` |
| Valores | `Object.values(o)` | `h.values` |
| Pares | `Object.entries(o)` | `h.to_a` / `h.each_pair` |
| Tamanho | `Object.keys(o).length` | `h.size` / `h.length` / `h.count` |
| Mesclar | `{ ...a, ...b }` / `Object.assign` | `a.merge(b)` |
| De pares para objeto | `Object.fromEntries(p)` | `p.to_h` |
| Filtrar | `Object.fromEntries(Object.entries(o).filter(...))` | `h.select { \|k, v\| ... }` |
| Transformar valores | idem com `map` | `h.transform_values { \|v\| ... }` |
| Transformar chaves | idem com `map` | `h.transform_keys(&:to_s)` |
| Selecionar chaves | desestruturação / `pick` | `h.slice(:a, :b)` |
| Excluir chaves | desestruturação / `omit` | `h.except(:a)` |
| Valor padrão | `o.x ?? padrao` | `h.fetch(:x, padrao)` / `Hash.new(0)` |
| Vazio? | `Object.keys(o).length === 0` | `h.empty?` |
| Inverter | manual | `h.invert` |
| Chave do maior valor | manual | `h.max_by { \|_, v\| v }` |
| Ordenar | manual | `h.sort_by { \|k, v\| v }.to_h` |

```javascript
const preco = { cafe: 5, pao: 2, leite: 7 };
Object.entries(preco).forEach(([k, v]) => console.log(k, v));
const dobro = Object.fromEntries(Object.entries(preco).map(([k, v]) => [k, v * 2]));
const caros = Object.fromEntries(Object.entries(preco).filter(([, v]) => v > 3));
```

```ruby
preco = { cafe: 5, pao: 2, leite: 7 }
preco.each { |k, v| puts "#{k}: #{v}" }
dobro = preco.transform_values { |v| v * 2 }       # => { cafe: 10, pao: 4, leite: 14 }
caros = preco.select { |_, v| v > 3 }              # => { cafe: 5, leite: 7 }
preco.map { |k, v| "#{k}=#{v}" }                   # => ["cafe=5", "pao=2", "leite=7"] (map em Hash → Array)
preco.sum { |_, v| v }                             # => 14
preco.values.sum
```

🔴 `select`/`reject`/`filter_map` em Hash: `select` e `reject` devolvem **Hash**; `map` devolve **Array**.

## Valores padrão: `Hash.new`

```javascript
const contagem = {};
for (const p of palavras) contagem[p] = (contagem[p] || 0) + 1;
```

```ruby
contagem = Hash.new(0)
palavras.each { |p| contagem[p] += 1 }

palavras.tally                          # => direto!

agrupado = Hash.new { |h, k| h[k] = [] }   # valor padrão novo a cada chave
agrupado[:a] << 1
```

🔴 `Hash.new([])` compartilha o **mesmo array** entre todas as chaves. Use o bloco:

```ruby
h = Hash.new([])
h[:a] << 1
h[:b]          # => [1]   (!!!)
h = Hash.new { |hash, chave| hash[chave] = [] }   # correto
```

## Ordem das chaves

- Hash em Ruby **sempre preserva a ordem de inserção**.
- Em JS, a ordem segue regras próprias (chaves numéricas inteiras vêm primeiro, em ordem crescente).

## Chaves de qualquer tipo

```ruby
h = { 1 => "um", [1, 2] => "par", nil => "nada", "x" => 1, :x => 2 }
```

Em JS, as chaves de um objeto viram **strings** (ou symbols). Para chaves arbitrárias, usa-se `Map`; em Ruby, o próprio Hash já faz isso.

## Desestruturação

```javascript
const { nome, idade } = pessoa;
const { nome: n, ...resto } = pessoa;
function f({ a, b = 2 }) {}
```

```ruby
# Pattern matching (Ruby 3+)
case pessoa
in { nome:, idade: }
  puts "#{nome} (#{idade})"
end

# Atribuição simples
nome, idade = pessoa.values_at(:nome, :idade)

# Em parâmetros: argumentos nomeados
def f(a:, b: 2); end
f(**{ a: 1 })

# Hash#in
if pessoa in { nome: String => n }
  puts n
end
```

## Shorthand (Ruby 3.1+)

```javascript
const nome = "Ana", idade = 30;
const p = { nome, idade };       // shorthand do ES6
```

```ruby
nome = "Ana"; idade = 30
p = { nome:, idade: }            # Ruby 3.1+: omitir o valor
```

## Objetos com comportamento: classes

Em JS, é comum criar objetos literais com métodos. Em Ruby, use **classes**:

```javascript
const conta = {
  saldo: 100,
  depositar(v) { this.saldo += v; return this; }
};
conta.depositar(50);
conta.saldo;
```

```ruby
class Conta
  attr_reader :saldo

  def initialize(saldo) = @saldo = saldo

  def depositar(v)
    @saldo += v
    self
  end
end

conta = Conta.new(100)
conta.depositar(50)
conta.saldo            # => 150
```

Para dados simples, use **Struct** ou **Data**:

```ruby
Ponto = Struct.new(:x, :y)             # mutável
pt = Ponto.new(1, 2)
pt.x                                   # => 1
pt.x = 10
pt.to_a                                # => [10, 2]

Coordenada = Data.define(:lat, :lng)   # imutável (Ruby 3.2+)
c = Coordenada.new(lat: -23.5, lng: -46.6)
c.with(lat: 0)                         # cópia alterada
```

`Struct` e `Data` fazem o papel do objeto literal "de dados" do JS, com campos definidos e métodos ( `==`, `to_h`, `inspect`).

## JSON: ida e volta

```javascript
const texto = JSON.stringify(pessoa);
const obj = JSON.parse(texto);
obj.nome;
```

```ruby
require "json"
texto = pessoa.to_json                         # => "{\"nome\":\"Ana\",...}"
JSON.generate(pessoa)
JSON.pretty_generate(pessoa)

obj = JSON.parse(texto)                        # chaves viram STRINGS
obj["nome"]
obj = JSON.parse(texto, symbolize_names: true) # chaves viram symbols
obj[:nome]
```

🔴 `JSON.parse` devolve **chaves string** por padrão. Use `symbolize_names: true` para trabalhar com `:nome`.

## Copiando e congelando

```javascript
const copia = { ...pessoa };                // cópia rasa
const funda = structuredClone(pessoa);       // cópia profunda
Object.freeze(pessoa);
```

```ruby
copia = pessoa.dup                           # cópia rasa
funda = Marshal.load(Marshal.dump(pessoa))   # cópia profunda (idiomática)
pessoa.freeze
pessoa[:x] = 1                               # erro: FrozenError
```

## Resumo

- `{}` JS → **Hash** (dados), **Struct/Data** (registro) ou **classe** (comportamento).
- Chaves em Ruby são normalmente **symbols**; acesse com `h[:chave]`, nunca `h.chave`.
- `Object.entries/fromEntries/keys/values` → `to_a`/`to_h`/`keys`/`values`; `select` e `transform_values` fazem o trabalho do `Object.fromEntries(...map)`.
- Hashes preservam ordem e aceitam qualquer tipo de chave; `Hash.new(0)` e `tally` facilitam contagem.
- `JSON.parse` retorna chaves string, salvo `symbolize_names: true`.

## Exercícios

1. Converta `const livro = { titulo: "X", autor: "Y" }` para Ruby e mostre `livro[:titulo]` e `livro["titulo"]`.
2. Crie um Hash de preços e dobre todos os valores com `transform_values`.
3. Conte a frequência de letras de uma palavra com `Hash.new(0)` e com `tally`.
4. Filtre o Hash para manter só os valores maiores que 3 e mostre o tipo do resultado; depois use `map` e compare o tipo.
5. Converta um array de pares `[[:a, 1], [:b, 2]]` em Hash.
6. Faça `JSON.parse` de um texto JSON, acesse com strings e depois com symbols.
7. Modele um `Ponto` como `Struct` e como `Data` e compare mutabilidade.
