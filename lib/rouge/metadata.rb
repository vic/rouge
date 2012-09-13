# encoding: utf-8

module Rouge::Metadata
  class InvalidMetadataError < StandardError; end

  def meta
    @meta
  end

  def meta= m
    if m != nil and m.class != Hash
      raise InvalidMetadataError, "bad metadata: #{m.inspect}"
    end

    @meta = m
  end
end

# vim: set sw=2 et cc=80:
