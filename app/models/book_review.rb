class BookReview < ActiveRecord::Base
  belongs_to :book

  validates :book, :rating, presence: true
  validates :rating, inclusion: { in: (1..5) }
end
