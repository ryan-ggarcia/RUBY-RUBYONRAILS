# ============================================================
# QUESTÃO: SISTEMA DE CAIXA DE MERCADO EM RUBY
# ============================================================
#
# OBJETIVO:
# Criar um sistema simples de mercado praticando:
# - Classes e objetos
# - Herança
# - Métodos (funções)
# - Hashes
# - Arrays
# - Condicionais (if/else/case)
# - Laços de repetição (loop/each)
#
# COMO USAR:
# Salve este arquivo como mercadinho.rb e execute:
# ruby mercadinho.rb
#
# Este código é um exemplo-base comentado para explicar durante a aula.
# ============================================================


# ------------------------------------------------------------
# 1. CLASSE BASE: PRODUTO
# ------------------------------------------------------------

# primeiramente para nos ajudar a entender melhor vamos praticar, vamos fazer um sistema de super-mercado
# simples, com produtos, carrinho de compras e o tipo de produto(alimento, limpeza, frios).

#primeiro vamos começar com  a classe de Produto para guardarmos as informações q serao importantes na hora da compra
# ou pra cadastrar um novo produto por exemplo

class Produto
  # attr_accessor cria métodos para ler e alterar estes atributos:
  # nome, codigo, valor e quantidade.
  attr_accessor :nome, :codigo, :valor, :quantidade

  # initialize é executado quando criamos um objeto com Produto.new.
  # Os parâmetros recebidos são guardados nas variáveis de instância
  # (que começam com @), pertencentes a cada objeto.
  def initialize(nome, codigo, valor, quantidade)
    @nome = nome
    @codigo = codigo
    @valor = valor
    @quantidade = quantidade
  end

  #exemplo em C
  # typedef struct {
  #   char nome[50];
  #   int idade;
  # } Pessoa;
  #
  # Pessoa pessoa = {"Gustavo", 20};
  #
  # pessoa.idade = 21;
  # printf("%d", pessoa.idade);

  #Metodo que calcula o preço de uma quantidade do produto.
  def subtotal(quantidade_comprada)
    @valor * quantidade_comprada
  end
end


# ------------------------------------------------------------
# 2. HERANÇA: ALIMENTO E LIMPEZA
# ------------------------------------------------------------

# Alimento herda de Produto.
# Isso significa que Alimento recebe os atributos e métodos de Produto.
class Alimento < Produto
  attr_accessor :validade

  # A classe filha recebe os dados gerais e também a validade.
  def initialize(nome, codigo, valor, quantidade, validade)
    # super chama o initialize da classe Produto, reutilizando o código.
    super(nome, codigo, valor, quantidade)# ->serve para q vc puxe as variaveis a classe pai, sempre q tiver
    @validade = validade                   # hereança tera super
  end
end

# Limpeza também herda de Produto, mas possui um atributo específico:
# volume (por exemplo, 500 ml ou 2 litros).
class Limpeza < Produto
  attr_accessor :volume

  def initialize(nome, codigo, valor, quantidade, volume)
    super(nome, codigo, valor, quantidade)
    @volume = volume
  end
end


