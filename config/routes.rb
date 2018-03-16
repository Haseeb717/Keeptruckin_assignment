Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
  	namespace :trips do
    	get 'index'
    	post 'create'
    	get 'distance_covered'
    end
  end
end
