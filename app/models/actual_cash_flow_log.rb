class ActualCashFlowLog
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :monthly_budget

  field :description, type: String
  field :category_id, type: BSON::ObjectId
  field :spent_on, type: DateTime
  field :value, type: Float

  validates :description, presence: true, length: { maximum: 50 }
  validates :category_id, presence: true
  validates :spent_on, presence: true
  validates :value, presence: true, numericality: true

  validate :category_belongs_to_this_owner

  before_save :create_cash_flow
  before_save :set_value_precision

  def category
    @category ||= category_id &&
                  monthly_budget&.user&.categories&.find(category_id)
  end

  protected

  def set_value_precision
    self.value = value.round(2)
  end

  def create_cash_flow
    return if monthly_budget.cash_flows.find_by(category_id: category_id)

    monthly_budget.cash_flows.create!(
      category_id: category_id,
      planned: 0
    )
  end

  def category_belongs_to_this_owner
    return if category_id.blank?
    return true unless category.nil?

    errors.add(:category_id, "should belong to current user")
  end
end
