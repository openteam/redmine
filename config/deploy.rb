require "bundler/capistrano"
require "rvm/capistrano"

load "config/deploy/settings"

namespace :deploy do
  desc "Copy config files"
  task :config_app, :roles => :app do
    run "ln -s #{deploy_to}/shared/config/configuration.yml #{release_path}/config/configuration.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Precompile assets"
  task :compile_assets, :roles => :app do
    run "cd #{deploy_to}/current && RAILS_ENV=production bin/rake assets:precompile"
  end

  desc "HASK copy right unicorn.rb file"
  task :copy_unicorn_config do
    run "ln -s #{deploy_to}/shared/config/unicorn.rb #{deploy_to}/current/config/unicorn.rb"
    run "ln -s #{deploy_to}/shared/config/secret_token.rb #{deploy_to}/current/config/initializers/secret_token.rb"
    run "ln -s #{deploy_to}/shared/config/gmail.yml #{deploy_to}/current/config/gmail.yml"
  end

  desc "Reload Unicorn"
  task :reload_servers do
    sudo "/etc/init.d/nginx reload"
    sudo "/etc/init.d/#{unicorn_instance_name} restart"
  end

  desc "Update crontab tasks"
  task :crontab do
    run "cd #{deploy_to}/current && exec bundle exec whenever --update-crontab --load-file #{deploy_to}/current/config/schedule.rb"
  end

  desc "Airbrake notify"
  task :airbrake do
    run "cd #{deploy_to}/current && RAILS_ENV=production TO=production bin/rake airbrake:deploy"
  end
end

# deploy
after "deploy:finalize_update", "deploy:config_app"
after "deploy", "deploy:migrate"
after "deploy", "deploy:copy_unicorn_config"
after "deploy", "deploy:reload_servers"
after "deploy:restart", "deploy:cleanup"
after "deploy", "deploy:crontab"
#after "deploy", "deploy:airbrake"

# deploy:rollback
after "deploy:rollback", "deploy:reload_servers"
