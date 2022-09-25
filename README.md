# Loyalty Program API Platform
 The platform offers clients the ability to issue loyalty points and rewards to their end users.

Product Requirements - https://github.com/PerxTech/backend-interview

Postman API collection - https://documenter.getpostman.com/view/11290012/2s83S6eBYC

Tech design - https://curious-birth-fc5.notion.site/Design-for-Loyalty-program-app-71dda24155fc47999bc3238864d46b3b

Trello board - https://trello.com/b/KvivLq54/loyalty-program-app

## Running the app

Prerequisite: ruby 2.7.6, MySQL >= 5.x
<br>You can install ruby via rvm or rbenv

App runs on rails 6.0.6.

### Running rails server
1. Go to root directory of the app 
2. Run `bundle install`
3. Run `rake db:setup` to create db, run migrations, seeds.
4. Run `rails s`


### Running sidekiq for background jobs
1. Install redis-server

    via homebrew - `brew install redis` <br>
    manual download link - https://redis.io/download/
2. Run `sidekiq` 


Rspec code coverage: 98.57 %
<br><br>
<img width="1500" alt="image" src="https://user-images.githubusercontent.com/35253370/192169319-71046fca-b7b0-4ded-90f9-ae842d44c6c3.png">


