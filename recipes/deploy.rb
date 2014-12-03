# Adapted from deploy::rails: https://github.com/aws/opsworks-cookbooks/blob/master/deploy/recipes/rails.rb

include_recipe 'deploy'

Chef::Log.info('RUNNING DELAYED_JOB::DEPLOY')

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.info("Skipping opsworks_delayed_job::deploy application #{application} as it is not an Rails app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  include_recipe "opsworks_delayed_job::setup"

  template "#{deploy[:deploy_to]}/shared/config/memcached.yml" do
    cookbook "rails"
    source "memcached.yml.erb"
    mode 0660
    owner deploy[:user]
    group deploy[:group]
    variables(:memcached => (deploy[:memcached] || {}), :environment => deploy[:rails_env])
  end

  Chef::Log.info('DELAYED_JOB RESTART COMMAND')
  Chef::Log.info(node[:delayed_job][application][:restart_command])
  node.set[:opsworks][:rails_stack][:restart_command] = node[:delayed_job][application][:restart_command]

  opsworks_deploy do
    Chef::Log.info('INSIDE "opsworks_deploy"')
    deploy_data deploy
    app application
  end
end
