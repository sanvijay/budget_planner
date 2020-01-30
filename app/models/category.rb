class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  SUPER_CATEGORY = %w[Income Expense EMI EquityInvestment DebtInvestment]
                   .map { |cat| [cat.underscore.to_sym, cat] }.to_h

  field :title, type: String
  field :type, type: String
  field :goal_id, type: BSON::ObjectId
  field :benefit_id, type: BSON::ObjectId
  field :asset_id, type: BSON::ObjectId

  embedded_in :user

  validates :type, presence: true, inclusion: { in: SUPER_CATEGORY.values }
  validates :title, presence: true, length: { maximum: 255 },
                    uniqueness: { scope: :type, case_sensitive: false }

  validate :goal_belongs_to_this_owner

  scope :by_income, -> { where(type: SUPER_CATEGORY[:income]) }
  scope :by_expense, -> { where(type: SUPER_CATEGORY[:expense]) }
  scope :by_emi, -> { where(type: SUPER_CATEGORY[:emi]) }
  scope :by_equity_investment, lambda {
    where(type: SUPER_CATEGORY[:equity_investment])
  }
  scope :by_debt_investment, lambda {
    where(type: SUPER_CATEGORY[:debt_investment])
  }

  def goal
    @goal ||= goal_id && user.goals.find(goal_id)
  end

  def benefit
    @benefit ||= benefit_id && user.benefits.find(benefit_id)
  end

  def asset
    @asset ||= asset_id && user.assets.find(asset_id)
  end

  private

  def goal_belongs_to_this_owner
    return if goal_id.blank?
    return true unless goal.nil?

    errors.add(:goal_id, "should belong to current user")
  end
end
