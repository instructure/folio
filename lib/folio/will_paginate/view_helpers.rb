require 'folio'
require 'folio/will_paginate/view_helpers/link_renderer'
require 'will_paginate/view_helpers'

module Folio
  module WillPaginate
    module ViewHelpers
      # just copied from ::WillPaginate::ViewHelpers except line 20 (changed from
      # "unless value > 1" to "if value == 1" to be friendly to unknown
      # total_pages)
      def will_paginate_with_folio(collection = nil, options = {})
        options, collection = collection, nil if collection.is_a? Hash
        unless collection or !controller
          collection_name = "@#{controller.controller_name}"
          collection = instance_variable_get(collection_name)
          raise ArgumentError, "The #{collection_name} variable appears to be empty. Did you " +
            "forget to pass the collection object for will_paginate?" unless collection
        end
        # early exit if there is nothing to render
        return nil if ::WillPaginate::ViewHelpers.total_pages_for_collection(collection) == 1

        options = options.symbolize_keys.reverse_merge ::WillPaginate::ViewHelpers.pagination_options
        if options[:prev_label]
          WillPaginate::Deprecation::warn(":prev_label view parameter is now :previous_label; the old name has been deprecated", caller)
          options[:previous_label] = options.delete(:prev_label)
        end

        # get the renderer instance
        renderer = case options[:renderer]
        when String
          options[:renderer].to_s.constantize.new
        when Class
          options[:renderer].new
        else
          options[:renderer]
        end
        # render HTML for pagination
        renderer.prepare collection, options, self
        renderer.to_html
      end

      def page_entries_info_with_folio(collection, options = {})
        # skip outputting anything unless the collection has ordinal pages (to
        # be able to get an offset) *and* a known total count.
        return unless collection.total_entries && collection.ordinal_pages
        page_entries_info_without_folio(collection, options)
      end

      def self.included(klass)
        [:will_paginate, :page_entries_info].each do |method|
          klass.send(:alias_method, :"#{method}_without_folio", method)
          klass.send(:alias_method, method, :"#{method}_with_folio")
        end
      end

      ::WillPaginate::ViewHelpers.send :include, self
    end
  end
end
