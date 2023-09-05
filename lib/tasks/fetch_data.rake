# frozen_string_literal: true

require "httparty"
require "active_support/core_ext/hash/indifferent_access"

def okx_api_host = "https://www.okx.com/priapi/v5/"

def instruments_endpoint = "#{okx_api_host}public/simpleProduct"

def traders_endpoint = "#{okx_api_host}ecotrade/public/follow-rank"

def historical_positions_endpoint = "#{okx_api_host}ecotrade/public/position-history"

def current_timestamp = (Time.now.to_f * 1000).to_i

def total_pages
  @total_pages = @traders_response_body ? @traders_response_body[:data].first[:pages].to_i : 2
end

def traders
  @traders_response_body[:data].first[:ranks].map do |trader|
    {
      unique_name: trader[:uniqueName],
      name: trader[:nickName],
      aum: trader[:aum].to_f,
      pnl: trader[:pnl].to_f,
      win_ratio: trader[:winRatio].to_f,
      yield_ratio: trader[:yieldRatio].to_f
    }
  end
end

# def fill_trader_instruments(trader)
#   all_trader_instruments.concat(trader_instruments(trader))
# end

# def trader_instruments(trader)
#   @trader_instruments ||= trader[:instruments].map do |instrument|
#     {
#       trader_id: trader[:uniqueName],
#       instrument_id: instrument[:instId]
#     }
#   end
# end

# def all_trader_instruments
#   @all_trader_instruments ||= []
# end

def all_traders
  @all_traders ||= []
end

namespace :scrape do
  desc "scrape instruments data from okx and save to db"
  task instruments: :environment do
    params = {
      t: current_timestamp,
      instType: "SWAP"
    }

    response = HTTParty.get(instruments_endpoint, query: params)
    body = JSON.parse(response).with_indifferent_access

    instruments = body[:data].map do |instrument|
      {
        name: instrument[:coinName],
        contract_multiplier: instrument[:ctMult].to_f,
        contract_type: instrument[:ctType],
        contract_value: instrument[:ctVal].to_f,
        contract_currency: instrument[:ctValCcy],
        instrument_id: instrument[:instId],
        settle_currency: instrument[:settleCcy]
      }
    end

    Instrument.upsert_all(instruments, unique_by: :instrument_id)
  end
end

namespace :scrape do
  task lead_traders: :environment do
    scrapping = true
    page = 1
    while scrapping
      break if page >= total_pages

      params = {
        t: current_timestamp,
        size: 20,
        sort: :desc,
        start: page
      }

      response = HTTParty.get(traders_endpoint, query: params)
      @traders_response_body = response.with_indifferent_access

      all_traders.concat(traders)

      page += 1
    end

    pp "total traders fetched #{all_traders.count}"
    pp "total new traders: #{all_traders.count - Trader.count}"
    # require 'pry'
    # binding.pry
    Trader.upsert_all(all_traders, unique_by: :unique_name)
  end
end
namespace :scrape do
  task historical_positions: :environment do
    # unique_names = Trader.where(last_scrapped_at: nil).pluck(:unique_name) - HistoricalPosition.distinct.pluck(:trader_id)

    unique_names = Trader.where("aum > 0")
      .and(Trader.where.not(last_scrapped_at: Time.zone.today.all_day))
      .pluck(:unique_name)

    # unique_names = Trader.where("aum > 0")
    #   .pluck(:unique_name)

    pp "scrapping #{unique_names.count} traders"
    unique_names.each do |trader_id|
      trader = Trader.find(trader_id)
      pp "current trader name: #{trader.name}"
      trader.update_historical_positions
      trader.last_scrapped_at = Time.zone.now
      trader.save!
    end
  end
end

"
t = traders
hp = a trader's historical_positions

then

order hp by opened at -> ordered_open_hp
order hp by closed at -> ordered_close_hp


res = Hash.new

for(int i = 0, i < ordered_open_hp.length; i++)
{
  res[]
}

"
