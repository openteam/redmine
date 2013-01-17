# encoding: utf-8

Rake::TaskManager.record_task_metadata = true

namespace :openteam do
  desc "Получение почты из Gmail и создание новых задач"
  task :import_emails => :environment do
    puts task.comment

    user = Settings['gmail']['user']
    pass = Settings['gmail']['password']

    projects = Project.all
    pb = ProgressBar.new(projects.size)

    imap_options = {
      :host => 'imap.gmail.com',
      :port => '993',
      :ssl => true,
      :username => user,
      :password => pass
    }

    issue_options = {
        :status => 1,
        :tracker => 'Поддержка',
        :category => 1,
        :priority => 1
    }

    options = {
      :no_permission_check => 1
    }

    projects.each do |project|
      next if project.email.blank?
      project_options = issue_options.merge(:project => project.identifier)
      Redmine::IMAP.check(
        imap_options.merge(:folder => project.identifier),
        options.merge(:issue => project_options)
      )
      pb.increment!
      Rails.logger.info("Try import issues to project #{project.identifier} at #{Time.zone.now}")
    end

  end
end
