require 'folio'
require 'folio/will_paginate/view_helpers/link_renderer_base'
require 'folio/will_paginate/view_helpers/link_renderer'
require 'will_paginate/view_helpers'

module Folio
  module WillPaginate
    module ViewHelpers
      # just copied from ::WillPaginate::ViewHelpers except line 14 (changed from
      # "unless value > 1" to "if value == 1" to be friendly to unknown
      # total_pages)
      def will_paginate_with_folio(collection, options = {})
        # early exit if there is nothing to render
        return nil if collection.total_pages == 1

        options = ::WillPaginate::ViewHelpers.pagination_options.merge(options)

        options[:previous_label] ||= will_paginate_translate(:previous_label) { '&#8592; Previous' }
        options[:next_label]     ||= will_paginate_translate(:next_label) { 'Next &#8594;' }

        # get the renderer instance
        renderer = case options[:renderer]
        when nil
          raise ArgumentError, ":renderer not specified"
        when String
          klass = if options[:renderer].respond_to? :constantize then options[:renderer].constantize
            else Object.const_get(options[:renderer]) # poor man's constantize
            end
          klass.new
        when Class then options[:renderer].new
        else options[:renderer]
        end
        # render HTML for pagination
        renderer.prepare collection, options, self
        output = renderer.to_html
        output = output.html_safe if output.respond_to?(:html_safe)
        output
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
