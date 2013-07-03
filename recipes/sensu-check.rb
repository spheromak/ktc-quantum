#
# Cookbook Name:: ktc-quantum 
# Recipe:: sensu-check 
#

include_recipe "ktc-monitor::client"

#
## process check
#
sensu_check "quantum_ns_metadata_proxy_process" do
  command "check-procs.rb -p quantum-ns-metadata-proxy -C 1"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quantum_linuxbridge_agent_process" do
  command "check-procs.rb -p quantum-linuxbridge-agent -C 1"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quantum_dhcp_agent_process" do
  command "check-procs.rb -p quantum-dhcp-agent -w 4 -c 4 -W 3 -C 3"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quantum_metadata_agent_process" do
  command "check-procs.rb -p quantum-metadata-agent -C 1"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quantum_l3_agent_process" do
  command "check-procs.rb -p quantum-l3-agent -C 1"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "dnsmasq_process" do
  command "check-procs.rb -p dnsmasq -w 3 -c 3 -W 2 -C 2"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quagga_ripd_process" do
  command "check-procs.rb -p ripd -W 1"
  handlers ["default"]
  standalone true
  interval 20
end

sensu_check "quagga_zebra_process" do
  command "check-procs.rb -p zebra -W 1"
  handlers ["default"]
  standalone true
  interval 20
end
