class BookFormatType < ActiveRecord::Base
  has_many :book_formats, dependent: :destroy
  has_many :formats, through: :book_formats, source: :book

  validates :name, presence: true, uniqueness: true
  validates :physical, inclusion: { in: [true, false] }

  scope :physical, -> { where(physical: true) }
  scope :electronic, -> { where(physical: false) }

  def electronic?
    physical? == false
  end

  def to_s
    name
  end

end
