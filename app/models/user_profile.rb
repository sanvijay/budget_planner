class UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  GENDERS = %w[Male Female Androgyny]
            .map { |gender| [gender.underscore.to_sym, gender] }.to_h

  field :first_name, type: String
  field :last_name, type: String
  field :dob, type: Date
  field :gender, type: String

  embedded_in :user

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :dob, presence: true
  validates :gender, presence: true, inclusion: { in: GENDERS.values }

  validate :dob_to_be_in_past

  private

  def dob_to_be_in_past
    return if dob.nil?
    return true if dob < Date.today

    errors.add(:dob, "should be in past")
  end
end
