module Spree
  Product.class_eval do
    def self.feeds_base_scope
      active.uniq
    end
  end
end
