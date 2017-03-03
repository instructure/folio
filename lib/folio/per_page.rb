module Folio
  module PerPage
    def default_per_page
      Folio.per_page
    end

    def per_page(*args)
      raise ArgumentError if args.size > 1
      @per_page = (args.first && args.first.to_i) if args.size > 0
      instance_variable_defined?(:@per_page) ? @per_page || default_per_page : default_per_page
    end

    alias_method :per_page=, :per_page
  end
end
