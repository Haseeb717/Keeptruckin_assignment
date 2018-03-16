module Api
	class TripsController < ApplicationController

		#skip_before_filter :verify_authenticity_token
		before_action :set_user, :only => [:index,:distance_covered]
		before_action :set_admin, :only => [:create]
		
		swagger_controller :trips, 'Trips'

    swagger_api :index do
	    summary "List Trips"
	    param :header, :id, :string, :required, "ID"
	    param :query, :user_id, :integer, :required, "User Id"
	    param :query, :vehicle_id, :integer, :required, "Vehicle Id"
	    param :query, :start_time, :string, :required, "Start Time"
	    param :query, :end_time, :string, :optional, "End Time"
	  end

	  swagger_api :create do
	    summary "Create Trip"
	    param :header, :id, :string, :required, "ID"
	    param :body, :trip, :string, :required, "Trips",:defaultValue=>'[{"user_id": 1,"vehicle_id": 1,"start_time": "2018-09-15","end_time": "2018-09-17"},{"user_id": 1,"vehicle_id": 1,"start_time": "2017-09-15","end_time": "2017-10-19"}]'
	  end

	  swagger_api :distance_covered do
	  	summary "Distance Covered"
	    param :header, :id, :string, :required, "ID"
	    param :query, :user_id, :integer, :required, "User Id"
	    param :query, :vehicle_id, :integer, :required, "Vehicle Id"
	    param :query, :start_time, :string, :required, "Start Time"
	    param :query, :end_time, :string, :optional, "End Time"
	  end

	  def index
	  	query = Hash.new
	  	query[:user_id] = params["user_id"] if query["user_id"]
	  	query[:vehicle] = params["vehicle_id"] if query["vehicle_id"]
	  	start_time = params["start_time"] if query["start_time"]
	    end_time = params["end_time"] if query["end_time"]

	  	trips = Trip.created_between(start_time,end_time).where(query)
	  	render json: ({trips:trips}), :status=>201
	  end

	  def create
	  	trips = params["_json"].as_json

	  	valid_data = CreateActions::Common.validate_date(trips)
	  	if(valid_data[0])
	  		Trip.create(trips)
	  		render json: ({trips:trips}), :status=>201
	  	else
	  		render json: ({message:valid_data[1]}), :status=>400
	  	end
	  end

	  def distance_covered
	  	query = Hash.new
	  	query[:user_id] = params["user_id"] if query["user_id"]
	  	query[:vehicle] = params["vehicle_id"] if query["vehicle_id"]
	  	start_time = params["start_time"] if query["start_time"]
	    end_time = params["end_time"] if query["end_time"]
	  
	  	trips = Trip.created_between(start_time,end_time).where(query).pluck(:distance_covered)
	  	render json: ({trips:trips.compact.sum}), :status=>201
	  end

	  private
	  	def set_user
				if request.headers['id'].present?
					id = request.headers['id'].to_i
					@user = User.find_by_id(id)
		      unless @user 
		      	render json: {:success=>false, :message=>"User not found"}, :status=>404
		      end
		    else
		    	render json: {:success=>false, :message=>"Invalid request"}, :status=>401
		    end
	    end

		  def set_admin
				if request.headers['id'].present?
					id = request.headers['id'].to_i
					@user = User.find_by_id(id)
		      if @user
		      	if !@user.is_admin 
		      		render json: {:success=>false, :message=>"Access not allowed"}, :status=>401
		      	end
		      else # user id not found
		      	render json: {:success=>false, :message=>"User not found"}, :status=>404
		      end
		    else
		    	render json: {:success=>false, :message=>"Invalid request"}, :status=>401
		    end
	    end
	end
end