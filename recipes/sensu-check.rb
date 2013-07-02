#
# Cookbook Name:: ktc-quantum 
# Recipe:: sensu-check 
#
# Copyright 2013, Sean Porter Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "ktc-monitor::plugin_setup"
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
