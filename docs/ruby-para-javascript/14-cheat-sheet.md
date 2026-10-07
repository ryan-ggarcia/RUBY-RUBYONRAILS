# 14 — Cheat sheet: JavaScript → Ruby

Consulta rápida. Detalhes nos documentos anteriores.

## Básico

| JavaScript | Ruby |
|-----------|------|
| `console.log(x)` | `puts x` / `p x` |
| `// comentário` | `# comentário` |
| `let x = 1` / `const X = 1` | `x = 1` / `X = 1` |
| `` `Olá ${nome}` `` | `"Olá #{nome}"` |
| `null` / `undefined` | `nil` |
| `typeof x` | `x.class` |
| `x === y` | `x == y` |
| `x !== y` | `x != y` |
| `x ?? y` | `x.nil? ? y : x` |
| `x?.y` | `x&.y` |
| `i++` | `i += 1` |
| `a ** b` | `a ** b` |
| `Math.floor(a / b)` | `a / b` (inteiros) |
| `Math.round(x)` | `x.round` |
| `Math.max(a, b)` | `[a, b].max` |
| `Number(s)` / `parseInt(s)` | `s.to_i` / `Integer(s)` |
| `String(n)` | `n.to_s` |
| `Math.random()` | `rand` |
| `Date.now()` | `Time.now` |
| `process.env.X` | `ENV["X"]` |
| `process.exit(1)` | `exit 1` |

## Controle de fluxo

| JavaScript | Ruby |
|-----------|------|
| `if (x) {} else if (y) {} else {}` | `if x ... elsif y ... else ... end` |
| `if (!x)` | `unless x` |
| `x ? a : b` | `x ? a : b` |
| `switch (x) { case 1: ... break; }` | `case x when 1 then ... end` |
| `for (let i=0;i<n;i++)` | `n.times { \|i\| }` |
| `for (const x of arr)` | `arr.each { \|x\| }` |
| `while (c) {}` | `while c ... end` |
| `do {} while (c)` | `begin ... end while c` |
| `break` / `continue` | `break` / `next` |
| `try/catch/finally` | `begin/rescue/ensure` |
| `throw new Error("x")` | `raise "x"` |

## Funções

| JavaScript | Ruby |
|-----------|------|
| `function f(a, b = 1) {}` | `def f(a, b = 1) ... end` |
| `const f = (a) => a * 2` | `f = ->(a) { a * 2 }` |
| `f(3)` (arrow) | `f.call(3)` / `f.(3)` / `f[3]` |
| `function f(...args)` | `def f(*args)` |
| `function f({ a, b })` | `def f(a:, b:)` |
| `f(...arr)` | `f(*arr)` |
| `return x` | `x` (última expressão) ou `return x` |
| callback `arr.map(x => x*2)` | bloco `arr.map { \|x\| x * 2 }` |
| `arr.map(x => x.up())` | `arr.map(&:up)` |
| `fn(cb)` com `cb()` | método com `yield` |

## Strings

| JavaScript | Ruby |
|-----------|------|
| `s.length` | `s.length` |
| `s.toUpperCase()` / `toLowerCase()` | `s.upcase` / `s.downcase` |
| `s.trim()` | `s.strip` |
| `s.includes("a")` | `s.include?("a")` |
| `s.startsWith("a")` | `s.start_with?("a")` |
| `s.split(",")` | `s.split(",")` |
| `s.replace(/a/g, "b")` | `s.gsub("a", "b")` |
| `s.slice(1, 3)` | `s[1...3]` |
| `s.repeat(3)` | `s * 3` |
| `s.padStart(5, "0")` | `s.rjust(5, "0")` |
| `s.at(-1)` | `s[-1]` |
| `[...s]` / `s.split("")` | `s.chars` |
| `s.localeCompare(t)` | `s <=> t` |
| `s.match(/re/)` | `s.match(/re/)` |
| `/re/.test(s)` | `s.match?(/re/)` |

## Arrays

