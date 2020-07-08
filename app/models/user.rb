class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :recoverable,
         :rememberable, :validatable, :trackable, :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  ## Database authenticatable
  field :email,                  type: String, default: ""
  field :encrypted_password,     type: String, default: ""
  field :sign_up_provider,       type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at,  type: Time

  ## Trackable
  field :sign_in_count,        type: Integer, default: 0
  field :current_sign_in_at,   type: Time
  field :last_sign_in_at,      type: Time
  field :current_sign_in_ip,   type: String
  field :last_sign_in_ip,      type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  field :phone_number,         type: String
  field :phone_pin,            type: String
  field :phone_verified,       type: Boolean, default: false
  field :phone_verified_on,    type: Time

  field :referring_token, type: String, default: nil

  ## Lockable
  # Only if lock strategy is :failed_attempts
  # field :failed_attempts, type: Integer, default: 0
  # Only if unlock strategy is :email or :both
  # field :unlock_token,    type: String
  # field :locked_at,       type: Time

  embeds_one :user_profile, autobuild: true
  embeds_one :user_access,  autobuild: true
  embeds_many :goals
  embeds_many :loans
  embeds_many :assets
  embeds_many :categories
  embeds_many :benefits
  embeds_many :accounts

  has_many :monthly_budgets, dependent: :destroy

  # Validation for email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :phone_number, uniqueness: { allow_blank: true }
  validates :referring_token, presence: true,
                              uniqueness: { case_sensitive: true }

  before_validation :generate_referring_token
  before_save :downcase_email

  def self.primary_key
    "_id"
  end

  def enabled?
    !user_profile.new_record?
  end

  def user_plan
    UserAccess::SUPPORTED_PLANS[user_access.plan]
  end

  def verify_phone(entered_pin)
    return false unless phone_pin == entered_pin

    self.phone_verified = true
    self.phone_pin = nil
    self.phone_verified_on = Time.zone.now

    save!
    true
  end

  def generate_and_send_phone_pin!
    return unless phone_number

    self.phone_pin = rand(0..999_999).to_s.rjust(6, "0")
    save!

    send_phone_pin(phone_pin)
  end

  private

  def send_phone_pin(pin)
    return unless phone_number

    TwilioClient.new.send_text(phone_number, "Your PIN is #{pin}. " \
                                    "Use this to verify your number. - finsey.")
  end

  def generate_referring_token
    self.referring_token = SecureRandom.hex(4) if referring_token.nil?
  end

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end
