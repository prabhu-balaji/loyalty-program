# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
Reward.find_or_create_by(name: Constants::REWARDS_MAPPING[:coffee])
Reward.find_or_create_by(name: Constants::REWARDS_MAPPING[:movie_ticket])
Reward.find_or_create_by(name: Constants::REWARDS_MAPPING[:cash_rebate]) # Hard coding now. This should be a client configuration when accepting to create reward programs via API
Reward.find_or_create_by(name: Constants::REWARDS_MAPPING[:lounge_access])
