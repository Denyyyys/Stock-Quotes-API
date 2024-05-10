require 'rails_helper'

RSpec.describe 'Race Conditions', type: :request, disable_transactions: true do
  it "test race condition for creating new stock quote with non-existent company" do
    expect(ActiveRecord::Base.connection.pool.size).to eq(5)
    wait_for_it  = true
    concurrency_level = 4

    threads = concurrency_level.times.map do |i|
      Thread.new do
        true while wait_for_it
        post '/api/v1/stock_quotes', params: { ticker: 'GTLB', price: 1}
      end
    end
    wait_for_it = false
    threads.each(&:join)
    expect(StockQuote.count).to eq(4)
    expect(Company.count).to eq(1)
  end
end
