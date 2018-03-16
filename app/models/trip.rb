class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle

  scope :start_after, ->(start_time) do
	  where("start_time > ?", start_time)
	end

	scope :start_before, ->(end_time) do
	  where("end_time < ? OR end_time IS NULL", end_time)
	end

	scope :empty_end_time, -> { where("end_time IS NULL") }

	scope :created_between, ->(start_time, end_time) do
	  query = self.all
	  query = query.start_after(start_time) if start_time
	  query = query.start_before(end_time)  if end_time
	  query = query.empty_end_time unless end_time
	  query
	end

end
