class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :planned_before, type: Boolean
  field :score, type: Integer

  validates :name, presence: true, length: { maximum: 50 }
end
