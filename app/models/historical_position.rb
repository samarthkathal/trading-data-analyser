class HistoricalPosition < ApplicationRecord
  self.table_name = :historical_positions
  self.primary_key = :id

  # Associations

  # not required
  belongs_to :instrument, dependent: :restrict_with_error
  belongs_to :trader, dependent: :restrict_with_error

  # Validations
  validates :leverage, :margin, :pnl, :margin_mode, :open_avg_price, presence: true
  validates :close_avg_price, :side, :open_time, :close_time, presence: true
end
