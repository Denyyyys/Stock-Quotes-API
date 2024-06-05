class CompaniesService
  def find_company_by_ticker(ticker)
    Company.find_by(ticker: ticker)
  end

  def get_or_create_company_by_ticker(ticker)
    company = find_company_by_ticker(ticker)
    if !company
      company = Company.create!(ticker: ticker)
    end
    company
  end

  def create_company(company_params)
    Company.create!(company_params)
  end
end