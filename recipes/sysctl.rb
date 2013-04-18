#
## Cookbook Name:: ktc-quantum
## Recipe:: sysctl
##

include_recipe "sysctl"
# Set net.ipv4.ip_forward = 1 and save it into /etc/sysctl.d/60-ktc-quantum-cookbook
sysctl "ktc-quantum cookbook" do
  priority "60"
  variable "net.ipv4.ip_forward"
  value "1"
  action :save
end
