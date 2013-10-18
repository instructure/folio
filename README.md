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

### Ordinal Folios

A typical use case for pagination deals with ordinal page identifiers;
e.g. "1" means the first page, "2" means the second page, etc.

As a matter of convenience for these use cases, an additional mixin is
provided: `Folio::Ordinal`.

Mixing this into your source instead of `Folio` has the same
requirements and benefits, except the responsibilities of the
`build_page` and `fill_page` methods are narrowed.

`build_page` no longer needs to configure `ordinal_page?`, `first_page`,
or `last_page` on the instantiated page, as these values can all be
inferred. `ordinal_page?` will be set true and `first_page` set to 1,
while the `last_page` attribute is replaced by an alias to
`total_pages`. The method now simply needs to choose a type of
`Folio::Page` to instantiate and return it.

Similarly, `fill_page` no longer needs to configure `next_page` and
`last_page`; they will be calculated from `current_page`, `first_page`,
and `last_page`. Instead, the method can focus entirely on populating
the page.

### Basic Page

As a minimal example and default simple implementation, we provide
`Folio::BasicPage`, which is simply a subclass of Array extended with
the `Folio::Page` mixin.

### Enumerable Extension

If you require `folio/core_ext/enumerable`, all `Enumerable`s will be
extended with `Folio::Ordinal` and naive `build_page` and `fill_page`
methods.

`build_page` will simply return a `Folio::BasicPage` (which will be
decorated by `Folio::Ordinal` as described above) to hold the results.
`fill_page` then selects an appropriate range of items from the folio
using standard `Enumerable` methods, then calls `replace` on the page
(subclass of `Array`, remember?) with this subset.

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
