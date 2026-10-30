# ItemSale = um item dentro de uma venda (ex.: 2x Arroz).
class ItemSale < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
end
