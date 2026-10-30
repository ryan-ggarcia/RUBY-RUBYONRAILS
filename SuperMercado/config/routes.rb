Rails.application.routes.draw do
  # root = a página que abre no endereço "/" (http://localhost:3000). Aqui: HomeController, action index.
  root "home#index"

  # resources cria as 7 rotas do CRUD para cada model (tabela abaixo).
  resources :categories
  resources :products
  resources :checkouts
  resources :sales
  resources :item_sales
end
# equivale a (exemplo com categories; veja todas com: bin/rails routes)
# Verbo	URL	Action	Função
# GET	/categories	index	Listar
# GET	/categories/:id	show	Ver um
# GET	/categories/new	new	Formulário de criação
# POST	/categories	create	Salvar novo
# GET	/categories/:id/edit	edit	Formulário de edição
# PATCH	/categories/:id	update	Salvar edição
# DELETE	/categories/:id	destroy	Excluir
