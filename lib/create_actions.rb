module CreateActions
  class Common

  	def self.validate_date(trips)
  		valid_data = true
	  	message = nil
  		trips.each_with_index do |data,index|
	  		user_overlap_check = false
	  		vehicle_overlap_check = false
	  		start_time = data["start_time"]
	  		end_time = data["end_time"].present? ? data["end_time"] : Time.current.to_s
	  		
	  		if data["user_id"].present? && data["vehicle_id"].present? && start_time.present? 
	  			user = User.find_by_id(data["user_id"])
	  			vehicle = Vehicle.find_by_id(data["vehicle_id"])
	  		
	  			# check user, vehicle register by company
	  			company_registered = company_registered(user,vehicle)
	  			unless company_registered
	  				valid_data = false
	  				message = "User/Vehicle not register by company"
	  				break
	  			end

	  			# check user time overlapping
	  			duplicate_user = trips.select { |attachment| attachment["user_id"] == data["user_id"] }
	  			if duplicate_user.count > 1
	  				user_overlap_check = overlapping_user_time(duplicate_user - [data],start_time,end_time,user.id)
	  			end

	  			if user_overlap_check == true
	  				valid_data = false
	  				message = "One of the user timings are overlapping"
	  				break
	  			end

	  			# check vehicle time overlapping
	  			duplicate_vehicle = trips.select { |attachment| attachment["vehicle_id"] == data["vehicle_id"] }
	  			if duplicate_vehicle.count > 1 
	  				vehicle_overlap_check = overlapping_vehicle_time(duplicate_vehicle - [data],start_time,end_time,vehicle.id)
	  			end

	  			if vehicle_overlap_check == true
	  				valid_data = false
	  				message = "One of the vehicle timings are overlapping"
	  				break
	  			end
	  		else
	  			valid_data = false
  				message = "Incomplete entry"
  				break
	  		end
	  	end
	  	[valid_data,message]
  	end

  	def self.overlapping_user_time(array,start_time,end_time,user_id)
	  	overlapping_start_time = array.select{|attachment| attachment["start_time"] >= start_time && attachment["start_time"] <= end_time}
	  	overlapping_end_time = array.select{|attachment| attachment["end_time"].to_s >= start_time && attachment["end_time"].t_s <= end_time}
	  	existing_overlapping_start_time = Trip.where(' user_id=? and start_time >=? and start_time <=?',user_id,start_time,end_time)
	  	existing_overlapping_end_time = Trip.where(' user_id=? and end_time >=? and end_time <=?',user_id,start_time,end_time)
	  	
	  	if overlapping_start_time.present? || overlapping_end_time.present? || existing_overlapping_start_time.present? || existing_overlapping_end_time.present?
	  		true
	  	else
	  		false
	  	end
	  end

	  def self.overlapping_vehicle_time(array,start_time,end_time,vehicle_id)
	  	overlapping_start_time = array.select{|attachment| attachment["start_time"] >= start_time && attachment["start_time"] <=end_time}
	  	overlapping_end_time = array.select{|attachment| attachment["end_time"].to_s >= start_time && attachment["end_time"].to_s <= end_time}
	  	existing_overlapping_start_time = Trip.where(' vehicle_id=? and start_time >=? and start_time <=?',vehicle_id,start_time,end_time)
	  	existing_overlapping_end_time = Trip.where(' vehicle_id=? and end_time >=? and end_time <=?',vehicle_id,start_time,end_time)
	  	
	  	if overlapping_start_time.present? || overlapping_end_time.present? || existing_overlapping_start_time.present? || existing_overlapping_end_time.present?
	  		true
	  	else
	  		false
	  	end
	  end

	  def self.company_registered(user,vehicle)
	  	company_registered = true
	  	if !user || user.company.nil?
	  		company_registered = false
	  	end

	  	if !vehicle || vehicle.company.nil?
				company_registered = false
			end

			company_registered
	  end
  end
end