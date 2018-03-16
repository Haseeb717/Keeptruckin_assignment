class Company < ApplicationRecord
	has_one :user
	has_one :vehicle
end
