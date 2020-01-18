if Rails.env.development? || Rails.env.test?
  require 'rainbow'

  namespace :precommit do
    desc "print coverage percent"
    task :coverage_percent do
      coverage_dir = "#{Rails.root}/coverage"
      json = File.read("#{coverage_dir}/.last_run.json")
      percent = JSON.parse(json)["result"]["covered_percent"]

      color = percent == 100 ? :green : :red
      puts Rainbow("The coverage is #{percent}%.").public_send(color)
      puts "Check results in #{coverage_dir}/index.html\n\n" if percent != 100
    end

    desc "precommit checks to make sure it's okay to push"
    task :check do
      system({ "COVERAGE" => "on" }, "bundle exec rspec")
      Rake::Task["precommit:coverage_percent"].invoke

      system("bundle exec bundle-audit")
      Rake::Task["brakeman:run"].invoke
      system("bundle exec rubocop")
    end
  end

  task precommit: ["precommit:check"]
end
