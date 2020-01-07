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
end
