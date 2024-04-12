class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.string :origin_country
      t.timestamps
    end
  end
end
