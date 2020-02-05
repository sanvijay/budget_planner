class CashFlow
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :monthly_budget

  field :category_id, type: BSON::ObjectId
  field :planned, type: Float

  validates :category_id, presence: true, uniqueness: true
  validates :planned, presence: true, numericality: true

  validate :category_belongs_to_this_owner

  before_save :set_planned_precision

  def category
    @category ||= category_id &&
                  monthly_budget.user.categories.find(category_id)
  end

  def actual
    logs.pluck(:value).reduce(:+) || 0
  end

  def logs
    @logs ||= monthly_budget.actual_cash_flow_logs
                            .where(category_id: category_id)
  end

  private

  def set_planned_precision
    self.planned = planned.round(2)
  end

  def category_belongs_to_this_owner
    return if category_id.blank?
    return true unless category.nil?

    errors.add(:category_id, "should belong to current user")
  end
end
