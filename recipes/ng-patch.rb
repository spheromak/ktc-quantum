## Cookbook Name:: ktc-quantum
## Recipe:: quantum-scheduler-patch
##

include_recipe "osops-utils"

%w{ 1:2013.1-0ubuntu2~cloud0}.each do |version|
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
end
