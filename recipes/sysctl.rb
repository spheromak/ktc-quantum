#
## Cookbook Name:: ktc-quantum
## Recipe:: sysctl
##

include_recipe "sysctl"
sysctl_multi "ktc-quantum cookbook" do
  priority "60"
  instructions(
    "net.ipv4.ip_forward" => "1",
    "net.bridge.bridge-nf-call-iptables" => "0",
    "net.bridge.bridge-nf-call-arptables" => "0"
  )
  action :save
end
