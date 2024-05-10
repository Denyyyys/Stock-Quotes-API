class ChangeCompanyNameToNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :companies, :name, true
  end
end
