#
## Cookbook Name:: ktc-quantum
## Recipe:: server
##
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "mysql::client"
include_recipe "mysql::ruby"
include_recipe "osops-utils"

if not node["package_component"].nil?
    release = node["package_component"]
else
    release = "grizzly"
end

platform_options = node["quantum"]["platform"][release]

if node["developer_mode"]
    node.set_unless["quantum"]["db"]["password"] = "quantum"
else
    node.set_unless["quantum"]["db"]["password"] = secure_password
end

node.set_unless['quantum']['service_pass'] = secure_password

package "quantum-server" do
    action :install
end

package "quantum-plugin-linuxbridge" do
    action :install
    only_if { node["quantum"]["plugin"] == "lb" }
end

ks_admin_endpoint = get_access_endpoint("keystone-api", "keystone", "admin-api")
ks_service_endpoint = get_access_endpoint("keystone-api", "keystone", "service-api")
keystone = get_settings_by_role("keystone", "keystone")

# Create db and user
# return connection info
# defined in osops-utils/libraries
mysql_info = create_db_and_user("mysql", 
				node["quantum"]["db"]["name"],
				node["quantum"]["db"]["username"],
				node["quantum"]["db"]["password"])
db_ip_address = get_access_endpoint("mysql-master", "mysql", "db")["host"]

platform_options["mysql_python_packages"].each do |pkg|
    package pkg do
        action :install
    end
end

platform_options["quantum_packages"].each do |pkg|
    package pkg do
        action :upgrade
	options platform_options["package_overrides"]
    end
end

service "quantum-server" do
    service_name platform_options["quantum_api_service"]
    supports :status => true, :restart => true
    action :nothing
end

keystone_register "Register Service Tenant" do
    auth_host ks_admin_endpoint["host"]
    auth_port ks_admin_endpoint["port"]
    auth_protocol ks_admin_endpoint["scheme"]
    api_ver ks_admin_endpoint["path"]
    auth_token keystone["admin_token"]
    tenant_name node["quantum"]["service_tenant_name"]
    tenant_description "Service Tenant"
    tenant_enabled "1"
    action :create_tenant
end

keystone_register "Register Service User" do
    auth_host ks_admin_endpoint["host"]
    auth_port ks_admin_endpoint["port"]
    auth_protocol ks_admin_endpoint["scheme"]
    api_ver ks_admin_endpoint["path"]
    auth_token keystone["admin_token"]
    tenant_name node["quantum"]["service_tenant_name"]
    user_name node["quantum"]["service_user"]
    user_pass node["quantum"]["service_pass"]
    user_enabled "1"
    action :create_user
end

keystone_register "Grant 'admin' role to service user for service tenant" do
    auth_host ks_admin_endpoint["host"]
    auth_port ks_admin_endpoint["port"]
    auth_protocol ks_admin_endpoint["scheme"]
    api_ver ks_admin_endpoint["path"]
    auth_token keystone["admin_token"] 
    tenant_name node["quantum"]["service_tenant_name"]
    user_name node["quantum"]["service_user"]
    role_name node["quantum"]["service_role"]
    action :grant_role
end

keystone_register "Reqister Quantum Service" do
    auth_host ks_admin_endpoint["host"]
    auth_port ks_admin_endpoint["port"]
    auth_protocol ks_admin_endpoint["scheme"]
    api_ver ks_admin_endpoint["path"]
    auth_token keystone["admin_token"]
    service_name "quantum"
    service_type "network"
    service_description "Quantum Network Service"
    action :create_service
end

api_endpoint = get_bind_endpoint("quantum", "api")
keystone_register "Register Quantum Endpoint" do
    auth_host ks_admin_endpoint["host"]
    auth_port ks_admin_endpoint["port"]
    auth_protocol ks_admin_endpoint["scheme"]
    api_ver ks_admin_endpoint["path"]
    auth_token keystone["admin_token"]
    service_type "network"
    endpoint_region "RegionOne"
    endpoint_adminurl api_endpoint["uri"]
    endpoint_internalurl api_endpoint["uri"]
    endpoint_publicurl api_endpoint["uri"]
    action :create_endpoint
end

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

template "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini" do
    source "#{release}/linuxbridge_conf.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
            "db_ip_address" => db_ip_address,
            "db_user" => node["quantum"]["db"]["username"],
            "db_password" => node["quantum"]["db"]["password"],
            "db_name" => node["quantum"]["db"]["name"],
            "lb_debug" => node["quantum"]["debug"],
            "lb_verbose" => node["quantum"]["verbose"],
            "physical_network" => node["quantum"]["lb"]["physical_network"],
            "physical_interface" => node["quantum"]["lb"]["physical_interface"],
            "physical_networks" => node["quantum"]["lb"]["physical_networks"]
    )
    only_if { node["quantum"]["plugin"] == "lb" }
end

template "/etc/default/quantum-server" do
  source "#{release}/quantum-server.erb"
  owner "quantum"
  group "quantum"
  mode "0600"
  variables(
          "quantum_plugin" => node["quantum"]["plugin"]
  )
  notifies :restart, resources(:service => "quantum-server"), :immediately
end

# Get rabbit info
rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")
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
    notifies :restart, resources(:service => "quantum-server"), :immediately
    notifies :enable, resources(:service => "quantum-server"), :immediately
end

include_recipe "ktc-quantum::ng-patch"
