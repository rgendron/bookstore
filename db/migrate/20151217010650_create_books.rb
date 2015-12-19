class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.references :publisher, index: true, foreign_key: true, null: false
      t.references :author, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
