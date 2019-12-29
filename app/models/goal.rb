class Goal
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :description, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :target, type: Float
  field :completed, type: Boolean

  embedded_in :user

  validates :description, presence: true, length: { maximum: 255 }
  validates :target, presence: true, numericality: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :end_date_cannot_be_in_past_of_start_date

  before_save :set_target_precision

  private

  def set_target_precision
    self.target = target.round(2)
  end

  def end_date_cannot_be_in_past_of_start_date
    return if start_date.blank? || end_date.blank?
    return true if start_date < end_date

    errors.add(:end_date, "can't be in the past of start date")
  end
end
