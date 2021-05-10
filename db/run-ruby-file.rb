# run this with "rails runner db/run-ruby-file.rb"
# or with docker:
# docker-compose run --rm web bundle exec rails runner db/run-ruby-file.rb
puts "hello world"

def send_simple_message
	RestClient.post "https://api:545c75efaa0a4f723f67386dac7cbefe-602cc1bf-dff3f1db"\
		"@api.mailgun.net/v3/sandbox3e8379cde3f94c8d936b25c4f21a492f.mailgun.org/messages",
		:from => "Mailgun Sandbox <postmaster@sandbox3e8379cde3f94c8d936b25c4f21a492f.mailgun.org>",
		:to => "Jeff Korenstein <j.korenstein@gmail.com>",
		:subject => "Hello Jeff Korenstein",
		:text => "Congratulations Jeff Korenstein, you just sent an email with Mailgun!  You are truly awesome!"

# You can see a record of this email in your logs: https://app.mailgun.com/app/logs.

# You can send up to 300 emails/day from this sandbox server.
# Next, you should add your own domain so you can send 10000 emails/month for free.
