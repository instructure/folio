require 'minitest/autorun'
require 'folio/will_paginate/active_record'
require_relative '../../setup/active_record'

describe ActiveRecord do
  TestSetup::ActiveRecord.migrate do |m|
    m.create_table(:items) do |t|
      t.boolean :filter
    end

    m.create_table(:related_things) do |t|
      t.integer :item_id
    end
  end

  class Item < ::ActiveRecord::Base
    has_many :related_things
  end

  class RelatedThing < ::ActiveRecord::Base; end

  before do
    RelatedThing.delete_all
    Item.delete_all
    24.times{ |i| Item.create(filter: (i % 2).zero?) }
  end

  describe "per_page" do
    it "should default to Folio.per_page" do
      was = Folio.per_page
      Folio.per_page = 10
      ActiveRecord::Base.per_page.must_equal 10
      Folio.per_page = was
    end
  end

  describe "paginate" do
    it "should return an ordinal folio page" do
      page = Item.paginate
      page.is_a?(Folio::Ordinal::Page).must_equal true
    end

    it "should return an instantiated page" do
      page = Item.paginate
      page.is_a?(Array).must_equal true
    end

    it "should respect per_page" do
      page = Item.paginate(per_page: 10)
      page.per_page.must_equal 10
    end

    it "should default per_page to model's per_page" do
      was = Item.per_page
      Item.per_page = 10
      page = Item.paginate
      page.per_page.must_equal 10
      Item.per_page = was
    end

    it "should set offset from page and per_page" do
      page = Item.paginate(page: 3, per_page: 10)
      page.offset.must_equal 20
    end

    it "should set current_page" do
      page = Item.paginate(page: 3, per_page: 10)
      page.current_page.must_equal 3
    end

    it "should have the right count" do
      page = Item.paginate(page: 3, per_page: 10)
      page.count.must_equal 4
    end

    it "should have the right size" do
      page = Item.paginate(page: 3, per_page: 10)
      page.size.must_equal 4
    end

    it "should return the expected items" do
      page = Item.paginate(page: 3, per_page: 10)
      page.must_equal Item.offset(20).all
    end

    it "should auto-count total_entries unless specified as nil" do
      page = Item.paginate
      page.total_entries.must_equal 24
    end

    it "should correctly auto-count total_entries with a grouping" do
      page = Item.group(:filter).paginate
      page.total_entries.must_equal 2
    end

    it "should correctly auto-count total_entries with a grouping and a having" do
      page = Item.group(:filter).having("COUNT(*)>1").paginate
      page.total_entries.must_equal 2
    end

    it "should work with total_entries nil" do
      page = Item.paginate(page: 3, total_entries: nil)
      page.current_page.must_equal 3
    end

    it "should work with per_page nil" do
      page = Item.paginate(per_page: nil)
      page.per_page.must_equal Folio.per_page
    end

    it "should validate page number against auto-counted total_entries" do
      lambda{ Item.paginate(page: 4, per_page: 10) }.must_raise Folio::InvalidPage
      end

    it "should raise on negative page" do
      lambda{ Item.paginate(page: -1) }.must_raise Folio::InvalidPage
    end

    it "should raise on page of 0" do
      lambda{ Item.paginate(page: 0) }.must_raise Folio::InvalidPage
    end

    it "should raise on page greater than known last_page" do
      lambda{ Item.paginate(page: 4, total_entries: 30) }.must_raise Folio::InvalidPage
    end

    it "should work on relations" do
      page = Item.where(filter: true).paginate(page: 2, per_page: 10)
      page.count.must_equal 2
    end

    it "should work on associations" do
      item = Item.first
      12.times{ |i| item.related_things.create! }
      page = item.related_things.paginate(page: 2, per_page: 10)
      page.count.must_equal 2
    end
  end
end
