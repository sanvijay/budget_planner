class Asset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :title, type: String
  field :value, type: Float

  embedded_in :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :value, presence: true, numericality: true

  before_save :set_value_precision

  def categories
    @categories ||= user.categories.where(asset_id: id)
  end

  def inflow_category_ids
    @inflow_category_ids ||= categories.where(
      :type.in => Category::INFLOW_SUPER_CATEGORY
    ).pluck(:id)
  end

  def inflow_actual_cash_flow_logs(financial_year: nil)
    value = 0

    all_monthly_budgets(financial_year.to_i).each do |mb|
      value += mb.actual_cash_flow_logs.where(
        :category_id.in => inflow_category_ids
      ).sum(:value)
    end
    value
  end

  def outflow_category_ids
    @outflow_category_ids ||= categories.where(
      :type.in => Category::OUTFLOW_SUPER_CATEGORY
    ).pluck(:id)
  end

  def outflow_actual_cash_flow_logs(financial_year: nil)
    value = 0

    all_monthly_budgets(financial_year.to_i).each do |mb|
      value += mb.actual_cash_flow_logs.where(
        :category_id.in => outflow_category_ids
      ).sum(:value)
    end

    value
  end

  def total_cost(financial_year: nil)
    {
      inflow: inflow_actual_cash_flow_logs(financial_year: financial_year),
      outflow: outflow_actual_cash_flow_logs(financial_year: financial_year)
    }
  end

  private

  def all_monthly_budgets(financial_year = nil)
    if financial_year
      user.monthly_budgets.of_the_financial_year(financial_year.to_i)
    else
      user.monthly_budgets
    end
  end

  def set_value_precision
    self.value = value.round(2)
  end
end
