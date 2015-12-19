class Author < ActiveRecord::Base
  has_many :books, dependent: :destroy
  validates :first_name, :last_name, presence: true

  def to_s
    "#{first_name} #{last_name}"
  end

end
