require 'timeout'

class CompaniesService
  def find_company_by_ticker(ticker)
    Company.find_by('LOWER(ticker) = LOWER(?)', ticker)
  end

  def get_or_create_company_by_ticker(ticker)
    begin
      company = find_company_by_ticker(ticker)
      puts "ticker for company: "
      puts company&.ticker
      if !company
        # ActiveRecord::Base.connection.execute("LOCK TABLE companies IN SHARE ROW EXCLUSIVE MODE")
        company = Timeout.timeout(2) do
          Company.create!(ticker: ticker)
        end
        puts "new company created"
      end
      return company
    rescue ActiveRecord::RecordInvalid => e
      if e.to_s == "Validation failed: Ticker has already been taken"
        puts "Validation failed: Ticker has already been taken"
        return get_or_create_company_by_ticker(ticker)
      else
        raise e
      end
    end
  end

  def create_company(company_params)
      Company.create!(company_params)
  end
end



