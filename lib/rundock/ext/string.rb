class String
  def just(pad, max)
    return self.ljust(max, pad) if length <= max
    return "#{self[0..(max - 3)]}.." if length > max
  end
end
