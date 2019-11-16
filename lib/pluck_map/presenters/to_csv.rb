require "pluck_map/errors"

module PluckMap
  module CsvPresenter

    def self.included(base)
      def base.to_csv(query, **kargs)
        new(query).to_csv(**kargs)
      end
    end

    def to_csv
      if attributes.nested?
        raise PluckMap::UnsupportedAttributeError, "to_csv can not be used to present nested attributes"
      end

      define_to_csv!
      to_csv
    end

    private def define_to_csv!
      require "csv"

      headers = CSV.generate_line(attributes.map(&:name))
      ruby = <<-RUBY
      def to_csv
        pluck do |results|
          rows = [#{headers.inspect}]
          results.each_with_object(rows) do |values, rows|
            values = Array(values)
            rows << CSV.generate_line([#{attributes.map(&:to_ruby).join(", ")}])
          end.join
        end
      end
      RUBY
      # puts "\e[34m#{ruby}\e[0m" # <-- helps debugging PluckMapPresenter
      class_eval ruby, __FILE__, __LINE__ - 7
    end

  end
end
