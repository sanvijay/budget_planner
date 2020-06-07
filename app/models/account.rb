class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String

  embedded_in :user

  validates :name, presence: true, length: { maximum: 50 }
end