| JavaScript | Ruby |
|-----------|------|
| `a.push(x)` | `a << x` / `a.push(x)` |
| `a.pop()` / `a.shift()` | `a.pop` / `a.shift` |
| `a.unshift(x)` | `a.unshift(x)` |
| `a.at(-1)` | `a.last` / `a[-1]` |
| `a.slice(1, 3)` | `a[1...3]` |
| `a.includes(x)` | `a.include?(x)` |
| `a.indexOf(x)` | `a.index(x)` |
| `a.join(",")` | `a.join(",")` |
| `a.concat(b)` / `[...a, ...b]` | `a + b` |
| `a.map(f)` | `a.map { }` |
| `a.filter(f)` | `a.select { }` / `a.reject { }` |
| `a.find(f)` | `a.find { }` |
| `a.some(f)` / `a.every(f)` | `a.any? { }` / `a.all? { }` |
| `a.reduce((s, x) => s + x, 0)` | `a.sum` / `a.reduce(0) { \|s, x\| s + x }` |
| `a.flat()` | `a.flatten` |
| `a.flatMap(f)` | `a.flat_map { }` |
| `[...new Set(a)]` | `a.uniq` |
| `a.sort((x, y) => x - y)` | `a.sort` |
| `a.sort((x, y) => y - x)` | `a.sort.reverse` / `a.sort { \|x, y\| y <=> x }` |
| `a.reverse()` | `a.reverse` |
| `Math.max(...a)` | `a.max` |
| `a.length === 0` | `a.empty?` |
| `Array.from({length: n}, (_, i) => i)` | `(0...n).to_a` |
| `a.forEach((x, i) => ...)` | `a.each_with_index { \|x, i\| ... }` |
| `Object.groupBy(a, f)` | `a.group_by { }` |
| `[a, b] = [b, a]` | `a, b = b, a` |

## Objetos / Hashes

| JavaScript | Ruby |
|-----------|------|
| `{ a: 1 }` | `{ a: 1 }` (chave symbol) |
| `o.a` / `o["a"]` | `h[:a]` |
| `o.a = 2` | `h[:a] = 2` |
| `delete o.a` | `h.delete(:a)` |
| `"a" in o` | `h.key?(:a)` |
| `Object.keys(o)` | `h.keys` |
| `Object.values(o)` | `h.values` |
| `Object.entries(o)` | `h.to_a` / `h.each { \|k, v\| }` |
| `Object.fromEntries(e)` | `e.to_h` |
| `{ ...a, ...b }` | `a.merge(b)` |
| `{ a, b }` (shorthand) | `{ a:, b: }` (Ruby 3.1+) |
| `o?.a?.b` | `h.dig(:a, :b)` |
| `const { a, b } = o` | `a, b = h.values_at(:a, :b)` / `in { a:, b: }` |
| `JSON.stringify(o)` | `o.to_json` |
| `JSON.parse(s)` | `JSON.parse(s)` (chaves string) |
| `structuredClone(o)` | `Marshal.load(Marshal.dump(h))` |
| `Object.freeze(o)` | `h.freeze` |
| `new Map()` | `{}` / `Hash.new` |

## Classes

| JavaScript | Ruby |
|-----------|------|
| `class A { }` | `class A ... end` |
| `constructor(x) { this.x = x }` | `def initialize(x) = @x = x` |
| `new A(1)` | `A.new(1)` |
| `class B extends A` | `class B < A` |
| `super(x)` | `super(x)` |
| `this.x` | `@x` |
| `this` | `self` |
| `static f() {}` | `def self.f ... end` |
| `get x() {}` / `set x(v) {}` | `attr_accessor :x` |
| `#privado` | `private` |
| `x instanceof A` | `x.is_a?(A)` |
| `toString()` | `to_s` |
| `Object.assign(Classe.prototype, mixin)` | `include Modulo` |
| `obj[nome]()` | `obj.send(:nome)` |

## Módulos e ferramentas

| JavaScript | Ruby |
|-----------|------|
| `import x from "pkg"` | `require "pkg"` |
| `import x from "./arq"` | `require_relative "arq"` |
| `package.json` | `Gemfile` |
| `npm install` | `bundle install` |
| `npm i axios` | `bundle add httparty` |
| `npx jest` | `bundle exec rspec` |
| `node app.js` | `ruby app.rb` |
| `node` (REPL) | `irb` |
| `npm run dev` | `bin/rails server` |
| `eslint` / `prettier` | `rubocop` |
| `jest` | `rspec` / `minitest` |

## Valores falsy

| Valor | JS | Ruby |
|-------|----|------|
| `false` | falsy | falsy |
| `null` / `undefined` / `nil` | falsy | falsy |
| `0` | falsy | **truthy** |
| `""` | falsy | **truthy** |
| `NaN` | falsy | truthy |
| `[]`, `{}` | truthy | truthy |

## Sufixos e prefixos de nomes em Ruby

| Marca | Significado | Exemplo |
|-------|-------------|---------|
| `?` | Retorna booleano | `vazio?`, `include?` |
| `!` | Perigoso / altera o objeto | `sort!`, `save!` |
| `=` | Setter | `nome=` |
| `:x` | Symbol | `:ativo` |
| `@x` | Variável de instância | `@nome` |
| `@@x` | Variável de classe | `@@total` |
| `$x` | Variável global | `$stdout` |
| `X` | Constante / classe | `PI`, `Pessoa` |
| `&:x` | Método como bloco | `map(&:upcase)` |
| `*args` / `**opts` | Splat | `def f(*a, **o)` |
