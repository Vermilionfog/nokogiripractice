class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :text
      t.date :search_time
      t.string :name

      t.timestamps null: false
    end
  end
end
