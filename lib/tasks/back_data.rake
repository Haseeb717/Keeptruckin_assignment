desc 'Backup 6 month old data'
task :backup_trip do
  # Store old posts in a `posts` array
  end_date = Time.current - 6.months
  start_date = Time.current - 6.months - 1.week

  trips = Trip.created_between(start_date,end_date)
  trips = trip.as_json

  # connect with backup database
  ActiveRecord::Base.establish_connection('my_backup_db')
  TripBackup.create(trips)

end
