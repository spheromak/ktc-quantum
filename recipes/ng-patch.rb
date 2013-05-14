## Cookbook Name:: ktc-quantum
## Recipe:: quantum-scheduler-patch
##

include_recipe "osops-utils"

# add /32 subnet support
template "/usr/share/pyshared/quantum/db/db_base_plugin_v2.py" do
  source "ktc-patches/db_base_plugin_v2.py.python-quantum"
  owner "root"
  owner "root"
  mode "0644"
  notifies :restart, resources(:service => "quantum-server"), :immediately
  only_if { ::Chef::Recipe::Patch.check_package_version("quantum-server","2013.1-0ubuntu2~cloud0",node) }
end
