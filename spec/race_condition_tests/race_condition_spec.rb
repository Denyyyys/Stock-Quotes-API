require 'rails_helper'
RSpec.describe CompaniesService, type: :service do
  describe 'race condition when creating companies' do
    let!(:ticker) { 'AAPL' }
    let(:ticker_params) { { ticker: ticker, price: 10 } }
    let(:company) { FactoryBot.create(:company, ticker: ticker) }
    subject(:service) { described_class.new() }

    it 'S1 create two stock quotes with the same ticker' do
      # allow_any_instance_of(CompaniesService).to receive(:find_company_by_ticker)
      #                                              .with(ticker).and_return(nil,  company)
      # post :create, params: ticker_params
      #
      # expect(response).to have_http_status(:created)
      # expect(Company.where(ticker: ticker).count).to eq(1)
      mutex = Mutex.new
      resource = ConditionVariable.new
      a = Thread.new {
        mutex.synchronize {
          puts 'a1'
          ActiveRecord::Base.transaction(isolation: :serializable) do
            puts 'a2'
            resource.wait(mutex)
            puts 'a3'
            a1 = service.get_or_create_company_by_ticker(ticker)
            puts a1
            puts 'a4'
          end
        }
      }

      b = Thread.new {
        sleep(1) # na wszelki przypadek, żeby upewnić się, że b zaczął swoje działanie po a
        mutex.synchronize {
          puts 'b1'
          ActiveRecord::Base.transaction(isolation: :serializable) do
            b1 = service.get_or_create_company_by_ticker(ticker)
            puts b1
          end
          puts 'b2'
          resource.signal
          puts 'b3'
        }
      }

      a.join()
      b.join()

      expect(Company.count).to eq(1)
    end























    it 'S2' do
      mutex = Mutex.new
      start_signal2 = ConditionVariable.new
      start_flag2 = false
      start_signal3 = ConditionVariable.new
      start_flag3 = false
      start_signal4 = ConditionVariable.new
      start_flag4 = false
      a = Thread.new {
        max_attempts = 3
        attempts = 0
        mutex.synchronize {
          puts 'a1'
          begin
            attempts += 1
            ActiveRecord::Base.transaction(isolation: :read_committed) do
              puts 'a2'
              until start_flag2
                start_signal2.wait(mutex)
              end
              puts 'a4'
              puts Company.first()&.ticker
              company1 = service.get_or_create_company_by_ticker(ticker)
              puts "company1"
              puts company1
              puts 'a5'
              until start_flag4
                start_signal4.wait(mutex)
              end
            end
          rescue Timeout::Error
            puts "oops, timeout1"
            start_flag3 = true
            start_signal3.signal
            until start_flag4
              start_signal4.wait(mutex)
            end
            retry if attempts < max_attempts
          end
          start_flag3 = true
          start_signal3.signal
        }
      }

      b = Thread.new {
        sleep(1) # na wszelki przypadek, żeby upewnić się, że b zaczął swoje działanie po a
        max_attempts = 3
        attempts = 0
        mutex.synchronize {
          puts 'b1'
          begin
            ActiveRecord::Base.transaction(isolation: :read_committed) do
              puts 'b2'
              company2 = service.get_or_create_company_by_ticker(ticker)
              puts "company2"
              puts company2
              puts Company.first()&.ticker
              puts 'b3'
              start_flag2 = true
              start_signal2.signal
              puts 'b4'
              sleep(1)
              puts "start_flag3 " + start_flag3.to_s
              until start_flag3
                start_signal3.wait(mutex)
              end
            end
            puts 'b5'
            start_flag4 = true
            start_signal4.signal
            puts 'b6'
          rescue Timeout::Error
            puts "oops, timeout2"
            retry if attempts < max_attempts
          end
        }
      }
      a.join()
      b.join()
      expect(Company.count).to eq(1)
    end
  end
end
