class Feedback
  include Mongoid::Document

  field :content, type: String

  validates :content, presence: true, length: { maximum: 255 }
end
