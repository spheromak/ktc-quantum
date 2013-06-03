## Cookbook Name:: ktc-quantum
## Recipe:: quantum-scheduler-patch
##

include_recipe "osops-utils"

%w{ 1:2013.1-0ubuntu2~cloud0 1:2013.1.1-0ubuntu1~cloud0 }.each do |version|
  if ::Chef::Recipe::Patch.check_package_version("quantum-server",version,node)
    # add /32 subnet support
    template "/usr/share/pyshared/quantum/db/db_base_plugin_v2.py" do
      source "ktc-patches/db_base_plugin_v2.py.#{version}"
      owner "root"
      owner "root"
      mode "0644"
      notifies :restart, resources(:service => "quantum-server"), :immediately
    end

    template "/usr/share/pyshared/quantum/db/securitygroups_db.py" do
      source "ktc-patches/securitygroups_db.py.#{version}"
      owner "root"
      owner "root"
      mode "0644"
      notifies :restart, resources(:service => "quantum-server"), :immediately
    end
  end

  if ::Chef::Recipe::Patch.check_package_version("quantum-l3-agent",version,node)
    template "/usr/share/pyshared/quantum/agent/l3_agent.py" do
      source "ktc-patches/l3_agent.py.#{version}"
      owner "root"
      owner "root"
      mode "0644"
      notifies :restart, resources(:service => "quantum-l3-agent"), :immediately
    end
  end
end
