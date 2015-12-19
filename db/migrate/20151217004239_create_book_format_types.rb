class CreateBookFormatTypes < ActiveRecord::Migration
  def change
    create_table :book_format_types do |t|
      t.string :name, null: false
      t.boolean :physical, null: false

      t.timestamps null: false
    end
  end
end
