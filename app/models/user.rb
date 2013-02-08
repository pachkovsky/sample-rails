class User
  include Mongoid::Document
  attr_accessible :email, :first_name, :last_name

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String

  validates :first_name, :last_name, :email, presence: true

  def full_name
    [self.first_name, self.last_name].reject(&:blank?).join(' ')
  end
end
