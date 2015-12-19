class CreateBookFormats < ActiveRecord::Migration
  def change
    create_table :book_formats do |t|
      t.references :book, index: true, foreign_key: true
      t.references :book_format_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