# ------------------------------------------------------------
# 3. CLASSE RESPONSÁVEL PELO CAIXA
# ------------------------------------------------------------
class Mercadinho
  def initialize

    @produtos = {
      "12" => Alimento.new("Arroz", "12", 12.00, 10, "12/2027"),
      "13" => Alimento.new("Feijão", "13", 8.00, 8, "10/2027"),
      "5"  => Alimento.new("Carne", "5", 20.00, 5, "25/10/2026"),
      "20" => Limpeza.new("Detergente", "20", 3.50, 12, "500 ml")
    }#aqui usaremos hash para controlar nosso estoque, sendo o codigo de produto a chave e o
    # objeto(alimenticio ou limpeza) o valor, isso facilita no gerenciamento, ja q basta apenas o
    # codigo para localizarmos o poduto, sera mais facil para as proximas funções

    # Array: começa vazio e receberá os itens escolhidos para a compra.
    # Cada item será um hash com o objeto Produto e a quantidade comprada.
    @carrinho = []

    #usar hash nos ajuda tambem para acesar um produto, ao inves de percorrermos toda uma array ate encontrar o produto
    # que queremos, apenas acessamos o chave diretamente q nos leva direto ao produto q queremos
  end

  # ----------------------------------------------------------
  # 4. MENU PRINCIPAL
  # ----------------------------------------------------------
  def menu
    # loop repete o menu até que a opção "0" execute break.
    loop do
      puts "\n===== MERCADINHO QUALQUER ====="
      puts "1 - Listar produtos"
      puts "2 - Cadastrar produto"
      puts "3 - Adicionar produto ao carrinho"
      puts "4 - Visualizar carrinho"
      puts "5 - Finalizar compra"
      puts "0 - Sair"
      print "Escolha uma opção: "

      # gets lê o que foi digitado; chomp remove a quebra de linha.
      # to_i converte a entrada para inteiro para o case comparar números.
      opcao = gets.chomp.to_i

      case opcao
      when 1
        listar_produtos
      when 2
        cadastrar_produto
      when 3
        adicionar_carrinho
      when 4
        visualizar_carrinho
      when 5
        finalizar_compra
      when 0
        puts "Programa encerrado!"
        break
      else
        # else é executado quando a opção não corresponde a nenhum when.
        puts "Opção inválida!"
      end
    end
  end

  # ----------------------------------------------------------
  # 5. LISTAR PRODUTOS
  # ----------------------------------------------------------
  def listar_produtos
    puts "\n===== PRODUTOS DISPONÍVEIS ====="

    # each percorre os pares do hash:
    # codigo recebe a chave; produto recebe o objeto armazenado.
    @produtos.each do |codigo, produto|
      puts "Código: #{codigo}"
      puts "Nome: #{produto.nome}"
      puts "Valor: R$ #{format('%.2f', produto.valor)}"
      puts "Estoque: #{produto.quantidade}"

      # is_a? verifica a classe real do objeto.
      # Assim, podemos exibir os atributos específicos das classes filhas.
      if produto.is_a?(Alimento)
        puts "Validade: #{produto.validade}"
      elsif produto.is_a?(Limpeza)
        puts "Volume: #{produto.volume}"
      end

      puts "-----------------------------"
    end
  end

  # ----------------------------------------------------------
  # 6. CADASTRAR PRODUTO
  # ----------------------------------------------------------
  def cadastrar_produto
    puts "\n===== CADASTRAR PRODUTO ====="
    puts "1 - Alimento"
    puts "2 - Produto de limpeza"
    print "Tipo do produto: "
    tipo = gets.chomp

    print "Nome: "
    nome = gets.chomp

    print "Código: "
    codigo = gets.chomp

    # Verifica se o código já existe como chave do hash.
    if @produtos.key?(codigo)
      puts "Já existe um produto com esse código!"
      return
    end

    print "Valor: R$ "
    valor = gets.chomp.to_f

    print "Quantidade em estoque: "
    quantidade = gets.chomp.to_i

    # Validações básicas para impedir valores inválidos.
    if nome.empty? || valor <= 0 || quantidade < 0
      puts "Dados inválidos. Confira nome, valor e quantidade."
      return
    end

    # Dependendo do tipo, criamos um objeto de uma classe filha diferente.
    case tipo
    when "1"
      print "Validade (ex.: 12/2027): "
      validade = gets.chomp
      produto = Alimento.new(nome, codigo, valor, quantidade, validade)
    when "2"
      print "Volume (ex.: 500 ml): "
      volume = gets.chomp
      produto = Limpeza.new(nome, codigo, valor, quantidade, volume)
    else
      puts "Tipo inválido!"
      return
    end

    # Adiciona uma nova entrada ao hash: código => objeto Produto.
    @produtos[codigo] = produto
    puts "Produto cadastrado com sucesso!"
  end

  # ----------------------------------------------------------
  # 7. ADICIONAR PRODUTO AO CARRINHO
  # ----------------------------------------------------------
  def adicionar_carrinho
    puts "\n===== ADICIONAR AO CARRINHO ====="
    print "Digite o código do produto: "
    codigo = gets.chomp

    # Procura o objeto no hash usando o código como chave.
    produto = @produtos[codigo]

    # Se a chave não existir, o resultado será nil.
    if produto.nil?
      puts "Produto não encontrado!"
      return
    end

    print "Quantidade desejada: "
    quantidade = gets.chomp.to_i

    if quantidade <= 0
      puts "A quantidade deve ser maior que zero."
      return
    end

    # Verifica se há estoque suficiente antes de colocar no carrinho.
    # O estoque só será reduzido quando a compra for finalizada.
    if quantidade > produto.quantidade
      puts "Estoque insuficiente! Disponível: #{produto.quantidade}"
      return
    end

    # Procura se esse produto já está no carrinho.
    item = @carrinho.find { |linha| linha[:produto].codigo == codigo }

    if item
      # Se já existe, soma a quantidade escolhida à quantidade anterior.
      # Também confere se o total no carrinho não ultrapassa o estoque.
      nova_quantidade = item[:quantidade] + quantidade

      if nova_quantidade > produto.quantidade
        puts "Essa quantidade ultrapassa o estoque disponível."
        return
      end

      item[:quantidade] = nova_quantidade
    else
      # << adiciona um novo hash ao array do carrinho.
      #:produto e :quantidade são chaves do hash que representa a linha.
      @carrinho << { produto: produto, quantidade: quantidade }
    end

    puts "Produto adicionado ao carrinho!"
  end

  # ----------------------------------------------------------
  # 8. VISUALIZAR CARRINHO
  # ----------------------------------------------------------
  def visualizar_carrinho
    puts "\n===== CARRINHO ====="

    if @carrinho.empty?
      puts "O carrinho está vazio."
      return
    end

    # Cada item do array é um hash com o produto e a quantidade comprada.
    @carrinho.each do |item|
      produto = item[:produto]
      quantidade = item[:quantidade]
      subtotal = produto.subtotal(quantidade)

      puts "#{produto.nome} - #{quantidade} x R$ #{format('%.2f', produto.valor)}"
      puts "Subtotal: R$ #{format('%.2f', subtotal)}"
    end

    puts "Total: R$ #{format('%.2f', calcular_total)}"
  end

  # ----------------------------------------------------------
  # 9. METODO PARA CALCULAR O TOTAL
  # ----------------------------------------------------------
  def calcular_total
    total = 0.0

    # Soma o subtotal de cada item do carrinho.
    @carrinho.each do |item|
      produto = item[:produto]
      quantidade = item[:quantidade]
      total += produto.subtotal(quantidade)
    end

    # O valor retornado por este metodo será usado na finalização.
    total
  end

  # ----------------------------------------------------------
  # 10. FINALIZAR COMPRA
  # ----------------------------------------------------------
  def finalizar_compra
    puts "\n===== FINALIZAR COMPRA ====="

    if @carrinho.empty?
      puts "Não é possível finalizar: o carrinho está vazio."
      return
    end

    total = calcular_total
    puts "Total da compra: R$ #{format('%.2f', total)}"
    print "Valor recebido: R$ "
    recebido = gets.chomp.to_f

    if recebido < total
      puts "Valor insuficiente. A compra não foi finalizada."
      return
    end

    # Somente depois do pagamento suficiente, atualizamos o estoque.
    @carrinho.each do |item|
      produto = item[:produto]
      produto.quantidade -= item[:quantidade]
    end

    troco = recebido - total
    puts "Compra finalizada com sucesso!"
    puts "Troco: R$ #{format('%.2f', troco)}"

    # Limpa os itens para que a próxima compra comece vazia.
    @carrinho.clear
  end
end

# ------------------------------------------------------------
# 11. INICIAR O PROGRAMA
# ------------------------------------------------------------

# Cria um objeto da classe Mercadinho e chama o menu.
mercado = Mercadinho.new
mercado.menu
