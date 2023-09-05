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

  def okx_url
    "https://www.okx.com/copy-trading/account/#{unique_name}"
  end

  def self.isolated
    # require "pry"
    # binding.pry

    
    # traders = Trader.arel_table
    # historical_positions = HistoricalPosition.arel_table
    # isolated_positions = Arel::Nodes::As.new(historical_positions, historical_positions.where(historical_positions[:margin_mode].eq("isolated")))

    # traders
    #   .join(isolated_positions).on(traders[:unique_name].eq(isolated_positions[:trader_id]))
    #   .project(traders[:unique_name], traders[:name])

    traders = find_by_sql(
      "with isolated_positions as (
    	select * from historical_positions hp
    	where hp.margin_mode = 'isolated' and (
        hp.open_time between now() - interval '2 week' AND now()
      )
    )
    select distinct t.unique_name from traders t
    inner join isolated_positions ip on ip.trader_id = t.unique_name
    group by t.unique_name"
    )

    where(unique_name: traders.map(&:unique_name))
  end

  def analyse_time
    @times_not_in_trade = []
    minimum_open_time = historical_positions.minimum(:open_time)
    time_now = DateTime.now.new_offset(0)
    # maximum_close_time = historical_positions.minimum(:close_time)

    historical_trade_timeslots = all_trade_times.pluck(:time_range)

    historical_trade_timeslots.each do |trade|
      if trade.begin > minimum_open_time
        @times_not_in_trade << (minimum_open_time..trade.begin - 1)
      end
      minimum_open_time = [minimum_open_time, trade.end].max
    end

    if minimum_open_time <= time_now.to_i
      @times_not_in_trade << (minimum_open_time..time_now.to_i)
    end

    # time_inactive = @times_not_in_trade.sum { |time| (time.end.to_i - time.begin.to_i) }
    # total_time = time_now.to_i - minimum_open_time.to_i
  end

  # def max_simultaneous_trades
  #   historical_trade_timeslots = all_trade_times.pluck(:time_range)

  #   sorted_timeslots = historical_trade_timeslots.sort_by { |range| range.begin }

  #   max_simultaneous = 0
  #   current_simultaneous = 0
  #   end_time = -1

  #   sorted_timeslots.each do |range|
  #     if range.begin <= end_time
  #       current_simultaneous += 1
  #     else
  #       current_simultaneous = 1
  #     end

  #     max_simultaneous = [max_simultaneous, current_simultaneous].max
  #     end_time = [end_time, range.end].max
  #   end

  #   max_simultaneous
  # end

  def max_concurrent_trades
    consolidated_trades = {}
    all_trade_times.each do |position|
      consolidated_trades.keys.select do |timeslot|
        timeslot.cover?(position.begin)
      end
    end

    # {
    #   begin..end: [unique_id, unique_id], # trade
    #   begin..end: [] # no trade
    # }
  end

  def test
    require "pry"
    binding.pry
  end

  def all_trade_times
    @all_trade_times ||= historical_positions.order(:open_time).pluck(:unique_id, :open_time, :close_time).map do |position|
      {unique_id: position.first, time_range: position.second..position.third}
    end
  end

  def analyse_historical_positions
    # Rails.logger.debug all_trade_times
    # Rails.logger.debug times_not_in_trade
    # require 'pry'
    # binding.pry

    puts "#{name} Max consecutive trades: #{max_simultaneous_trades}"
  end

  def update_historical_positions
    scrapping = true
    @trader_positions = nil
    params = {
      t: current_timestamp,
      size: 100,
      uniqueName: unique_name
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

    Rails.logger.debug { "#{name} => #{all_positions.count}" }

    historical_positions.upsert_all(all_positions, unique_by: :unique_id) if all_positions.count.positive?
  end

  private

  def current_positions
    @current_positions = @trader_positions[:data].map do |position|
      {
        unique_id: position[:id],
        trader_id: unique_name,
        instrument_id: position[:instId],
        leverage: position[:lever].to_i,
        margin: position[:margin].to_f,
        pnl: position[:pnl].to_f,
        margin_mode: position[:mgnMode],
        open_avg_price: position[:openAvgPx].to_f,
        close_avg_price: position[:closeAvgPx].to_f,
        side: position[:posSide],
        open_time: Time.strptime(position[:openTime].to_s, "%Q"),
        close_time: Time.strptime(position[:uTime].to_s, "%Q")
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

# select * from historical_positions hp where t.unique_name IN (select distinct (trader_id) from historical_positions hp where hp.margin_mode = "isolated") AND hp.margin_mode = "cross" AND hp.trader_id = (SELECT unique_name FROM 'traders' t where t.aum != 0 AND t.aum >= 1000 AND t.aum <= 200000 AND t.win_ratio >= .85) limit 0,30

# select distinct (trader_id) from historical_positions hp where hp.margin_mode = "isolated" limit 10

# select * from traders t where t.unique_name IN (select distinct (trader_id) from historical_positions hp where hp.margin_mode = "isolated")
# AND  t.aum != 0 AND t.aum >= 100000 AND t.win_ratio >= .85 limit 0,30

# select * from traders t inner join
