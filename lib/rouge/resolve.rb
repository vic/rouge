# encoding: utf-8

module Rouge::Resolve; end

class << Rouge::Resolve
  def resolve(form)
    # We'll resolve symbols to their context/name pairs, or to
    # vars.
    # TESTS.
    # recursive
    form
  end
end

# vim: set sw=2 et cc=80:
