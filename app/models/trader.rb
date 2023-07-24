class Trader < ApplicationRecord
  self.table_name = :traders
  self.primary_key = :unique_name

  # Associations
  has_many :trader_instruments, dependent: :restrict_with_error
  has_many :instruments, through: :trader_instruments, dependent: :restrict_with_error

  # not required
  has_many :historical_positions, dependent: :restrict_with_error

  # Validations
  validates :name, :unique_name, presence: true
end
