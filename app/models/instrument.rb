class Instrument < ApplicationRecord
  self.table_name = :instruments
  self.primary_key = :inst_id

  # Associations
  has_many :trader_instruments, dependent: :restrict_with_error
  has_many :traders, through: :trader_instruments, dependent: :restrict_with_error

  # not required
  has_many :historical_positions, dependent: :restrict_with_error

  # Validations
  validates :type, :name, :inst_id, presence: true
end
