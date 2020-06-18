class Benefit
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :title, type: String
  field :value, type: Float
  field :score_weightage_out_of_100, type: Integer, default: 100

  embedded_in :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :value, presence: true, numericality: { other_than: 0 }
  validates :score_weightage_out_of_100, presence: true

  before_save :set_value_precision

  def categories
    @categories ||= user.categories.where(benefit_id: id)
  end

  def category_ids
    @category_ids ||= categories.pluck(:id)
  end

  def yearly_total(financial_year:)
    value = 0
    user.monthly_budgets.of_the_financial_year(financial_year.to_i).each do |mb|
      value += mb.actual_cash_flow_logs.where(:category_id.in => category_ids)
                 .sum(:value)
    end

    value
  end

  private

  def set_value_precision
    self.value &&= value.round(2)
  end
end
