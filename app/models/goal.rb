class Goal
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :description, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :target, type: Float
  field :completed, type: Boolean
  field :score_weightage_out_of_100, type: Integer, default: 100

  embedded_in :user

  validates :description, presence: true, length: { maximum: 255 }
  validates :target, presence: true, numericality: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :score_weightage_out_of_100, presence: true

  validate :end_date_cannot_be_in_past_of_start_date
  validate :description_with_same_category_title

  before_save :set_target_precision
  after_create :create_category, :create_planned_cash_flows

  def category
    @category ||= user.categories.find_by(goal_id: id)
  end

  def planned_cash_flow
    user.monthly_budgets.of_period(start_date, end_date).inject(0) do |sum, mb|
      sum + mb.planned_cash_flows.find_by(category_id: category.id).try(:value)
    end
  end

  private

  def set_target_precision
    self.target = target.round(2)
  end

  def end_date_cannot_be_in_past_of_start_date
    return if start_date.blank? || end_date.blank?
    return true if start_date < end_date

    errors.add(:end_date, "can't be in the past of start date")
  end

  def description_with_same_category_title
    return unless new_record?
    return unless user&.categories&.find_by(title: description)

    errors.add(
      :title,
      "can't have description with already existing category"
    )
  end

  def create_category
    @category = user.categories.create!(
      title: description,
      type: "EMI",
      goal_id: id
    )
  end

  def create_planned_cash_flows
    num_of_months = num_of_months_needs_to_achieve_goal
    split = target / num_of_months
    num_of_months.times do |i|
      monthly_budget = user.monthly_budgets.find_or_create_by(
        month: start_date.beginning_of_month + i.month
      )
      monthly_budget.planned_cash_flows.create!(
        category_id: @category.id, value: split
      )
    end
  end

  def num_of_months_needs_to_achieve_goal
    start = start_date.beginning_of_month
    complete = end_date.end_of_month

    # https://stackoverflow.com/a/9428676
    (complete.year * 12 + complete.month) - (start.year * 12 + start.month) + 1
  end
end
