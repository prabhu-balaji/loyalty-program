# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
Reward.find_or_create_by(name: "coffee")
Reward.find_or_create_by(name: "movie_ticket")
Reward.find_or_create_by(name: "five_percent_cash_rebate") # Hardcoding now. This should be a client configuration when accepting to create reward programs via API
