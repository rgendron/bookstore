class Book < ActiveRecord::Base

  DEFAULT_SEARCH_OPTIONS = {
    title_only: false,
    book_format_type_id: nil,
    book_format_physical: nil
  }

  belongs_to :publisher
  belongs_to :author
  has_many :reviews, class_name: "BookReview", dependent: :destroy
  has_many :book_formats, dependent: :destroy
  has_many :book_format_types, through: :book_formats

  scope :physical, -> { joins(:book_format_types).merge(BookFormatType.physical).uniq }
  scope :electronic , -> { joins(:book_format_types).merge(BookFormatType.electronic).uniq }
  # Ideally, we would create an average_rating column.
  scope :highest_rated_order, -> {
    joins("left outer join book_reviews on book_reviews.book_id = books.id").
    group('books.id').order('avg(rating) desc')
  }


  validates :publisher, :author, :title, presence: true

  def self.search(query, options = {})
    options = options.reverse_merge(default_search_options)

    books = search_all(query, options[:title_only])
    if (type_id = options[:book_format_type_id])
      books = books.joins(:book_formats).where("book_formats.book_format_type_id": type_id)
    end

    unless options[:book_format_physical].nil?
      books = options[:book_format_physical] ? books.physical : books.electronic
    end
    books.highest_rated_order.uniq
  end

  def self.search_all(query, title_only = false)
    query = query.downcase
    joins = []
    or_conditions = ["lower(books.title) like :like_query"]

    unless title_only
      or_conditions << "lower(publishers.name) = :query"
      or_conditions << "lower(authors.last_name) = :query"
      joins += [:publisher, :author]
    end
    Book.joins(joins).where(or_conditions.join( ' OR '), query: query, like_query: "%#{query}%")
  end


  def author_name
    "#{author.first_name} #{author.last_name}"
  end

  def average_rating
    reviews.exists? ? reviews.average(:rating).round(1) : nil
  end

  def format_types
    formats.map {|format| format}
  end

  def to_s
    title
  end

  private

  def self.default_search_options
    { title_only: false, book_format_type_id: nil, book_format_physical: nil }
  end

end
