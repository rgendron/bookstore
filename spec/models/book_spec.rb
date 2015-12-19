require 'rails_helper'

RSpec.describe Book, type: :model do

  subject(:book) { create :book }
  let(:publishers) { [1,2].map {|n|  create(:publisher, name: "Pub #{n}") } }
  let(:authors) { [1,2].map {|n|  create(:author, first_name: "First #{n}", last_name: "Last #{n}") } }

  let!(:books) { 2.upto(5).map {|n|  create(:book, title: "Book #{n}", publisher: publishers[n % 2], author: authors[n % 2]) } }
  let(:reviews) { [1, 2, 5].map {|rating| FactoryGirl.build(:book_review, rating: rating )} }

  let(:physical_types) { 1.upto(3).map {|n| create(:book_format_type, name: "Physical #{n}", physical: true)} }
  let(:electronic_types) { 1.upto(2).map {|n| create(:book_format_type, name: "Electronic #{n}", physical: false)} }

  describe "associations" do
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:book_formats).dependent(:destroy) }
    it { should have_many(:book_format_types).through(:book_formats) }
    it { should belong_to(:author)}
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:publisher) }
    it { should validate_presence_of(:author) }
  end

  describe "scopes" do
    before(:each) do
      books[0].book_format_types << physical_types[0,1] << electronic_types[1]
      books[1].book_format_types << physical_types[0,2]
      books[2].book_format_types << physical_types[1]
      books[3].book_format_types << electronic_types[0,1]

      books[0].reviews << reviews[0,1]
      books[1].reviews << reviews[2]
    end

    describe ".physical" do
      it 'should return only books with format types' do
        expect(Book.physical.all?{ |b| b.book_format_types.any?(&:physical?) }).to be true
      end

      it 'should return all physical format books' do
        expect(Book.physical.count).to eq 3
      end
    end


    describe ".electronic" do
      it 'should return only books with format types' do
        expect(Book.electronic.all? { |b| b.book_format_types.any?(&:electronic?) }).to be true
      end

      it 'should return all electronic format books' do
        expect(Book.electronic.count).to eq 2
      end
    end

    describe ".highest_rated_order" do
      it 'should return books based on highest average rating' do
        ordered_books = Book.highest_rated_order.uniq
        expect(ordered_books[0..1]).to eq [books[1], books[0]]
      end

      it 'should return all books' do
        expect(Book.highest_rated_order.length).to eq Book.count
      end
    end

  end

  describe ".search" do

    it "should be insensitive to case" do
      expect(Book.search("book")).to eq Book.search('BOOK')
    end

    it 'should return books based on highest average rating' do

      books[0].reviews << reviews[0,1]
      books[1].reviews << reviews[2]
      search_results = Book.search('book')
      expect(search_results[0..1]).to eq [books[1], books[0]]
    end

    context "when book_format_physical option is set to true" do
      it "should only return books with with physical format type " do
        search_results = Book.search('book',book_format_physical: true)
        expect(search_results.all?{ |b| b.book_format_types.any?(&:physical?) }).to be true
      end
    end

    context "when book_format_physical option is set to false" do
      it "should only return books with electronic format type" do
        search_results = Book.search('book',book_format_physical: false)
        expect(search_results.all?{ |b| b.book_format_types.any?(&:electronic?) }).to be true
      end
    end

    context "when title_only option is set to true" do
      it "should return only books where query is in title" do
        search_results = Book.search('pub 2', title_only: true)
        expect(search_results.all? { |book| book.title.index('pub2') }).to be true
      end
    end

    context "when book_format_type_id is set" do
      it "should return only books with that format id" do
        books[2].book_format_types << physical_types[1]
        books[3].book_format_types << electronic_types[0,1]
        id = physical_types[1].id
        search_results = Book.search('book',  book_format_type_id: id)
        expect(search_results.all.all?{ |b| b.book_formats.pluck(:book_format_type_id).include?(id)}).to be true
      end
    end

  end

  describe ".search_all" do
    context "when title_only is set to true" do
      it "should return nothing when there is no matching title" do
        expect(Book.search_all('Pub 1', true)).to eq []
      end

      it "should return all matching titles" do
        create(:book, publisher: publishers.first, title: "Not in Search")
        expect(Book.search_all('Book', true).count).to eq 4
      end
    end

    context "when title_only is set to false " do
      before(:each) do
        create(:book, publisher: publishers[0], title: "Has publisher in title: #{publishers.second.name}")
        create(:book, publisher: publishers[1], title: "Has author last name in title: #{authors.second.last_name}")
      end

      it "should return all matching books" do
        expect(Book.search_all('Pub 2', false).count).to eq 4
      end

      it "should return all books with author last name equal to query" do
        expect(Book.search_all('Last 2', false).count).to eq 3
      end

      it "should return all books with publisher name equal to query" do
        expect(Book.search_all('Pub 2', false).count).to eq 4
      end
    end
  end

  describe ".self.default_search_options" do
    it 'should return the right defaults' do
      expected = { title_only: false, book_format_type_id: nil, book_format_physical: nil }
      expect(Book.send('default_search_options')).to eq expected
    end
  end

  describe "#to_s" do
    it "should be the right string" do
      expect(book.to_s).to eq book.title
    end
  end

  describe "#author_name" do
    it 'should return #first_name + #last_name' do
      full_name = "#{book.author.first_name} #{book.author.last_name}"
      expect(book.author_name).to eq full_name
    end
  end

  describe "#average_rating" do
    context "when there are no reviews" do
      it "should returns nil" do
        book = create(:book, reviews: [])
        expect(book.average_rating).to eq nil
      end
    end

    context "with only a single review" do
      it "should return the rating from that review" do
        review = FactoryGirl.build(:book_review, rating: 3)
        book = create(:book, reviews: [review])
        expect(book.average_rating).to eq 3
      end
    end

    context "with multiple reviews" do
      it "should return the average review ratings to one decimal place" do
        reviews = [1, 2, 5].map {|rating| FactoryGirl.build(:book_review, rating: rating )}
        book.reviews = reviews
        expect(book.average_rating).to eq 2.7
      end
    end
  end
end
