# encoding: utf-8

module Rouge::Seq
  Empty = Object.new
  class << Empty
    def first; nil; end
    def next; nil; end
    def more; self; end
    def cons(o); ArraySeq.new([o], 0); end
    def seq; nil; end
  end

  module ASeq
    def seq; self; end
    def cons(o); Rouge::Cons.new(o, self); end
    def more
      s = self.next
      if s.nil?
        Rouge::Cons::Empty
      else
        s
      end
    end
  end

  class ArraySeq
    include ASeq

    def initialize(array, i)
      @array = array
      @i = i
    end

    def next
      if @i + 1 < @array.length
        ArraySeq.new(@array, @i + 1)
      else
        nil
      end
    end

    def first
      @array[@i]
    end
  end

  class Cons
    include ASeq

    def initialize(first, more)
      @first = first
      @more = more
    end

    def next
      more.seq
    end

    def first
      @first
    end

    def more
      if @more.nil?
        Empty
      else
        @more
      end
    end
  end

  class Lazy
    def initialize(body)
      @body = body
      @realised = false
      @value = nil
    end
  end
end

# vim: set sw=2 et cc=80:
