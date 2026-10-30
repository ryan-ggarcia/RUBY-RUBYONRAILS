# Checkout = caixa do supermercado (Caixa 1, Caixa 2...).
class Checkout < ApplicationRecord
  # Caixa que tem vendas não pode ser apagado.
  has_many :sales, dependent: :restrict_with_error

  validates :name, presence: true
end
