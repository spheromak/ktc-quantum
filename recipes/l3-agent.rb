#
## Cookbook Name:: ktc-quantum
## Recipe:: l3 agent
##

include_recipe "osops-utils"

if Chef::Config[:solo]
	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
end

if not node["package_component"].nil?
    release = node["package_component"]
else
    release = "folsom"
end

platform_options = node["quantum"]["platform"][release]
plugin = node["quantum"]["plugin"]

platform_options["quantum_l3_packages"].each do |pkg|
    package pkg do
        action :upgrade
	options platform_options["package_overrides"]
    end
end

service "quantum-l3-agent" do
    service_name platform_options["quantum_l3_agent"]
    supports :status => true, :restart => true
    action :nothing
end

ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")
metadata_ip = get_ip_for_net("nova", search(:node, "recipes:nova\\:\\:api-metadata AND chef_environment:#{node.chef_environment}")[0])

# To get quantum service_pass from quantum server.
quantum_info = get_settings_by_recipe("nova-network\\:\\:nova-controller", "quantum")

template "/etc/quantum/l3_agent.ini" do
    source "#{release}/l3_agent.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
	    "quantum_external_bridge" => node["quantum"][plugin]["external_bridge"],
	    "nova_metadata_ip" => metadata_ip,
	    "service_pass" => quantum_info["service_pass"],
	    "service_user" => node["quantum"]["service_user"],
	    "service_tenant_name" => node["quantum"]["service_tenant_name"],
            "keystone_protocol" => ks_admin_endpoint["scheme"],
	    "keystone_api_ipaddress" => ks_admin_endpoint["host"],
	    "keystone_admin_port" => ks_admin_endpoint["port"],
	    "keystone_path" => ks_admin_endpoint["path"],
	    "quantum_debug" => node["quantum"]["debug"],
	    "quantum_verbose" => node["quantum"]["verbose"],
	    "quantum_namespace" => node["quantum"]["use_namespaces"],
	    "quantum_plugin" => node["quantum"]["plugin"]
    )
    notifies :restart, resources(:service => "quantum-l3-agent"), :immediately
    notifies :enable, resources(:service => "quantum-l3-agent"), :immediately
end
