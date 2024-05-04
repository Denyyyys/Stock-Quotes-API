# frozen_string_literal: true

# Migration to create the companies table in the database
class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.string :origin_country
      t.timestamps
    end

    add_index :companies, :ticker, unique: true
  end
end
