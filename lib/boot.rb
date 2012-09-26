




seq = __rouge_ns[:seq] =
  lambda {|coll|
    # s = Rouge::Cons[*(coll.to_a)]
    s = Rouge::Cons.send(:[], *(coll.to_a))
    if s.== Rouge::Cons::Empty
      nil
    else
      s
    end
  }

concat = __rouge_ns[:concat] =
  lambda {|*lists|

  lists.map(&lambda {|r| r.to_a}).inject(&lambda {|r
    seq.call(lists.map(&:to_a).inject(:+))
    # seq.call(lists.map(&:to_a).inject(:+))
  }
