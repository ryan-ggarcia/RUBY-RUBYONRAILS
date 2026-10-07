# 12 — Assincronia e I/O

## O modelo de execução

| | JavaScript | Ruby |
|--|-----------|------|
| Modelo padrão | **Thread única** + event loop | **Síncrono e bloqueante** |
| Concorrência | `async/await`, Promises, callbacks | Threads, Fibers, Ractors, gems (`async`) |
| I/O | Não bloqueante por padrão | Bloqueante por padrão |
| Paralelismo real | Web Workers, `worker_threads` | Processos (`fork`), Ractors; threads da MRI têm **GVL** |

Em JS, quase toda operação de I/O é assíncrona e você precisa de `await`. Em Ruby, `File.read` e `Net::HTTP.get` **simplesmente bloqueiam** até terminar e devolvem o valor — sem `await`, sem Promise.

```javascript
const texto = await fs.promises.readFile("a.txt", "utf8");
const resposta = await fetch("https://api.exemplo.com/dados");
const dados = await resposta.json();
```

```ruby
texto = File.read("a.txt")
dados = JSON.parse(Net::HTTP.get(URI("https://api.exemplo.com/dados")))
```

Código Ruby típico é **linear** e fácil de ler. No Rails, cada requisição roda em sua própria thread/processo, então o bloqueio de uma não trava as demais.

## Concorrência em Ruby

### Threads

```javascript
const resultados = await Promise.all([
  fetch(url1).then(r => r.json()),
  fetch(url2).then(r => r.json()),
]);
```

```ruby
threads = [url1, url2].map do |url|
  Thread.new { JSON.parse(Net::HTTP.get(URI(url))) }
end
resultados = threads.map(&:value)       # espera e coleta (equivale a Promise.all)
```

- `Thread.new { ... }` inicia uma tarefa concorrente.
- `thread.value` espera o término e devolve o valor; `thread.join` só espera.
- Na MRI, o **GVL** (Global VM Lock) permite que só uma thread execute código Ruby por vez, mas libera durante I/O: threads **ajudam em I/O** (HTTP, banco, disco), não em cálculo pesado.
- Para CPU em paralelo: **processos** (`fork`, `Process`), `Ractor`, ou JRuby/TruffleRuby.

Dados compartilhados exigem proteção:

```ruby
mutex = Mutex.new
contador = 0
10.times.map { Thread.new { 1000.times { mutex.synchronize { contador += 1 } } } }.each(&:join)
```

Para comunicação: `Queue`.

### Fibers e a gem `async`

Fibers são corrotinas leves; a gem **`async`** oferece um modelo parecido com o do JS (event loop) sobre elas:

```ruby
require "async"
require "async/http/internet"

Async do
  internet = Async::HTTP::Internet.new
  tarefas = [url1, url2].map do |url|
    Async { internet.get(url).read }
  end
  corpos = tarefas.map(&:wait)
ensure
  internet&.close
end
```

Útil para muitos I/Os simultâneos (Ruby 3 tem *Fiber scheduler* embutido).

### Jobs em segundo plano (o "setTimeout/fila" do dia a dia)

```javascript
setTimeout(() => enviarEmail(usuario), 0);
```

No Rails, tarefas demoradas vão para **jobs** (Active Job + Sidekiq/Solid Queue):

```ruby
class EnviarEmailJob < ApplicationJob
  def perform(usuario)
    UsuarioMailer.boas_vindas(usuario).deliver_now
  end
end

EnviarEmailJob.perform_later(usuario)
```

## Tempo e espera

```javascript
await new Promise(r => setTimeout(r, 1000));
setInterval(tick, 1000);
```

```ruby
sleep 1                      # bloqueia a thread atual por 1 segundo
sleep 0.5

# repetir a cada segundo (em thread própria)
Thread.new { loop { tick; sleep 1 } }

require "timeout"
Timeout.timeout(5) { operacao_lenta }   # levanta Timeout::Error
```

## Lazy e geradores

O equivalente de geradores (`function*`) é o `Enumerator`:

```javascript
function* naturais() { let n = 1; while (true) yield n++; }
```

```ruby
naturais = Enumerator.new do |y|
  n = 1
  loop { y << n; n += 1 }
end

naturais.take(3)                           # => [1, 2, 3]
naturais.lazy.select(&:even?).first(3)     # => [2, 4, 6]
naturais.next                              # => 1 (iteração manual)
```

## Entrada e saída (console)

```javascript
console.log("texto");
console.error("erro");
process.stdout.write("sem quebra");
const rl = readline.createInterface({ input: process.stdin });
```

```ruby
puts "texto"                 # com quebra
print "sem quebra"
$stderr.puts "erro"          # ou warn "erro"
pp objeto                    # imprime estruturas legíveis
nome = gets.chomp            # lê uma linha do teclado
```

