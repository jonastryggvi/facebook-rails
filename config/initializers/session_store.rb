# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_facebook-rails_session',
  :secret      => '41dc8ae87be29426fee3d4265b3cadd902adc726503af20a2e7a0d0e388b51b6e8808237a83660450ea9dade56643dd9869908adcdf3654f5f2357a9509ecb76'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
