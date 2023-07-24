class TraderInstrument < ApplicationRecord
  self.table_name = :traders_instruments

  # Associations
  belongs_to :trader
  belongs_to :instrument

  # Validations
  validates :type, presence: true
end
