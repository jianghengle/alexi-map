# README

This is a Ruby on Rails (rails_admin https://github.com/sferik/rails_admin) application to do the database migrations and management.

## installation
1. install rvm: https://rvm.io/
2. `rvm install ruby 2.3.3`
3. if no bundle, `gem install bundler`
4. `bundle install`
5. `rake db:create`
6. `rake db:migrate`
7. `rails c`
8. create a user: `User.create(email: 'your@email.com', password: 'yourpassword', role: 'Admin')`
9. `exit`
10. `rails s -p 3001`

