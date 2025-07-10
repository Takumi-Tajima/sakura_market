class TaxRate
  STANDARD = 1.10
  REDUCED = 1.08

  def self.default
    STANDARD
  end

  def self.reduced
    REDUCED
  end
end
