require 'nokogiri'
require 'sanitize'

module Sanitizer

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def sanitize_html(*attrs)
      begin 
        unless(ActiveRecord::Base.connection.column_exists?(
          table_name.to_sym, :sanitized_fields, :hstore))
          raise "In order to use sanitize_html, you must define a field on this model called 'sanitized_fields' of type :hstore"
        end
      rescue ActiveRecord::StatementInvalid
        # this error happens when running migrations because the table
        # might not exist
        return
      end

      before_save do
        changed_fields = {}
        attrs.each do |field|
          if (changes.keys.include?(field.to_s))
            doc = Nokogiri::HTML(read_attribute(field))

            # strip entire script tags
            doc.xpath('//script').remove

            sanitized = Sanitize.clean(doc.to_s, 
              :elements => ['p', 'br', 'strong', 'b', 'em', 'sup', 'sub', 'ul', 'ol', 'li', 'pre', 'blockquote', 'a', 'img'],
              :attributes => {'a' => ['href', 'title'], 'img' => ['src']},
              :protocols => {'a' => {'href' => ['http', 'https', :relative]}, 'img' => {'href' => ['http', 'https', :relative]}},
              :add_attribute => { 'a' => {'rel' => 'nofollow'}}
            )

            # reparse and remove empty links that the sanitizer left behind
            doc = Nokogiri::HTML(sanitized)
            doc.xpath('//a[@href=""]').each do |link|
              link.replace link.content
            end
            doc.xpath('//a[not(@href)]').each do |link|
              link.replace link.content
            end

            html = doc.xpath('/html/body').to_s.gsub(/^<body>(.*)<\/body>$/, '\1')
            changed_fields[field.to_s] = html
          end
        end
        # ugly workaround for the fact that ActiveRecord can't do dirty tracking
        # on keys inside an hstore.  yet.
        unless (changed_fields.empty?)
          sanitized_fields = {} if (sanitized_fields.nil?)
          self.sanitized_fields = sanitized_fields.merge(changed_fields)
        end

        # if no sanitized fields have been set, make it an empty array
        self.sanitized_fields = {} if sanitized_fields.nil?
      end
    end
  end
end

ActiveRecord::Base.send(:include, Sanitizer)