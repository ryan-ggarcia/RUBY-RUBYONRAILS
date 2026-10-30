# Em vez de você configurar cada detalhe do projeto, o Rails assume um padrão. Se você seguir os nomes e a estrutura esperados, ele funciona sozinho. Você só escreve configuração quando foge do padrão.



# O controller recebe a requisição, usa o model e decide a resposta (mostrar uma tela ou redirecionar). Ele tem três responsabilidades:

# Ler os dados que chegaram (params)
# Pedir ao model para buscar ou salvar
# Escolher a resposta

# ERRO: o comentário dizia "produtos_controller.rb" e os exemplos usavam Produto (copiado de outro projeto).
# CORREÇÃO: este arquivo é app/controllers/categories_controller.rb e o model é Category.

# ERRO (no arquivo todo): a variável era @categories (plural) para UMA categoria.
# Funciona, mas confunde: plural = lista, singular = um registro.
# CORREÇÃO: @categories só no index (lista) e @category no resto. As views foram ajustadas junto.
class CategoriesController < ApplicationController
  # before_action: roda set_category ANTES dessas actions. Evita repetir o find em cada uma.
  before_action :set_category, only: %i[show edit update destroy]

  # GET /categories
  def index
    # Category.all busca todos os registros.
    # @categories (com @) é uma variável de instância. Ela fica disponível na view index.html.erb. É assim que o controller entrega dados para a tela.
    # Não há render: o Rails renderiza automaticamente a view com o mesmo nome da action (app/views/categories/index.html.erb).
    @categories = Category.all
  end

  # GET /categories/1 => id
  # Mostra um. Fica vazio porque o before_action já buscou @category.
  def show
  end

  # GET /categories/new
  # Category.new cria um objeto em memória, ainda não salvo no banco.
  # A view usa esse objeto para montar o formulário.
  def new
    @category = Category.new
  end

  # POST /categories
  def create
    @category = Category.new(category_params)
    # save devolve true (salvou) ou false (validação falhou).
    if @category.save
      redirect_to @category, notice: "Categoria cadastrada"
    else
      # ERRO: :unprocessable_entity foi renomeado no Rack 3 e gera aviso de "deprecated" no log.
      # CORREÇÃO: usar :unprocessable_content (é o mesmo código HTTP 422).
      # O 422 é obrigatório: sem ele o Turbo não mostra os erros do formulário.
      render :new, status: :unprocessable_content
    end
  end

  # GET /categories/1/edit
  def edit
  end

  # PATCH /categories/1
  def update
    if @category.update(category_params)
      redirect_to @category, notice: "Categoria atualizada"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /categories/1
  def destroy
    # ERRO: não tratava a falha. Categoria com produtos não pode ser apagada (ver has_many no model).
    # CORREÇÃO: destroy devolve false quando não consegue, então mostramos o motivo com alert.
    if @category.destroy
      redirect_to categories_path, notice: "Categoria removida.", status: :see_other
    else
      redirect_to categories_path, alert: @category.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # ERRO: o comentário dizia "Privado para não ser mostrado na view".
  # CORREÇÃO: private significa que esses métodos NÃO viram actions (nenhuma URL chama eles).
  # Só servem de ajuda aqui dentro do controller.
  private

  def set_category
    @category = Category.find(params[:id])
  end

  # Strong parameters: libera só esses campos. Qualquer outro é ignorado. Isso impede que alguém envie campos que você não queria permitir.
  def category_params
    params.require(:category).permit(:name)
  end
end
