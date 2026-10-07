# 05 — Symbols

## O que é um Symbol

Um **Symbol** é um identificador **leve e imutável**. Começa com `:` e funciona como um **rótulo** ou **nome** — não como um texto que você vai manipular.

```ruby
:nome
:status
:ativo
:pendente
```

Pense em um symbol como uma **etiqueta**: ele não guarda nada dentro, ele **é** o próprio nome.

## Symbol vs. String

À primeira vista parecem iguais, mas se comportam de forma diferente:

```ruby
"nome".object_id   # => um número (ex.: 8)
"nome".object_id   # => outro número (cada string é um objeto novo)

:nome.object_id    # => sempre o mesmo número
:nome.object_id    # => idêntico ao anterior
```

| Característica | String | Symbol |
|----------------|--------|--------|
| Sintaxe | `"nome"` | `:nome` |
| Mutável | Sim | **Não** |
| Novo objeto a cada uso | Sim | **Não** (mesmo objeto) |
| Comparação | Compara caractere a caractere | Compara identidade (mais rápida) |
| Uso típico | Conteúdo, texto | Identificador, chave |
| Tem métodos de texto | Muitos (`upcase`, `split`...) | Poucos |

```ruby
s = "ruby"
s << "!"            # funciona: strings mudam
:ruby << "!"        # erro: NoMethodError (symbols não mudam)
```

## Quando usar cada um

- Use **String** quando o valor é **conteúdo**: nome de uma pessoa, uma mensagem, o texto digitado pelo usuário.
- Use **Symbol** quando o valor é um **identificador** fixo: chaves de hash, estados, nomes de opções.

```ruby
# Conteúdo -> String
nome = "Maria Silva"

# Estado/identificador -> Symbol
status = :ativo
```

## Onde você vai ver symbols

### 1. Chaves de hash

```ruby
pessoa = { nome: "Ana", idade: 30 }
pessoa[:nome]    # => "Ana"
```

### 2. Estados e opções

```ruby
pedido = :pendente
pedido = :enviado
pedido = :cancelado
```

### 3. Nomes de métodos

```ruby
class Pessoa
  attr_accessor :nome, :idade   # :nome e :idade são symbols
end

"ruby".respond_to?(:upcase)     # => true
[1, 2, 3].send(:sum)            # => 6
```

### 4. Argumentos no Rails

```ruby
render :new
redirect_to :root
validates :titulo, presence: true
has_many :tarefas
```

## Criando e convertendo symbols

```ruby
:ativo
:"com espaços"          # symbol com caracteres especiais
"ativo".to_sym          # => :ativo
:ativo.to_s             # => "ativo"
%i[a b c]               # => [:a, :b, :c]  (array de symbols)
```

## Symbol não é constante

Uma confusão comum: symbol **parece** constante porque não muda, mas são coisas diferentes.

| | Constante | Symbol |
|---|-----------|--------|
| Aparência | Começa com maiúscula: `PI` | Começa com `:`: `:pi` |
| O que é | Um **nome** que guarda um valor | Um **valor** que é um rótulo |
| Guarda algo? | Sim (`PI` guarda `3.14`) | Não, ele mesmo é o conteúdo |

```ruby
PI = 3.14      # constante: nome -> valor
:pi            # symbol: o rótulo em si
```

O que têm em comum é a **imutabilidade**.

## Symbols em memória

Cada symbol existe **uma única vez** na memória. Se você usar `:status` mil vezes, é sempre o mesmo objeto. Com strings, mil usos de `"status"` podem criar mil objetos.

```ruby
a = :ativo
b = :ativo
a.equal?(b)      # => true  (mesmo objeto)

c = "ativo"
d = "ativo"
c.equal?(d)      # => false (objetos diferentes)
c == d           # => true  (mesmo conteúdo)
```

Em versões modernas do Ruby, symbols criados dinamicamente são coletados pelo garbage collector quando não são mais usados, então o risco de vazamento de memória com `to_sym` é bem menor que no passado. Mesmo assim, evite converter entrada de usuário em symbols sem necessidade.

## Pegadinha: chave `:nome` não é a mesma que `"nome"`

```ruby
h = { nome: "Ana" }
h[:nome]    # => "Ana"
h["nome"]   # => nil   (chave diferente!)
```

Escolha um padrão (normalmente symbols) e mantenha. Dados vindos de JSON ou formulários costumam ter chaves **string**; o Rails resolve isso com `params` (um hash que aceita as duas formas).

## Sintaxe moderna de hash

```ruby
{ nome: "Ana" }          # moderno: a chave é :nome
{ :nome => "Ana" }       # antigo, equivalente
{ "nome" => "Ana" }      # chave String (diferente)
```

## Resumo

- Symbol = **identificador imutável**, escrito `:assim`.
- Existe uma única cópia por nome na memória e a comparação é rápida.
- Use symbols para **chaves, estados e nomes**; strings para **conteúdo**.
- Não é constante: constante é um nome que guarda valor; symbol é o próprio rótulo.

## Exercícios

1. Crie os symbols `:ativo`, `:pendente` e `:cancelado` e guarde-os em um array.
2. Mostre com `object_id` a diferença entre duas strings iguais e dois symbols iguais.
3. Crie um hash de produto com chaves symbol e acesse o preço.
4. Mostre o que acontece ao acessar `{ nome: "Ana" }["nome"]` e explique.
5. Converta `"em_andamento"` em symbol e o symbol de volta em string.
