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

  private

  def set_value_precision
    self.value = value.round(2)
  end
end
