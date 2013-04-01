## Cookbook Name:: ktc-quantum
## Recipe:: plugin
##

case node["quantum"]["plugin"]
when "ovs"
	include_recipe "ktc-quantum::ovs-plugin"
when "lb"
        include_recipe "ktc-quantum::lb-plugin"
end
