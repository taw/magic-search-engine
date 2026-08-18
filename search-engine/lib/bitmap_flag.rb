# A boolean instance variable costs 8 bytes on every instance whether it is set
# or not, and ruby picks an object's size class from the most instance variables
# any instance of that class reaches - 38 fit in 320 bytes, 39 need 640. Cards
# and printings carry enough booleans between them to cross that line on their
# own, so they keep them as bits of a single integer.
#
# Declare them in one list, like attr_accessor. Each name takes the next bit, so
# the list is append-only. Every name gets a reader, a `?` alias and a writer,
# and the class has to start @flags off at 0 itself.
#
#   class Card
#     extend BitmapFlag
#     FLAG_BITS = bitmap_flags :funny, :reserved, :modal
#   end
#
# The returned name => bit hash is there for classes that want a mask over
# several flags at once.
module BitmapFlag
  def bitmap_flags(*names)
    raise "#{self} already declared bitmap flags, they have to go in one list" if @bitmap_flags
    @bitmap_flags = names.each_with_index.to_h{|name, index| [name, 1 << index] }.freeze

    @bitmap_flags.each do |name, mask|
      # Integer#[] and #anybits? measure the same as this within 5% over 300k
      # calls, so this is simply the readable one rather than a trick
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{name}
          @flags & #{mask} != 0
        end
        alias_method :#{name}?, :#{name}

        def #{name}=(value)
          if value
            @flags |= #{mask}
          else
            @flags &= ~#{mask}
          end
        end
      RUBY
    end

    @bitmap_flags
  end
end
