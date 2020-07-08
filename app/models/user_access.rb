class UserAccess
  include Mongoid::Document
  include Mongoid::Timestamps

  MIN_REFERRAL_COUNT_FOR_PLUS_PLAN = 3
  SUPPORTED_PLANS = {
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

  field :plan,            type: Symbol, default: :free
  field :plan_updated_at, type: Date

  field :referred_by,      type: BSON::ObjectId
  field :referred_users,   type: Array, default: []

  embedded_in :user

  validates :plan, inclusion: { in: SUPPORTED_PLANS.keys }

  validate :allowed_referred_by_user
  validate :allowed_referred_users

  before_save :remove_duplicate_referred_users

  def claim_plus_access!
    return false unless claim_plus_access?

    self.plan = :plus
    self.plan_updated_at = Time.zone.today
    save!
  end

  def referred_by_user
    referred_by && User.find(referred_by)
  end

  def referred_by_code!(code)
    lreferred_by_user = User.find_by(referring_token: code)
    return false unless lreferred_by_user
    return false if invalid_referral_user?(lreferred_by_user)

    self.referred_by = lreferred_by_user.to_param unless referred_by
    save!

    luser_access = lreferred_by_user.user_access
    luser_access.referred_users << user.to_param
    luser_access.save!
  end

  def completed_referred_users
    referred_users.select do |r|
      User.find(r).user_access.completed_referral?
    end
  end

  protected

  def completed_referral?
    user.phone_verified?
  end

  private

  def remove_duplicate_referred_users
    self.referred_users = referred_users.uniq
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
    completed_referral? &&
      completed_referred_users.count >= MIN_REFERRAL_COUNT_FOR_PLUS_PLAN
  end

  def invalid_referral_user?(ruser)
    ruser.to_param == user.to_param ||
      ruser.user_access.referred_by.to_param == user.to_param
  end
end