Entrada completa:

```ruby
STDIN.each_line { |linha| puts linha.upcase }
entrada = STDIN.read
```

## Arquivos

```javascript
import fs from "node:fs";
fs.readFileSync("a.txt", "utf8");
fs.writeFileSync("b.txt", "conteúdo");
fs.appendFileSync("b.txt", "mais");
fs.existsSync("a.txt");
fs.readdirSync(".");
fs.unlinkSync("b.txt");
```

```ruby
File.read("a.txt")                  # lê tudo
File.readlines("a.txt", chomp: true)   # array de linhas
File.write("b.txt", "conteúdo")      # grava (sobrescreve)
File.write("b.txt", "mais", mode: "a")   # acrescenta
File.exist?("a.txt")
Dir.children(".")                    # lista nomes
Dir.glob("**/*.rb")                  # busca por padrão
File.delete("b.txt")
File.basename("/x/y/arq.rb")         # => "arq.rb"
File.extname("arq.rb")               # => ".rb"
File.join("pasta", "arq.rb")         # => "pasta/arq.rb"
```

Leitura/escrita com bloco (fecha o arquivo automaticamente — o equivalente ao `try/finally`):

```ruby
File.open("a.txt") do |arquivo|
  arquivo.each_line { |linha| puts linha }
end

File.open("saida.txt", "w") do |f|
  f.puts "linha 1"
  f.puts "linha 2"
end
```

Bibliotecas: `FileUtils` (`mkdir_p`, `cp`, `mv`, `rm_rf`) e `Pathname` (caminhos orientados a objeto).

## HTTP

```javascript
const r = await fetch("https://api.exemplo.com/usuarios", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ nome: "Ana" }),
});
const dados = await r.json();
```

```ruby
require "net/http"
require "json"

uri = URI("https://api.exemplo.com/usuarios")
resposta = Net::HTTP.post(
  uri,
  { nome: "Ana" }.to_json,
  "Content-Type" => "application/json"
)
dados = JSON.parse(resposta.body)
resposta.code            # => "201"
```

Com a gem **HTTParty** (ou Faraday), fica mais próximo do `axios`:

```ruby
require "httparty"
r = HTTParty.post("https://api.exemplo.com/usuarios",
                  body: { nome: "Ana" }.to_json,
                  headers: { "Content-Type" => "application/json" })
r.parsed_response
r.code
```

## Datas e horas

```javascript
const agora = new Date();
agora.getFullYear();
agora.toISOString();
new Date(2025, 0, 15);
```

```ruby
agora = Time.now
agora.year
agora.iso8601                         # require "time"
Time.new(2025, 1, 15)
Date.new(2025, 1, 15)                 # require "date"
Date.today + 7                        # daqui a 7 dias
agora.strftime("%d/%m/%Y %H:%M")
# Rails: 3.days.ago, 1.week.from_now, Time.current
```

## Regex

```javascript
const m = "abc123".match(/\d+/);
m?.[0];
"a1b2".replace(/\d/g, "#");
/^\w+@\w+\.\w+$/.test(email);
```

```ruby
m = "abc123".match(/\d+/)
m&.[](0)                              # ou m[0] se não for nil
"a1b2".gsub(/\d/, "#")
email.match?(/\A\w+@\w+\.\w+\z/)

if "João 25" =~ /(\w+) (\d+)/
  puts $1, $2
end
```

🔴 Em Ruby, `^` e `$` casam **início e fim de linha**; use `\A` e `\z` para início e fim da **string** inteira (importante em validações).

## Resumo

- JS é assíncrono por padrão (`await`); Ruby é **síncrono e bloqueante** — sem `async/await` no código comum.
- Para concorrência: `Thread` (bom em I/O; GVL limita CPU), processos, Ractors, Fibers e a gem `async`.
- Tarefas de fundo no Rails: **jobs**, não `setTimeout`.
- I/O de arquivos é direto (`File.read/write/open`) e `File.open` com bloco fecha sozinho.
- `Net::HTTP`/HTTParty ≈ `fetch`/`axios`; `Enumerator` ≈ geradores.

## Exercícios

1. Leia um arquivo e conte as linhas e palavras em Ruby.
2. Escreva um arquivo com três linhas e depois acrescente uma quarta.
3. Busque dois URLs em threads e combine os resultados (o equivalente a `Promise.all`).
4. Converta `await new Promise(r => setTimeout(r, 2000))` para Ruby.
5. Crie um `Enumerator` de números de Fibonacci e pegue os 10 primeiros de forma preguiçosa.
6. Faça uma requisição GET para uma API pública e imprima um campo do JSON.
7. Explique por que threads aceleram um script que baixa 10 páginas, mas não um cálculo de números primos (MRI).
