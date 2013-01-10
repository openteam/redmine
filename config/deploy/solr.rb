settings_yml_path = "config/deploy.yml"
config = YAML::load(File.open(settings_yml_path))

raise "not found deploy key in deploy.yml. see deploy.yml.example" unless config['deploy']
gateway = config['deploy']["gateway"]
raise "not found deploy.gateway key in deploy.yml. see deploy.yml.example" unless gateway
application = config['deploy']["application"]
raise "not found deploy.application key in deploy.yml. see deploy.yml.example" unless application
domain = config['deploy']["domain"]
raise "not found deploy.domain key in deploy.yml. see deploy.yml.example" unless domain
solr_domain = config['deploy']["solr_domain"]
raise "not found deploy.solr_domain key in settings.yml. see settings.yml.example" unless solr_domain

namespace :solr do
  desc "Import solr index files"
  task :import do
    run_locally("rsync -a --delete -e='ssh #{gateway} -A ssh' #{solr_domain}:/srv/solr/data/#{application}/data/ solr/data/development; true")
  end

  desc "Restart Solr server"
  task :restart do
    run_locally("ssh #{gateway} -At ssh #{solr_domain} supervisorctl restart solr")
  end
end
