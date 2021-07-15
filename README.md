# Adopt-a-Drain

[![Join the chat at https://gitter.im/sfbrigade/adopt-a-drain](https://badges.gitter.im/sfbrigade/adopt-a-drain.svg)](https://gitter.im/sfbrigade/adopt-a-drain?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](http://img.shields.io/travis/sfbrigade/adopt-a-drain.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/sfbrigade/adopt-a-drain.svg)][gemnasium]
[![Coverage Status](http://img.shields.io/coveralls/sfbrigade/adopt-a-drain.svg)][coveralls]

[travis]: http://travis-ci.org/sfbrigade/adopt-a-drain
[gemnasium]: https://gemnasium.com/sfbrigade/adopt-a-drain
[coveralls]: https://coveralls.io/r/sfbrigade/adopt-a-drain

Claim responsibility for cleaning out a storm drain after it rains.

## Screenshot
![Adopt-a-Drain](/adopt.png "Adopt-a-Drain")

## Demo
You can see a running version of the application at
[http://adopt-a-drain.herokuapp.com/][demo].

[demo]: http://adopt-a-drain.herokuapp.com/

## Installation
This application requires [Postgres](http://www.postgresql.org/) to be installed

    git clone git://github.com/sfbrigade/adopt-a-drain.git
    cd adopt-a-drain
    bundle install

    bundle exec rake db:create
    bundle exec rake db:schema:load

See the [wiki](https://github.com/sfbrigade/adopt-a-drain/wiki/Windows-Development-Environment) for a guide on how to install this application on Windows.

## Docker

To setup a local development environment with
[Docker](https://docs.docker.com/engine/installation/).   

```
# Override database settings as the docker host:
echo DB_HOST=db > .env
echo DB_USER=postgres >> .env
```
## Medford updates
```
# Medford update 1
edit Dockerfile to reflect ruby 2.6.3

# Medford update 2 - Update mimemagic
bundle update mimemagic 

# Medford update 3 - add user information to .env file
USER=theuser
POSTGRES_PASSWORD=thepassword

# Medford update 4 - Update database.yml
development:
  adapter: postgresql
  encoding: unicode
  database: adopt_a_thing_development
  pool: 5
  username: postgres
  password: <%= ENV['POSTGRES_PASSWORD'] %>
  
test:
  adapter: postgresql
  encoding: unicode
  database: adopt_a_thing_test
  pool: 5
  username: postgres
  password: <%= ENV['POSTGRES_PASSWORD'] %>

medford update #5: 
adjust docker-compose.yml
    environment:
      PGDATABASE: adopt_a_thing_development
      PGUSER: postgres
      PGHOST: db
  
added to Dockerfile: (copied from Savannah implementation)
    EXPOSE 3000
    COPY . /myapp
    ARG BUNDLE_INSTALL_ARGS
    ARG RAILS_ENV=development
    RUN bundle install ${BUNDLE_INSTALL_ARGS}
    RUN if [ "$RAILS_ENV" = "production" ]; then SECRET_TOKEN=$(rake secret) bundle exec rake assets:precompile; fi
    CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

medford update #6
    Docker has changed since this repo was built.  Docker has added additional security requirements.
    Add the postgres password to the .env file, and then add these lines to docker config files.
    see - https://stackoverflow.com/questions/60368999/why-wont-my-docker-postgresql-container-run-anymore

    docker-compose.yml:
        db:
            image: postgres
            environment: 
            - POSTGRES_PASSWORD=<%= ENV['POSTGRES_PASSWORD'] %>
    database.yml:
        (to both development: and test:)
            username: postgres
            password: <%= ENV['POSTGRES_PASSWORD'] %>
    
```
## Docker (continued)
```
# Setup your docker based postgres database:
docker-compose run --rm web bundle exec rake db:setup

medford note 13:
need to create a csv file similar to Savannah's savannah_drains.csv to use Savannah's data.rake

medford note 14: 
replace data.rake with Savannah's - based on advice from San Francisco implementation: 
    # class for importing things from CSV datasource is currently very specific to drains from DataSF 
change Savannah's data.rake to reflect medford.csv of drains

medford note 15:
for binding.pry to work: https://gist.github.com/briankung/ebfb567d149209d2d308576a6a34e5d8
    First, add pry-rails to your Gemfile: gem 'pry-rails', group: :development
    Second, rebuild your Docker container to install the gems: docker-compose build

# Load data:
docker-compose run --rm web bundle exec rake data:load_drains
    medford note 15: then restart server (docker-compose up)
    
# OR: don't load all that data, and load the seed data:
# docker-compose run --rm web bundle exec rake db:seed

medford note 16:
 Adjust initialLocation in ./app/assets/javascripts/main.js.rb. 

 medford note 17:
 whenever loading new assets, such as .png files, always pre-compile assets (see step 3 below)., then add, commit and push to heroku.

# Start the web server:
docker-compose build 
docker-compose up

# Visit your website http://localhost:3000 (or the IP of your docker-machine)
```

## Usage
    rails server 
    medford note: don't do this, do "docker-compose up" instead.

## Seed Data
    bundle exec rake data:load_things

## Deploying to Heroku
A successful deployment to Heroku requires a few setup steps:

medford note:
```
    heroku login
    heroku git:remote -a `app-name`
    heroku stack:set heroku-18
```
1. Generate a new secret token:

    ```
    rake secret
    ```

2. Set the token on Heroku:

    ```
    heroku config:set SECRET_TOKEN=the_token_you_generated
    ``` 

3. [Precompile your assets](https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar)

    ```
    medford note #7: before precompile: export GOOGLE_GEOCODER_API_KEY=(key)
    ```
    RAILS_ENV=production bundle exec rake assets:precompile

    git add public/assets

    git commit -m "vendor compiled assets"

4. Add a production database to config/database.yml

    medford note #8: 
    ```
    git push heroku master 
    ```

5. Seed the production db:

    medford note:
    ```
    heroku config:set GOOGLE_MAPS_KEY=your_maps_api_key
    heroku config:set GOOGLE_MAPS_JAVASCRIPT_API_KEY=your_maps_api_key
    heroku config:set GOOGLE_GEOCODER_API_KEY=your_maps_api_key
    heroku config:set USER=jeffkorenstein
    heroku config:set POSTGRES_PASSWORD=your_postgres_password

    heroku rake db:create  (unless already created)
    heroku rake db:migrate

    for sample data:
        heroku rake db:seed
    for real data:
        heroku rake data:load_drains
    ```

Keep in mind that the Heroku free Postgres plan only allows up to 10,000 rows,
so if your city has more than 10,000 fire drains (or other thing to be
adopted), you will need to upgrade to the $9/month plan.

medford note: #9
### Google Maps API Service  (from Adopt-A-Drain Savannah)
You will need to apply for a Google Maps Javascript API key in order to remove the "Development Only" watermark on maps. 
After you have obtained the key, you will need to set it as environment variables.

    heroku config:set GOOGLE_MAPS_KEY=your_maps_api_key
    heroku config:set GOOGLE_MAPS_JAVASCRIPT_API_KEY=your_maps_api_key
    heroku config:set GOOGLE_GEOCODER_API_KEY=your_maps_api_key

medford note: #10
for dev box to work, need to update .env file to include:
GOOGLE_MAPS_JAVASCRIPT_API_KEY=(your key)
SECRET_KEY_BASE=(your key)

medford note: #11
need to update secrets.yml file as:
development:
  google_maps_javascript_api_key: <%= ENV["GOOGLE_MAPS_JAVASCRIPT_API_KEY"] %>
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

test:
  google_maps_javascript_api_key: <%= ENV["GOOGLE_MAPS_JAVASCRIPT_API_KEY"] %>
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>


### Google Analytics
If you have a Google Analytics account you want to use to track visits to your
deployment of this app, just set your ID and your domain name as environment
variables:

    heroku config:set GOOGLE_ANALYTICS_ID=your_id
    heroku config:set GOOGLE_ANALYTICS_DOMAIN=your_domain_name

An example ID is `UA-12345678-9`, and an example domain is `adoptadrain.org`.

## Contributing
In the spirit of [free software][free-sw], **everyone** is encouraged to help
improve this project.

[free-sw]: http://www.fsf.org/licensing/essays/free-sw.html

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by [translating to a new language][locales]
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up
  inconsistent whitespace)
* by refactoring code
* by closing [issues][]
* by reviewing patches
* [financially][]

[locales]: https://github.com/sfbrigade/adopt-a-drain/tree/master/config/locales
[issues]: https://github.com/sfbrigade/adopt-a-drain/issues
[financially]: https://secure.sfbrigade.org/page/contribute

## Submitting an Issue
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. When submitting a bug report, please include a [Gist][]
that includes a stack trace and any details that may be necessary to reproduce
the bug, including your gem version, Ruby version, and operating system.
Ideally, a bug report should include a pull request with failing specs.

[gist]: https://gist.github.com/

## Submitting a Pull Request
1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Add specs for your unimplemented feature or bug fix.
4. Run `bundle exec rake test`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `bundle exec rake test`. If your specs fail, return to step 5.
7. Run `open coverage/index.html`. If your changes are not completely covered
   by your tests, return to step 3.
8. Add, commit, and push your changes.
9. [Submit a pull request.][pr]

[fork]: http://help.github.com/fork-a-repo/
[branch]: https://guides.github.com/introduction/flow/
[pr]: http://help.github.com/send-pull-requests/

## Supported Ruby Version
This library aims to support and is [tested against][travis] Ruby version 2.2.2.

If something doesn't work on this version, it should be considered a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the version above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## Copyright
Copyright (c) 2015 Code for San Francisco. See [LICENSE.md](https://github.com/sfbrigade/adopt-a-drain/blob/master/LICENSE.md) for details.

[license]: https://github.com/sfbrigade/adopt-a-drain/blob/master/LICENSE.md 
