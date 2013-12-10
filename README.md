# Folio

`Folio` is a library for pagination. It's meant to be nearly compatible
with `WillPaginate`, but with broader -- yet more well-defined --
semantics to allow for sources whose page identifiers are non-ordinal
(i.e. a page identifier of `3` does not necessarily indicate the third
page).

[![Build Status](https://travis-ci.org/instructure/folio.png?branch=master)](https://travis-ci.org/instructure/folio)

## Installation

Add this line to your application's Gemfile:

    gem 'folio-pagination'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install folio-pagination

## Usage

The core `Folio` interface is defined by two mixins. Mixing `Folio` into
a source of items creates a "folio" and provides pagination on that
folio. Mixing `Folio::Page` into a subset of items from a folio creates
a "page" with additional properties relating it to the folio and the
other pages in the folio.

`Folio` also provides some basic implementations, both standalone and by
mixing these modules in to familiar classes.

### Pages

You can mix `Folio::Page` into any `Enumerable`. The mixin gives you
eight attributes and one method:

 * `ordinal_pages?` indicates whether the page identifiers in
   `current_page`, `first_page`, `last_page`, `previous_page`, and
   `next_page` should be considered ordinal or not.

 * `current_page` is the page identifier addressing this page within the
   folio.

 * `per_page` is the number of items requested from the folio when
   filling this page.

 * `first_page` is the page identifier addressing the first page within
   the folio.

 * `last_page` is the page identifier addressing the final page within
   the folio, if known.

 * `next_page` is the page identifier addressing the immediately
   following page within the folio, if there is one.

 * `previous_page` is the page identifier addressing the immediately
   preceding page within the folio, if there is one and it is known.

 * `total_entries` is the number of items in the folio, if known.

 * `total_pages` if the number of pages in the folio, if known. It is
   calculated from `total_entries` and `per_page`.

`ordinal_pages?`, `first_page`, and `last_page` are common to all pages
created by a folio and are configured, as available, when the folio
creates a blank page in its `build_page` method (see below).

`current_page`, `per_page`, and `total_entries` control the filling of a
page and are configured from parameters to the folio's `paginate`
method.

`next_page` and `previous_page` are configured, as available, when the
folio fills the configured page in its `fill_page` method (see below).

### Folios

You can mix `Folio` into any class implementing two methods:

 * `build_page` is responsible for instantiating a `Folio::Page` and
   configuring its `ordinal_pages?`, `first_page`, and `last_page`
   attributes.

 * `fill_page` will receive a `Folio::Page` with the `ordinal_pages?`,
   `first_page`, `last_page`, `current_page`, `per_page`, and
   `total_entries` attributes configured, and should populate the page
   with the corresponding items from the folio. It should also set
   appropriate values for the `next_page` and `previous_page` attributes
   on the page. If the value provided in the page's `current_page`
   cannot be interpreted as addressing a page in the folio,
   `Folio::InvalidPage` should be raised.

In return, `Folio` provides a `paginate` method and `per_page`
attributes for both the folio class and for individual folio instances.

The `paginate` method coordinates the page creation, configuration, and
population. It takes three parameters: `page`, `per_page`, and
`total_entries`, each optional.

 * `page` configures the page's `current_page`, defaulting to the page's
   `first_page`.

 * `per_page` configures the page's `per_page`, defaulting to the
   folio's `per_page` attribute.

 * `total_entries` configures the page's `total_entries`, if present.
   otherwise, if the folio implements a `count` method, the page's
   `total_entries` will be set from that method.

NOTE: providing a `total_entries` parameter of nil will still bypass the
`count` method, leaving `total_entries` nil. This is useful when the
count would be too expensive and you'd rather just leave the number of
entries unknown.

The `per_page` attribute added to the folio instance will default to the
`per_page` attribute from the folio class when unset. The `per_page`
class attribute added to the folio class will default to global
`Folio.per_page` when unset.

### Ordinal Pages and Folios

A typical use case for pagination deals with ordinal page identifiers;
e.g. "1" means the first page, "2" means the second page, etc.

As a matter of convenience for these use cases, additional mixins of
`Folio::Ordinal` and `Folio::Ordinal::Page` are provided.

Mixing `Folio::Ordinal::Page` into an `Enumerable` provides the same
methods as `Folio::Page` but with the following overrides:

 * `ordinal_pages` is always true

 * `first_page` is always 1

 * `previous_page` is always either `current_page-1` or nil, depending
   on how `current_page` relates to `first_page`.

 * `next_page` can only be set if `total_pages` is unknown. if
   `total_pages` is known, `next_page` will be either `current_page+1`
   or nil, depending on how `current_page` relates to `last_page`. if
   `total_pages` is unknown and `next_page` is unset (vs. explicitly set
   to nil), it will default to `current_page+1`.

 * `last_page` is deterministic: always `total_pages` if `total_pages`
   is known, `current_page` if `total_pages` is unknown and `next_page`
   is nil, nil otherwise (indicating the page sequence continues until
   `next_page` is nil).

Similarly, mixing `Folio::Ordinal` into a source provides the same
methods as `Folio`, but simplifies your `build_page` and `fill_page`
methods by moving some responsibility into the `paginate` method.
`build_page` also has a default implementation.

 * `build_page` no longer needs to configure `ordinal_page?`, `first_page`,
   or `last_page` on the instantiated page. Instead, just instantiate
   and return a `Folio::Page` or `Folio::Ordinal::Page`. Then
   `ordinal_page?`, `first_page`, and `last_page` are handled for you,
   as described above. If not provided, the default implementation just
   returns a subclass of `Array` setup to be a `Folio::Ordinal::Page`.

 * `fill_page` no longer needs to configure `next_page` and
   `previous_page`; the ordinal page will handle them. (Note that if
   necessary, you can still set `next_page` explicitly to nil.) Also,
   `paginate` will now perform ordinal bounds checking for you, so you
   can focus entirely on populating the page.

### `BasicPage`s and `create`

Often times you just want to take the simplest collection possible. One
way would be to subclass `Array` and mixin `Folio::Page`, then
instantiate the subclass. When you want to add more, or `Array` isn't the
proper superclass, you can still do this.

For the common case we've already done it. This is the
`Folio::BasicPage` class. We've also provided a shortcut for
instantiating one: `Folio::Page.create`. So, for example, a simple
`build_page` method could just be:

```
  def build_page
    page = Folio::Page.create
    # setup ordinal_pages?, first_page, etc.
    page
  end
```

`Folio::Ordinal::BasicPage` and `Folio::Ordinal::Page.create` are also
available, respectively, for the ordinal case.

### Enumerable Extension

If you require `folio/core_ext/enumerable`, all `Enumerable`s will be
extended with `Folio::Ordinal` and naive `build_page` and `fill_page`
methods.

`build_page` will simply return a basic ordinal page as from
`Folio::Page::Ordinal.create`. `fill_page` then selects an appropriate
range of items from the folio using standard `Enumerable` methods, then
calls `replace` on the page (it's a `Folio::Ordinal::BasicPage`) with
this subset.

This lets you do things like:

```
require 'folio/core_ext/enumerable'

natural_numbers = Enumerator.new do |enum|
  n = 0
  loop{ enum.yield(n += 1) }
end
page = natural_numbers.paginate(page: 3, per_page: 5, total_entries: nil)

page.ordinal_pages?  #=> true
page.per_page        #=> 5
page.first_page      #=> 1
page.previous_page   #=> 2
page.current_page    #=> 3
page.next_page       #=> 4
page.last_page       #=> nil
page.total_entries   #=> nil
page.total_pages     #=> nil
page                 #=> [11, 12, 13, 14, 15]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
