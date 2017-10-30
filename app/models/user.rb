class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work
  has_many :works, dependent: :destroy

  validates :username, uniqueness: true, presence: true
end
