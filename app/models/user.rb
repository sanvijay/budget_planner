class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :email, type: String

  embeds_many :goals
  embeds_many :assets
  embeds_many :categories
  has_many :monthly_budgets

  # Validation for email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  before_save :downcase_email

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end
end
