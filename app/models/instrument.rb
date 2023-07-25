class Instrument < ApplicationRecord
  self.table_name = :instruments
  self.primary_key = :instrument_id

  # Associations
  has_many :trader_instruments, dependent: :destroy_async
  has_many :traders, through: :trader_instruments, dependent: :destroy_async

  # not required
  has_many :historical_positions, dependent: :destroy_async

  # Validations
  validates :contract_type, :name, :instrument_id, presence: true
end
