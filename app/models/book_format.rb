class BookFormat < ActiveRecord::Base
  belongs_to :book
  belongs_to :book_format_type

  validates :book_format_type, :book, presence: true
  validates :book_id, uniqueness: { scope: :book_format_type_id }
end
