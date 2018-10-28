lock '>=3.6.0'

# general setup
set :application, 'website'
set :repo_url, 'git@github.com:Jalle19/website.git'
set :deploy_to, '/home/ubuntu/website'
set :branch, ENV["REVISION"] || ENV["BRANCH"] || "master"

set :scm, :git

# logging
set :log_level, :info
set :keep_releases, 5

namespace :website do
	desc "Build neggefi"
	task :build do
		on roles(:all) do
			within File.join(fetch(:release_path), 'neggefi') do
				execute :hugo
			end
		end
	end
end

namespace :deploy do
	after :updated, "website:build"
end
