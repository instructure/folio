begin
  require 'will_paginate/active_record'
rescue LoadError
  raise "folio-pagination's activerecord support requires will_paginate"
end

require 'folio/page'
require 'folio/ordinal'
require 'folio/ordinal/page'

module Folio
  module WillPaginate
    # enhances model_or_scope.page(n) method from WillPaginate to behave like a
    # Folio::Ordinal::Page. replaces model_or_scope.paginate(...) method to
    # behave like that from Folio while preserving basic mechanics of the
    # version from WillPaginate.
    #
    # differences:
    #
    #  * total_entries loading via count is *not* deferred as it was under
    #    WillPaginate.
    #
    #  * paginate does *not* recognize any parameters beyond those described in
    #    for Folio's paginate (e.g. finder options, count options).
    #
    module ActiveRecord
      module RelationMethods
        include Folio::Page
        include Folio::Ordinal::Page

        # overrides Folio::Page's per_page similar to WillPaginate's version,
        # but uses correct semantics for per_page(nil) (vs. per_page()).
        def per_page(*args)
          if args.size > 0
            raise ArgumentError if args.size > 1
            value ||= @klass.per_page
            limit(value)
          end
          limit_value
        end

        # overrides WillPaginate's weird "ignore limit when counting" behavior.
        # I can't fall back on super in the branch with a limit_value, since
        # that would fall into WillPaginate's lap, but since there is a
        # limit_value, safe enough to just instantiate and check length
        def count
          if limit_value
            to_a.size
          else
            super
          end
        end
      end

      module Pagination
        # turns the sequence of calls made by Folio::Ordinal#paginate into the
        # construction of an appropriate relation
        class PageProxy
          def initialize(target)
            @target = target
          end

          include Folio::Ordinal::Page

          # called during Folio#configure_pagination, used to build up @rel
          # from @target and the arguments
          attr_writer :current_page

          def per_page=(per_page)
            @rel = @target.limit(per_page.to_i).page(@current_page)
            @rel.limit_value
          end

          def total_entries=(total_entries)
            @rel.total_entries = total_entries
          end

          # called during Folio::Ordinal#configure_pagination for bounds
          # checking, before the proxy has been replaced by its result
          def current_page
            @rel.current_page
          end

          def out_of_bounds?
            @rel.out_of_bounds?
          end

          # get the result of the construction back out during fill_page
          def result
            @rel
          end
        end

        # set up the proxy to receive the calls
        def build_page
          PageProxy.new(self)
        end

        # pull the result out of the proxy
        def fill_page(proxy)
          proxy.result
        end

        # make sure the relation coming out of page(...) is folio-compatible
        def page(num)
          super.extending(RelationMethods)
        end

        # don't try and look at Class (ActiveRecord::Base.class, etc.) for
        # defaults
        def default_per_page
          Folio.per_page
        end

        include ::Folio::Ordinal

        def paginate(options={})
          if !options.has_key?(:total_entries)
            group_values = self.scoped.group_values
            unless group_values.empty?
              # total_entries left to an auto-count, but the relation being
              # paginated has a grouping. we need to do a special count, lest
              # self.count give us a hash instead of the integer we expect.
              options[:total_entries] = except(:group).select(group_values).uniq.count
            end
          end
          super(options)
        end
      end

      # mix into Active Record. these are the same ones that WillPaginate mixes
      # its version of Pagination into.
      ::ActiveRecord::Base.extend Pagination
      klasses = [::ActiveRecord::Relation]
      if defined? ::ActiveRecord::Associations::CollectionProxy
        klasses << ::ActiveRecord::Associations::CollectionProxy
      else
        klasses << ::ActiveRecord::Associations::AssociationCollection
      end
      klasses.each { |klass| klass.send(:include, Pagination) }
    end
  end
end
