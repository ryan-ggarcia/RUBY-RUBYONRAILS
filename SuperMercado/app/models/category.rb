# O model representa uma tabela do banco (categories) e guarda as regras dos dados.
class Category < ApplicationRecord
  # Uma categoria tem vários produtos (o outro lado do belongs_to :category em Product).
  # ERRO: faltava essa linha. Apagar uma categoria com produtos dava erro 500 (o banco bloqueia pela foreign_key).
  # CORREÇÃO: restrict_with_error não deixa apagar e guarda o motivo em errors.
  has_many :products, dependent: :restrict_with_error

  # ERRO: a mensagem era "Erro..Nome não informado." e na tela aparecia "Name Erro..Nome não informado.",
  # porque full_messages sempre coloca o nome do campo antes da mensagem.
  # CORREÇÃO: escrever só o final da frase.
  validates :name, presence: { message: "não pode ficar em branco" }
end
# Outro metodos utilizados
# validates :nome, presence: true                       obrigatório
# validates :nome, length: { minimum: 3, maximum: 50 }  tamanho
# validates :email, uniqueness: true                    não pode repetir
# validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }  formato
# validates :idade, numericality: { only_integer: true, greater_than_or_equal_to: 18 }
# validates :status, inclusion: { in: %w[ativo inativo] }  só valores da lista
