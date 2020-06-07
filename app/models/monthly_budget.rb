class MonthlyBudget
  include Mongoid::Document

  field :month, type: Date
  field :prev_month_bal_actual, type: Float, default: 0
  field :prev_month_bal_actuals, type: Hash, default: {}
  field :prev_month_bal_planned, type: Float, default: 0

  belongs_to :user
  embeds_many :actual_cash_flow_logs
  embeds_many :cash_flows

  validates :month, presence: true, uniqueness: { scope: :user }
  validates :prev_month_bal_actual, numericality: true
  validates :prev_month_bal_planned, numericality: true

  validate :user_allowed_to_create
  validate :valid_prev_month_bal_actuals

  scope :of_the_year, lambda { |year|
    where(
      :month.gte => Date.new(year, 1, 1),
      :month.lte => Date.new(year + 1, 1, 1)
    )
  }

  scope :of_the_financial_year, lambda { |year|
    where(
      :month.gte => Date.new(year, 4, 1),
      :month.lte => Date.new(year + 1, 3, 31)
    )
  }

  scope :of_the_month, lambda { |date|
    where(
      :month.gte => date.beginning_of_month,
      :month.lte => date.end_of_month
    )
  }

  scope :of_period, lambda { |from, to|
    where(
      :month.gte => from.beginning_of_month,
      :month.lte => to.end_of_month
    )
  }

  before_validation :set_month_as_beginning
  before_validation :convert_prev_month_bal_actuals

  def to_param
    "#{format('%<digit>02d', digit: month.month)}#{month.year}"
  end

  private

  def set_month_as_beginning
    return if month.blank?

    self.month = month.beginning_of_month
  end

  def convert_prev_month_bal_actuals
    prev_month_bal_actuals.each do |acc, bal|
      prev_month_bal_actuals[acc.to_s] = bal.to_f
    end
  end

  def valid_prev_month_bal_actuals
    prev_month_bal_actuals.each do |acc, _bal|
      unless user.accounts.find(acc.to_s)
        errors.add(:prev_month_bal_actuals, "invalid accounts not allowed")
        break
      end
    end
  end

  # This is for creating goal and recurring budget plan.
  # We should find a better way to do above mentioned jobs.
  def user_allowed_to_create
    return errors.add(:base, "user not enabled") unless user.enabled?

    too_old_to_create?
    too_young_to_create?
  end

  def too_old_to_create?
    # (((user.user_profile.dob - month).days.to_i / 24 / 60 / 60) / 365.25)
    return if ((month - user.user_profile.dob).days.to_i / 31_557_600) < 100

    errors.add(:month, "too old to create budget")
  end

  def too_young_to_create?
    return if (month - user.user_profile.dob).days.to_i.positive?

    errors.add(:month, "too young to create budget")
  end
end
