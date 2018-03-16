class User < ApplicationRecord
  belongs_to :company
  has_many :trips
end
