class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  SUPER_CATEGORY = %w[Income Expense EMI EquityInvestment DebtInvestment]
                   .map { |cat| [cat.underscore.to_sym, cat] }.to_h

  field :title, type: String
  field :type, type: String

  embedded_in :user

  validates :type, presence: true, inclusion: { in: SUPER_CATEGORY.values }
  validates :title, presence: true, length: { maximum: 255 },
                    uniqueness: { scope: :type, case_sensitive: false }

  scope :by_income, -> { where(type: SUPER_CATEGORY[:income]) }
  scope :by_expense, -> { where(type: SUPER_CATEGORY[:expense]) }
  scope :by_emi, -> { where(type: SUPER_CATEGORY[:emi]) }
  scope :by_equity_investment, lambda {
    where(type: SUPER_CATEGORY[:equity_investment])
  }
  scope :by_debt_investment, lambda {
    where(type: SUPER_CATEGORY[:debt_investment])
  }
end
