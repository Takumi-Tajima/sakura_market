class TaxRate
  DEFAULT = 1.10
  REDUCED = 1.08

  def self.default
    DEFAULT
  end

  def self.reduced
    REDUCED
  end

  def self.calculate_tax_amount(amount, rate = default)
    BigDecimal(amount.to_s) * (rate - 1)
  end
end
