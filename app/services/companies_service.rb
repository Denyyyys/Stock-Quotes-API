class CompaniesService
  def find_company_by_ticker(ticker)
    Company.find_by(ticker: ticker)
  end

  def get_or_create_company_by_ticker(ticker)
    begin
      company = find_company_by_ticker(ticker)
      if !company
        company = Company.create!(ticker: ticker)
      end
      return company
    rescue ActiveRecord::RecordInvalid => e
      if e.to_s == "Validation failed: Ticker has already been taken"
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


