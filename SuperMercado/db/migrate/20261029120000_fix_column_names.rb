# ERRO (nas migrations antigas): nomes de coluna com erro de digitação e fora do padrão.
#   inventary   -> inventory     (inglês correto)
#   unit_prince -> unit_price    ("prince" é príncipe, não preço)
#   Completed_in -> completed_at (coluna nunca começa com maiúscula; datas terminam em _at por convenção)
# CORREÇÃO: nunca edite uma migration que já rodou. Crie uma NOVA migration que corrige,
# assim o banco de todo mundo da turma é atualizado com `bin/rails db:migrate`.
class FixColumnNames < ActiveRecord::Migration[8.1]
  def change
    rename_column :products, :inventary, :inventory
    rename_column :item_sales, :unit_prince, :unit_price
    rename_column :sales, :Completed_in, :completed_at
  end
end
