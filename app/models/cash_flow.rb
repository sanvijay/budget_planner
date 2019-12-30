class CashFlow
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :monthly_budget

  field :category_id, type: BSON::ObjectId
  field :value, type: Float

  validates :category_id, presence: true
  validates :value, presence: true, numericality: true

  validate :category_belongs_to_this_owner

  before_save :set_value_precision

  private

  def set_value_precision
    self.value = value.round(2)
  end

  def category_belongs_to_this_owner
    return if category_id.blank?
    return true unless monthly_budget.user.categories.find(category_id).nil?

    errors.add(:category_id, "should belong to current user")
  end
end
