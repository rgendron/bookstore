require 'rails_helper'

RSpec.describe Book, type: :model do
  subject(:book) { create :book }

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
    describe "book format scopes" do
      let!(:both) { create_list(:book, 1,:with_physical_formats, :with_electronic_formats) }
      let!(:physical) { create_list(:book, 2,:with_physical_formats) }
      let!(:electronic) { create_list(:book, 3,:with_electronic_formats) }

      describe ".physical" do
        it 'returns only books with physical format types' do
          expect(Book.physical.all?{ |b| b.book_format_types.any?(&:physical?) }).to be true
        end

        it 'returns all physical format books' do
          expect(Book.physical.count).to eq 3
        end
      end

      describe ".electronic" do
        it 'returns only books with physical format types' do
          expect(Book.electronic.all? { |b| b.book_format_types.any?(&:electronic?) }).to be true
        end

        it 'returns all electronic format books' do
          expect(Book.electronic.count).to eq 4
        end
      end
    end

    describe ".highest_rated_order" do
      let!(:highly_rated) { create :book, :with_reviews, ratings: [5,4], title: "High" }
      let!(:medium_rated) { create :book, :with_reviews, ratings: [3,3], title: "Medium" }
      let!(:low_rated) { create :book, :with_reviews, ratings: [1,2], title: "Low" }

      it 'returns books based on highest average rating' do
        ordered_book_titles = Book.highest_rated_order.uniq.map(&:title)
        expect(ordered_book_titles).to eq ["High","Medium","Low"]
      end

      it 'returns all books' do
        expect(Book.highest_rated_order.length).to eq Book.count
      end
    end
  end

  describe ".search" do
    it "is be insensitive to case" do
      create :book, title: "MIXED case"
      expect(Book.search("mixed case")).to eq Book.search('MIXED CASE')
    end

    it 'returns books based on highest average rating' do
      create :book, :with_reviews, ratings: [5,4], title: "High Rated"
      create :book, :with_reviews, ratings: [1,2], title: "Low Rated"
      search_result_titles = Book.search('Rated').map(&:title)
      expect(search_result_titles).to eq ["High Rated", "Low Rated"]
    end

    context "when book_format_physical option is set" do
      let!(:both) { create_list(:book, 1,:with_physical_formats, :with_electronic_formats) }
      let!(:physical) { create_list(:book, 2,:with_physical_formats) }
      let!(:electronic) { create_list(:book, 3,:with_electronic_formats) }

      context "when book_format_physical option is set to true" do
        it "returns only books with with physical format type " do
          search_results = Book.search('book',book_format_physical: true)
          expect(search_results.all?{ |b| b.book_format_types.any?(&:physical?) }).to be true
        end
      end

      context "when book_format_physical option is set to false" do
        it "returns only books with electronic format type" do
          search_results = Book.search('book',book_format_physical: false)
          expect(search_results.all?{ |b| b.book_format_types.any?(&:electronic?) }).to be true
        end
      end
    end
    context "when title_only option is set to true" do
      it "returns only books where query is in title" do
        create(:book, title: "Pierre Trudeau: A biography")
        create(:book, author: build(:author, last_name: "Trudeau"))
        search_results = Book.search('Trudeau', title_only: true)
        expect(search_results.all? { |book| book.title.index(/Trudeau/i) }).to be true
      end
    end

    context "when book_format_type_id is set" do
      it "returns only books with specified format id" do
        book = create(:book, :with_physical_formats, title: "Superforecasting")
        create(:book, :with_electronic_formats, title: "Superforecasting")
        id = book.book_format_types.first.id
        search_results = Book.search('Super',  book_format_type_id: id)
        expect(search_results).to eq [book]
      end
    end
  end

  describe ".search_all" do
    context "when title_only is set to true" do
      let!(:bio) { create(:book, title: "Pierre Trudeau: A biography") }
      let!(:trudeau) { create(:book, author: build(:author, last_name: "Trudeau")) }
      let!(:layton) { create(:book, author: build(:author, last_name: "Layton")) }

      it "returns nothing when there is no matching title" do
        expect(Book.search_all('Layton', true)).to eq []
      end

      it "returns all books with the query as a substring of the title" do
        expect(Book.search_all('biography', true)).to eq [bio]
      end
    end

    context "when title_only is set to false" do

      it "returns all books with author last name equal to query" do
      	book = create(:book, author: build(:author, last_name: "Andrews")) 
        expect(Book.search_all('Andrews', false)).to eq [book]
      end

      it "returns all books with publisher name equal to query" do
      	book = create(:book, publisher: build(:publisher, name: "Archie"))
        expect(Book.search_all('Archie', false)).to eq [book]
      end

      it "returns all books with the query as a substring of the title" do
				book = create(:book, title: "Archie Andrews")
        expect(Book.search_all('Archie', false)).to eq [book]
      end
    end
  end

  describe ".self.default_search_options" do
    it 'returns the right defaults' do
      expected = { title_only: false, book_format_type_id: nil, book_format_physical: nil }
      expect(Book.send('default_search_options')).to eq expected
    end
  end

  describe "#to_s" do
      it "returns the right string" do
        expect(book.to_s).to eq book.title
      end
    end

    describe "#author_name" do
      it 'returns #first_name + #last_name' do
        full_name = "#{book.author.first_name} #{book.author.last_name}"
        expect(book.author_name).to eq full_name
      end
    end

    describe "#average_rating" do
      context "when there are no reviews" do
        it "returnss nil" do
          book = create(:book, :with_reviews, ratings: [])
          expect(book.average_rating).to eq nil
        end
      end

      context "with only a single review" do
        it "returns the rating from that review" do
          book = create(:book, :with_reviews, ratings: [3])
          expect(book.average_rating).to eq 3
        end
      end

      context "with multiple reviews" do
        it "returns the average review ratings to one decimal place" do
          book = create(:book, :with_reviews, ratings: [3,4])
          expect(book.average_rating).to eq 3.5
        end
      end
    end
  end
