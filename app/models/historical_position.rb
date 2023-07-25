class HistoricalPosition < ApplicationRecord
  self.table_name = :historical_positions
  self.primary_key = :id

  # Associations

  # not required
  belongs_to :instrument, dependent: :destroy_async
  belongs_to :trader, dependent: :destroy_async

  # Validations
  validates :leverage, :margin, :pnl, :margin_mode, :open_avg_price, presence: true
  validates :close_avg_price, :side, :open_time, :close_time, presence: true
end
