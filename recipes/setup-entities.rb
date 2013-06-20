#
## Cookbook Name:: ktc-quantum
## Recipe:: setup entities
##

include_recipe "ktc-quantum::l3-agent"

ks_service_endpoint = get_access_endpoint("keystone-api", "keystone", "service-api")

quantum_router node['quantum']['l3']['router_name'] do
  auth_host ks_service_endpoint['host']
  auth_port ks_service_endpoint['port']
  auth_protocol ks_service_endpoint['scheme']
  auth_api_ver ks_service_endpoint['path']
  tenant_name node['quantum']['service_tenant_name']
  user_name node['quantum']['service_user']
  user_pass node['quantum']['service_pass']
end
