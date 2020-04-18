if Rails.env.development? || Rails.env.test?
  namespace :brakeman do
    desc "Run Brakeman"
    task :run, [:output_files] => :environment do |_t, args|
      require 'brakeman'

      files = args[:output_files].split(' ') if args[:output_files]
      Brakeman.run app_path: ".", output_files: files,
                   print_report: true, exit_on_warn: true
    end
  end
end
