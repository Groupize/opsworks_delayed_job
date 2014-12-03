Chef::Log.info('RUNNING DELAYED_JOB::SERVICE')

service "monit" do
  supports :status => false, :restart => true, :reload => true
  action :nothing
end


node[:deploy].each do |application, deploy|

  # Overwrite the unicorn restart command declared elsewhere
  # Apologies for the `sleep`, but monit errors with "Other action already in progress" on some boots.
  execute "restart Rails app #{application}" do
    Chef::Log.info("sleep 300 && #{node[:delayed_job][application][:restart_command]}")
    command "sleep 300 && #{node[:delayed_job][application][:restart_command]}"
    action :nothing
  end

end
