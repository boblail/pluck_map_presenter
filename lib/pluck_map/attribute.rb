module PluckMap
  class Attribute
    attr_reader :id, :selects, :name, :value, :block
    attr_accessor :indexes

    def initialize(id, options={})
      @id = id
      @selects = Array(options.fetch(:select, id))
      @name = options.fetch(:as, id)
      @block = options[:map]

      if options.key? :value
        @value = options[:value]
        @selects = []
      else
        raise ArgumentError, "You must select at least one column" if selects.empty?
        raise ArgumentError, "You must define a block if you are going to select " <<
          "more than one expression from the database" if selects.length > 1 && !block
      end
    end

    def apply(object)
      block.call(*object)
    end

    def no_map?
      block.nil?
    end

    # When the PluckMapPresenter performs the query, it will
    # receive an array of rows. Each row will itself be an
    # array of values.
    #
    # This method constructs a Ruby expression that will
    # extract the appropriate values from each row that
    # correspond to this Attribute.
    def to_ruby(selects = nil)
      if selects
        puts "DEPRECATION WARNING: PluckMap::Attribute#to_ruby no longer requires an argument. Replace `attribute.to_ruby(keys)` with `attribute.to_ruby`."
      end

      return @value.inspect if defined?(@value)
      return "values[#{indexes[0]}]" if indexes.length == 1 && !block
      ruby = "values.values_at(#{indexes.join(", ")})"
      ruby = "invoke(:\"#{id}\", #{ruby})" if block
      ruby
    end



    def values
      [id, selects, name, value, block]
    end

    def ==(other)
      return false if self.class != other.class
      self.values == other.values
    end

    def hash
      values.hash
    end

    def eql?(other)
      return true if self.equal?(other)
      return false if self.class != other.class
      self.values.eql?(other.values)
    end
  end
end
