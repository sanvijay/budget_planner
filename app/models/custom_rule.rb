class CustomRule
  include Mongoid::Document
  include Mongoid::Timestamps

  field :emergency_corpus, type: Float # Current value user possess
  field :emergency_corpus_score_weightage_out_of_100, type: Integer,
                                                      default: 100

  field :outflow_split_percentage, type: Hash
  field :outflow_split_score_weightage_out_of_100, type: Integer, default: 100

  embedded_in :user

  validate :valid_user_profile

  validates :emergency_corpus, presence: true
  validates :outflow_split_percentage, presence: true

  # Weightages
  validates :emergency_corpus_score_weightage_out_of_100, presence: true
  validates :outflow_split_score_weightage_out_of_100, presence: true

  validate :outflow_split_percentage_keys
  validate :outflow_split_percentage_total

  before_validation :calculate_outflow_split_percentage,
                    :calculate_emergency_corpus
  before_save :set_emergency_corpus_precision

  private

  def user_profile
    @user_profile ||= user.user_profile
  end

  def valid_user_profile
    return true if user_profile.valid?

    errors.add(:user_profile, "should be created")
  end

  def set_emergency_corpus_precision
    self.emergency_corpus &&= emergency_corpus.round(2)
  end

  def calculate_outflow_split_percentage
    return unless valid_user_profile && outflow_split_percentage.nil?

    debt_investment_of_saving = user_profile.age
    equity_investment_of_saving = 100 - user_profile.age

    self.outflow_split_percentage = {
      emi: 40,
      expense: 30,
      equity_investment: (equity_investment_of_saving * 30) / 100.0,
      debt_investment: (debt_investment_of_saving * 30) / 100.0
    }
  end

  def calculate_emergency_corpus
    return unless valid_user_profile && emergency_corpus.nil?

    self.emergency_corpus = if user_profile.monthly_income.nil?
                              0
                            else
                              user_profile.monthly_income * 6
                            end
  end

  def outflow_split_percentage_keys
    return if outflow_split_percentage.nil?

    return true if (
      outflow_split_percentage.keys.map(&:to_s) -
      Category::SUPER_CATEGORY.keys.reject { |k| k == :income }.map(&:to_s)
    ).empty?

    errors.add(:outflow_split_percentage, "should be subset of super category")
  end

  def outflow_split_percentage_total
    return if outflow_split_percentage.nil?

    outflow_split_percentage.map { |k, v| outflow_split_percentage[k] = v.to_f }
    return unless outflow_split_percentage.values.inject(:+) != 100

    errors.add(:outflow_split_percentage, "should add up to 100")
  end
end
