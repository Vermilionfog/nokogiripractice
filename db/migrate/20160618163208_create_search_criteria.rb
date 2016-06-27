class CreateSearchCriteria < ActiveRecord::Migration
  def change
    create_table :search_criteria do |t|
      t.string :name
      t.string :url
      t.string :xpath
      t.string :css
      t.string :keyword

      t.timestamps null: false
    end
  end
end
