class MonthlyBudget
  include Mongoid::Document

  field :month, type: Date

  belongs_to :user
  embeds_many :expected_cash_flows
  embeds_many :actual_cash_flows

  validates :month, presence: true, uniqueness: { scope: :user }

  scope :of_the_year, lambda { |year|
    where(
      :month.gte => Date.new(year, 1, 1),
      :month.lte => Date.new(year + 1, 1, 1)
    )
  }

  scope :of_the_month, lambda { |date|
    where(
      :month.gte => date.beginning_of_month,
      :month.lte => date.end_of_month
    )
  }

  before_validation :set_month_as_beginning

  def to_param
    "#{format('%<digit>02d', digit: month.month)}#{month.year}"
  end

  private

  def set_month_as_beginning
    return if month.blank?

    self.month = month.beginning_of_month
  end
end
