## Cookbook Name:: ktc-quantum
## Recipe:: lb-plugin
##

include_recipe "osops-utils"

if not node["package_component"].nil?
	    release = node["package_component"]
else
	    release = "grizzly"
end

platform_options = node["quantum"]["platform"][release]
plugin = node["quantum"]["plugin"]

node["quantum"][plugin]["packages"].each do |pkg| 
    package pkg do
        if node["osops"]["do_package_upgrades"]
            action :upgrade
        else
            action :install
        end
        options platform_options["package_overrides"]
    end
end

service "quantum-plugin-linuxbridge-agent" do
    service_name node["quantum"]["lb"]["service_name"]
    supports :status => true, :restart => true
    action :nothing
end

mysql_info = get_access_endpoint("mysql-master", "mysql", "db")
ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")
rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")
api_endpoint = get_bind_endpoint("quantum", "api")

template "/etc/quantum/api-paste.ini" do
    source "#{release}/api-paste.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
        "keystone_api_ipaddress" => ks_admin_endpoint["host"],
        "keystone_admin_port" => ks_admin_endpoint["port"],
        "keystone_protocol" => ks_admin_endpoint["scheme"],
        "service_tenant_name" => node["quantum"]["service_tenant_name"],
        "service_user" => node["quantum"]["service_user"],
        "service_pass" => node["quantum"]["service_pass"]
    )
end

template "/etc/quantum/quantum.conf" do
    source "#{release}/quantum.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
        "quantum_debug" => node["quantum"]["debug"],
        "quantum_verbose" => node["quantum"]["verbose"],
        "quantum_ipaddress" => api_endpoint["host"],
        "quantum_port" => api_endpoint["port"],
        "rabbit_ipaddress" => rabbit_info["host"],
        "rabbit_port" => rabbit_info["port"],
        "overlapping_ips" => node["quantum"]["overlap_ips"],
        "quantum_plugin" => node["quantum"]["plugin"]
    )
end

template "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini" do
    source "#{release}/linuxbridge_conf.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
	    "db_ip_address" => mysql_info["host"],
	    "db_user" => node["quantum"]["db"]["username"],
	    "db_password" => node["quantum"]["db"]["password"],
	    "db_name" => node["quantum"]["db"]["name"],
	    "lb_debug" => node["quantum"]["debug"],
	    "lb_verbose" => node["quantum"]["verbose"],
            "physical_network" => node["quantum"]["lb"]["physical_network"],
            "physical_interface" => node["quantum"]["lb"]["physical_interface"],
            "physical_networks" => node["quantum"]["lb"]["physical_networks"]
    )
    # notifies :restart, resources(:service => "quantum-server"), :immediately
    notifies :restart, resources(:service => "quantum-plugin-linuxbridge-agent"), :immediately
    notifies :enable, resources(:service => "quantum-plugin-linuxbridge-agent"), :immediately
end
