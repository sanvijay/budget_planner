class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  INFLOW_SUPER_CATEGORY = %w[Income].freeze
  OUTFLOW_SUPER_CATEGORY = %w[
    Expense
    EMI
    EquityInvestment
    DebtInvestment
  ].freeze

  SUPER_CATEGORY = (INFLOW_SUPER_CATEGORY + OUTFLOW_SUPER_CATEGORY)
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

  validate :goal_belongs_to_this_owner, :asset_belongs_to_this_owner,
           :benefit_belongs_to_this_owner, :benefit_only_for_expenses

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

  def asset_belongs_to_this_owner
    return if asset_id.blank?
    return true unless asset.nil?

    errors.add(:asset_id, "should belong to current user")
  end

  def benefit_belongs_to_this_owner
    return if benefit_id.blank?
    return true unless benefit.nil?

    errors.add(:benefit_id, "should belong to current user")
  end

  def benefit_only_for_expenses
    return if benefit_id.blank?
    return true if INFLOW_SUPER_CATEGORY.exclude?(type)

    errors.add(:benefit_id, "can only be added to expenses")
  end
end
