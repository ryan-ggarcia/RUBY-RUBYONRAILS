# 10 — Erros e exceções

## `try/catch/finally` → `begin/rescue/ensure`

```javascript
try {
  const dados = JSON.parse(texto);
  processar(dados);
} catch (e) {
  console.error("Falhou:", e.message);
} finally {
  console.log("sempre executa");
}
```

```ruby
begin
  dados = JSON.parse(texto)
  processar(dados)
rescue JSON::ParserError => e
  puts "Falhou: #{e.message}"
ensure
  puts "sempre executa"
end
```

| JavaScript | Ruby |
|-----------|------|
| `try` | `begin` |
| `catch (e)` | `rescue => e` |
| `finally` | `ensure` |
| `throw new Error("x")` | `raise "x"` / `raise StandardError, "x"` |
| `error.message` | `e.message` |
| `error.stack` | `e.backtrace` |
| `instanceof` no catch | `rescue TipoErro` |
| (não existe) | `else` e `retry` |

## Capturando tipos diferentes

```javascript
try { ... }
catch (e) {
  if (e instanceof TypeError) { ... }
  else if (e instanceof RangeError) { ... }
  else throw e;
}
```

```ruby
begin
  ...
rescue ZeroDivisionError => e
  puts "divisão por zero"
rescue ArgumentError, TypeError => e     # vários tipos juntos
  puts "argumento ruim: #{e.message}"
rescue => e                              # StandardError (equivale ao "catch" genérico)
  puts "outro erro: #{e.class}"
  raise                                  # relança o erro atual
end
```

🔴 `rescue` sem tipo captura apenas `StandardError` e seus filhos — o que é correto. **Não** capture `Exception` (pegaria `SystemExit`, `Interrupt` e outros).

Ordem: coloque os `rescue` mais específicos primeiro.

## `else` e `retry`

```ruby
begin
  tentativas ||= 0
  chamar_api
rescue Timeout::Error
  tentativas += 1
  retry if tentativas < 3          # tenta de novo desde o begin
  puts "desisti"
else
  puts "sucesso (nenhum erro)"     # só roda se não houve exceção
ensure
  limpar
end
```

## `rescue` em métodos e blocos (sem `begin`)

```ruby
def ler_arquivo(caminho)
  File.read(caminho)
rescue Errno::ENOENT
  "arquivo não encontrado"
ensure
  puts "fim"
end

[1, 0, 2].each do |n|
  puts 10 / n
rescue ZeroDivisionError
  puts "pulei o zero"
end
```

Em métodos e blocos `do...end`, `rescue` pode ficar direto no corpo.

## Modificador `rescue` (uso com cuidado)

```ruby
numero = Integer("abc") rescue 0      # engole qualquer StandardError
```

Prático em scripts, ruim em código sério: esconde erros.

## Lançando erros

```javascript
throw new Error("saldo insuficiente");
throw new RangeError("fora do intervalo");
```

```ruby
raise "saldo insuficiente"                              # RuntimeError
raise ArgumentError, "idade inválida"
raise ArgumentError.new("idade inválida")
raise SaldoInsuficienteError.new(saldo, valor)          # classe própria
```

## Exceções personalizadas

```javascript
class SaldoInsuficienteError extends Error {
  constructor(saldo, valor) {
    super(`Saldo ${saldo} insuficiente para ${valor}`);
    this.name = "SaldoInsuficienteError";
    this.saldo = saldo;
  }
}
```

```ruby
class SaldoInsuficienteError < StandardError
  attr_reader :saldo, :valor

  def initialize(saldo, valor)
    @saldo = saldo
    @valor = valor
    super("Saldo #{saldo} insuficiente para #{valor}")
  end
end

begin
  raise SaldoInsuficienteError.new(10, 50)
rescue SaldoInsuficienteError => e
  puts e.message
  puts e.valor
end
```

Herde de `StandardError` (ou de uma classe base própria do seu módulo, para facilitar capturas agrupadas).

## Hierarquia principal

```
Exception
├── NoMemoryError
├── ScriptError (LoadError, NotImplementedError, SyntaxError)
├── SecurityError
├── SignalException (Interrupt)
├── SystemExit
└── StandardError              ← o que você normalmente captura
    ├── ArgumentError
    ├── IOError
    ├── IndexError (KeyError, StopIteration)
    ├── NameError (NoMethodError)
    ├── RangeError (FloatDomainError)
    ├── RuntimeError           ← raise "texto"
    ├── TypeError
    ├── ZeroDivisionError
    └── ...
```

## Erros comuns: equivalências

| Situação | JavaScript | Ruby |
|----------|-----------|------|
| Chamar método em `nil`/`null` | `TypeError: Cannot read properties of null` | `NoMethodError: undefined method 'x' for nil` |
| Variável inexistente | `ReferenceError` | `NameError` |
| Argumentos errados | (silencioso) | `ArgumentError` |
| Dividir por zero (inteiros) | `Infinity` | `ZeroDivisionError` |
| Chave inexistente com `fetch` | — | `KeyError` |
| Tipo errado em conta | coerção | `TypeError` |
| Arquivo inexistente | `ENOENT` | `Errno::ENOENT` |
| JSON inválido | `SyntaxError` | `JSON::ParserError` |

## Erros de fluxo x `catch/throw`

Ruby tem `catch`/`throw` (**não** relacionados a exceções) para sair de laços aninhados:

```ruby
resultado = catch(:achou) do
  matriz.each do |linha|
    linha.each { |x| throw :achou, x if x > 10 }
  end
  nil
end
```

## Convenções: métodos com `!` e `raise`

Muitos métodos têm duas versões:

| Segura (retorna `nil`/`false`) | Perigosa (`!`, levanta erro) |
|-------------------------------|-----------------------------|
| `save` | `save!` |
| `Hash#[]` | `Hash#fetch` |
| `Integer(x, exception: false)` | `Integer(x)` |
| `find_by` | `find` |

Escolha conforme queira **tratar** a falha ou **exigir** o sucesso.

## Depuração

```javascript
console.error(e);
debugger;
console.trace();
```

```ruby
p e                      # inspeção rápida
puts e.full_message      # mensagem com backtrace
puts e.backtrace.first(5)
binding.irb              # abre um console no ponto (parecido com debugger)
# gem debug: `debugger` ou binding.break
raise "algo" if ENV["DEBUG"]
```

## Resumo

- `try/catch/finally` → `begin/rescue/ensure`; `throw` → `raise`.
- `rescue` aceita vários tipos; sem tipo pega `StandardError`. Nunca capture `Exception`.
- `else` (sem erro) e `retry` (tentar de novo) são exclusivos do Ruby.
- Em métodos e blocos `do...end` pode-se usar `rescue` sem `begin`.
- Erros próprios herdam de `StandardError`; o Ruby falha mais cedo que o JS (sem coerção silenciosa).

## Exercícios

1. Converta um `try/catch/finally` com `JSON.parse` para `begin/rescue/ensure`.
2. Trate `ZeroDivisionError` ao dividir uma lista de números por zero.
3. Crie `IdadeInvalidaError` com atributo `idade` e lance-a de um método.
4. Implemente uma função com `retry` que tenta até 3 vezes e depois desiste.
5. Compare `Integer("abc")` com `"abc".to_i` quanto a exceções.
6. Explique por que `rescue Exception` é má prática.
