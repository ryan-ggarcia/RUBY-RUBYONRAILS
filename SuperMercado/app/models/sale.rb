# Sale = uma venda feita em um caixa.
class Sale < ApplicationRecord
  # Lista de status possíveis. Usada na validação e no select do formulário.
  STATUSES = %w[open completed canceled]

  belongs_to :checkout
  # dependent: :destroy -> apagar a venda apaga também os itens dela.
  has_many :item_sales, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
end
