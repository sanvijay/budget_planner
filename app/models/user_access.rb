class UserAccess
  include Mongoid::Document
  include Mongoid::Timestamps

  MIN__REFERRAL_COUNT_FOR_SUCCESSFUL_PLUS_ACCOUNT = 3
  SUPPORTED_MODELS = {
    free: {
      goals: 3,
      categories: 15,
      assets: 3,
      loans: 3,
      benefits: 3,
      plan_upto_in_years: 2
    },
    plus: {
      goals: 5,
      categories: 25,
      assets: 5,
      loans: 5,
      benefits: 5,
      plan_upto_in_years: 7
    },
    prime: {
      goals: 50,
      categories: 250,
      assets: 100,
      loans: 100,
      benefits: 100
    }
  }.freeze

  field :model,            type: Symbol, default: :free
  field :model_updated_at, type: Date

  field :referred_by,      type: BSON::ObjectId
  field :referred_users,   type: Array, default: []
  field :referring_token,  type: String, default: nil

  embedded_in :user

  validate :allowed_model
  validate :allowed_referred_by_user
  validate :allowed_referred_users

  before_save :generate_referring_token

  def claim_plus_access!
    return unless claim_plus_access?

    self.model = :plus
    self.model_updated_at = Time.zone.today
    save!
  end

  def referred_by_user
    User.find(referred_by)
  end

  protected

  def generate_referring_token
    self.referring_token = SecureRandom.hex(3) if referring_token.nil?
  end

  def completed_referral?
    user.phone_verified?
  end

  private

  def allowed_model
    return if SUPPORTED_MODELS.keys.include?(model)

    errors.add(:model, "is not allowed model")
  end

  def allowed_referred_by_user
    return if referred_by.nil?
    return unless referred_by_user.nil?

    errors.add(:referred_by, "is unknown user")
  end

  def allowed_referred_users
    return if referred_users.empty?

    return unless referred_users.any? do |r|
      r.nil? || User.find(r).nil?
    end

    errors.add(:referred_users, "are not allowed")
  end

  def claim_plus_access?
    referred_users.select do |r|
      User.find(r).user_access.completed_referral?
    end.count >= MIN__REFERRAL_COUNT_FOR_SUCCESSFUL_PLUS_ACCOUNT
  end
end
