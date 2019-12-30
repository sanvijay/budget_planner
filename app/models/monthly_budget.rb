class MonthlyBudget
  include Mongoid::Document

  field :month, type: Date

  belongs_to :user
  embeds_many :expected_cash_flows
  embeds_many :actual_cash_flows

  validates :month, presence: true, uniqueness: { scope: :user }
end
