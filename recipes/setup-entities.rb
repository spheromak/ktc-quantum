#
## Cookbook Name:: ktc-quantum
## Recipe:: setup entities
##

include_recipe "ktc-quantum::l3-agent"

ks = get_access_endpoint("keystone-api", "keystone", "service-api")

url ="#{ks['scheme']}#{ks['host']}:#{ks['port']}/#{ks['path']}/tokens"

quantum_router node['quantum']['l3']['router_name'] do
  auth_url    url
  tenant_name node['quantum']['service_tenant_name']
  user_name   node['quantum']['service_user']
  api_key     node['quantum']['service_pass']
end
