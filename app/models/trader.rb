class Trader < ApplicationRecord
  self.table_name = :traders
  self.primary_key = :unique_name

  # Associations
  has_many :trader_instruments, dependent: :destroy_async
  has_many :instruments, through: :trader_instruments, dependent: :destroy_async

  # not required
  has_many :historical_positions, dependent: :destroy_async

  # Validations
  validates :unique_name, presence: true

  def update_historical_positions
    scrapping = true
    @trader_positions = nil
    params = {
      t: current_timestamp,
      size: 50,
      uniqueName: unique_name,
    }

    while scrapping
      if all_positions.count.positive?
        params[:after] = all_positions.last[:unique_id]
      end

      response = HTTParty.get(historical_positions_endpoint, query: params)
      @trader_positions = response.with_indifferent_access

      scrapping = false if @trader_positions[:data].count.zero?

      all_positions.concat(current_positions)
    end

    historical_positions.upsert_all(all_positions, unique_by: :unique_id) if all_positions.count.positive?
  end

  private

  def current_positions
    @current_positions = @trader_positions[:data].map do |position|
      {
        unique_id: position[:id],
        trader_id: unique_name,
        instrument_id: position[:instId],
        leverage: position[:leverage].to_i,
        margin: position[:margin].to_f,
        pnl: position[:pnl].to_f,
        margin_mode: position[:mgnMode],
        open_avg_price: position[:openAvgPx].to_f,
        close_avg_price: position[:closeAvgPx].to_f,
        side: position[:posSide],
        open_time: Time.strptime(position[:openTime].to_s, "%Q"),
        close_time: Time.strptime(position[:uTime].to_s, "%Q"),
      }
    end
  end

  def all_positions
    @all_positions ||= []
  end

  def okx_api_host = "https://www.okx.com/priapi/v5/"

  def historical_positions_endpoint = "#{okx_api_host}ecotrade/public/position-history"

  def current_timestamp = (Time.now.to_f * 1000).to_i
end
