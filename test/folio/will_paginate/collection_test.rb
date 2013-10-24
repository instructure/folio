require 'minitest/autorun'
require 'folio/will_paginate/collection'

describe WillPaginate::Collection do
  describe "create" do
    it "should create an ordinal page" do
      page = WillPaginate::Collection.create(1)
      page.is_a?(Folio::Ordinal::Page).must_equal true
    end

    it "should set current_page on the created page" do
      page = WillPaginate::Collection.create(4)
      page.current_page.must_equal 4
    end

    it "should set per_page on the created page if given" do
      page = WillPaginate::Collection.create(4, 10)
      page.per_page.must_equal 10
    end

    it "should set total_entries on the created page if given" do
      page = WillPaginate::Collection.create(4, 10, 50)
      page.total_entries.must_equal 50
    end

    it "should yield the page to block if given" do
      page = WillPaginate::Collection.create(1) { |p| p.replace [1, 2, 3] }
      page.must_equal [1, 2, 3]
    end

    it "created page should have offset method like WillPaginate::Collection" do
      page = WillPaginate::Collection.create(4, 10)
      page.offset.must_equal 30
    end

    it "created should set total_entries on replace like WillPaginate::Collection" do
      page = WillPaginate::Collection.create(4, 10)
      page.total_entries.must_be_nil
      page.replace [1, 2, 3]
      page.total_entries.must_equal 33
    end
  end
end
