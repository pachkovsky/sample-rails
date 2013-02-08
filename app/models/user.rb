class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name

  validates :first_name, :last_name, :email, presence: true

  def full_name
    [self.first_name, self.last_name].reject(&:blank?).join(' ')
  end
end
