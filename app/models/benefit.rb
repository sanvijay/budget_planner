class Benefit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :value, type: Float
  field :score_weightage_out_of_100, type: Integer, default: 100

  embedded_in :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :value, presence: true, numericality: { other_than: 0 }
  validates :score_weightage_out_of_100, presence: true

  before_save :set_value_precision

  def categories
    @categories ||= user.categories.where(benefit_id: id)
  end

  private

  def set_value_precision
    self.value &&= value.round(2)
  end
end
