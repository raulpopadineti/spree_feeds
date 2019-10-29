# RSS specification:
# - https://support.google.com/merchants/answer/1344057
# - https://support.google.com/merchants/answer/188494
# - https://support.google.com/merchants/answer/160589
# - https://support.google.com/merchants/answer/1347943
# - https://support.google.com/merchants/answer/160081
#
# Mandatory attributes:
# - id
# - title
# - description
# - google_product_category
# - link
# - image_link
# - condition
# - availability
# - price
# - item_group_id (only if the product has variants)
require 'csv'

module SpreeFeeds
  class Google < SpreeFeeds::Base

    def perform
      tags = SpreeFeeds::Config.google_shopping_tags
      file_path = "#{@base_path}/google.tsv"
      tmp_name = "#{file_path}.tmp"

      options = { col_sep: '\t' }
      CSV.open(tmp_name, "w", options) do |csv|
        csv << tags

        @products.find_each(batch_size: 200) do |product|
          variants = product.variants.many? ? product.variants : [product.master]
          variants.each do |variant|
            helper = Helpers::GoogleShoppingFeed.new(variant, @root_url)
            csv << tags.map do |tag|
              if helper.respond_to?(tag) && value = helper.public_send(tag)
                value
              end
            end
          end
        end
      end

      File.rename(tmp_name, file_path)
    end
  end
end
