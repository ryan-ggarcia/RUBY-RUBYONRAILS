class Product < ApplicationRecord
  # belongs_to: cada produto pertence a UMA categoria (coluna category_id). É obrigatório.
  belongs_to :category
  # Produto que já foi vendido não pode ser apagado.
  has_many :item_sales, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :inventory, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
