## Cookbook Name:: ktc-quantum
## Recipe:: quantum-scheduler-patch
##

include_recipe "osops-utils"

# add /32 subnet support
%w{ 2012.2.1-0ubuntu1~cloud0 2012.2.3-0ubuntu2~cloud0 }.each do |version|
  if ::Chef::Recipe::Patch.check_package_version("quantum-server",version,node)
    template "/usr/share/pyshared/quantum/db/db_base_plugin_v2.py" do
      source "ktc-patches/db_base_plugin_v2.py.#{version}"
      owner "root"
      owner "root"
      mode "0644"
      notifies :restart, resources(:service => "quantum-server"), :immediately
    end
  end
end

