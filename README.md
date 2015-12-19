# Zee Bookstore

Author:: Ryan Gendron (mailto: rfgendron at g mail dot com)

This is the backend for Zee Bookstore!

## Installation

    $ git clone https://github.com/rgendron/bookstore.git
    $ cd bookstore
    $ bundle install
    $ bundle exec rake db:migrate
    $ bundle exec rspec spec/


## Usage

### Book Search

* All searches are case insensitive.
* Books returned are ordered by average rating, with highest rated first.

To find all books with "Smith" in the title, or with the last name equaling "Smith" or with the publisher name equaling "Smith":

```
books = Book.search "Smith"
```

To search book titles only for "Smith":

```
books = Book.search "Smith", title_only: true
```

To search for books by Book Format Type, you need the id of the Book Format Type:

```
books = Book.search "Smith", book_format_type_id: 4
```

To search only for books with physical Book Format Types:

```
books = Book.search "Smith", book_format_physical: true
```

To search only for books with electronic Book Format Types:

```
books = Book.search "Smith", book_format_physical: false
```

You can mix options:

```
books = Book.search("Smith",
                     title_only: true, 
                     book_format_type_id: 4
                     book_format_physical: true)
                     
                     
```

Happy Searching!