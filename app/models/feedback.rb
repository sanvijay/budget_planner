class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String

  validates :content, presence: true, length: { maximum: 255 }
end
