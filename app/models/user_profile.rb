class UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  GENDERS = %w[Male Female Androgyny]
            .index_by { |gender| gender.underscore.to_sym }

  field :first_name, type: String
  field :last_name, type: String
  field :dob, type: Date
  field :gender, type: String
  field :expense_ratio, type: Hash, default: {
    expense: 30,
    emi: 40,
    equity_investment: 10,
    debt_investment: 20
  }
  field :monthly_income, type: Float

  embedded_in :user

  before_validation :expense_ratio_make_numeric

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :dob, presence: true
  validates :gender, presence: true, inclusion: { in: GENDERS.values }
  validates :expense_ratio, presence: true

  validate :dob_to_be_in_past
  validate :expense_ratio_has_four_entries, :expense_ratio_adds_to_100

  before_save :set_monthly_income_precision

  private

  def set_monthly_income_precision
    self.monthly_income &&= monthly_income.round(2)
  end

  def age
    return 0 if dob.nil?

    @age ||= Time.zone.today.year - dob.year
  end

  def dob_to_be_in_past
    return if dob.nil?
    return true if dob < Time.zone.today

    errors.add(:dob, "should be in past")
  end

  def expense_ratio_make_numeric
    return if expense_ratio.nil?

    Category::OUTFLOW_SUPER_CATEGORY.each do |cat|
      sym_cat = cat.underscore.to_sym
      expense_ratio[sym_cat] = expense_ratio[sym_cat].to_f
    end
  end

  def expense_ratio_has_four_entries
    return if expense_ratio.nil?
    return true if expense_ratio.count == 4

    errors.add(:expense_ratio, "should have 4 numbers")
  end

  def expense_ratio_adds_to_100
    return if expense_ratio.nil?
    return true if expense_ratio.values.reduce(:+) == 100

    errors.add(:expense_ratio, "should adds to 100")
  end
end
