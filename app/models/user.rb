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
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :sign_up_provider,   type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # Only if lock strategy is :failed_attempts
  # field :failed_attempts, type: Integer, default: 0
  # Only if unlock strategy is :email or :both
  # field :unlock_token,    type: String
  # field :locked_at,       type: Time

  embeds_one :user_profile, autobuild: true
  embeds_one :custom_rule, autobuild: true
  embeds_many :goals
  embeds_many :assets
  embeds_many :categories
  embeds_many :benefits
  has_many :monthly_budgets, dependent: :destroy

  # Validation for email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  before_save :downcase_email

  def self.primary_key
    "_id"
  end

  def enabled?
    !user_profile.new_record?
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end
