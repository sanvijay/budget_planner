class MonthlyBudget
  include Mongoid::Document

  field :month, type: Date

  belongs_to :user

  validates :month, presence: true, uniqueness: { scope: :user }
end
