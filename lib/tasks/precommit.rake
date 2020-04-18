if Rails.env.development? || Rails.env.test?
  require 'rainbow'

  namespace :precommit do
    desc "precommit checks to make sure it's okay to push"
    task check: :environment do
      system("bundle exec rspec")

      system("bundle exec bundle-audit")
      Rake::Task["brakeman:run"].invoke
      system("bundle exec rubocop")
    end
  end

  task precommit: ["precommit:check"]
end
