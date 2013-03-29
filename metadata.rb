maintainer        "KT Cloudware, Inc."
description	  "Installs/Configures Openstack Quantum Service"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
recipe		 "ktc-quantum::server", "Installs packages required for quantum-server"

%w{ ubuntu fedora }.each do |os|
	  supports os
end

%w{ database monitoring mysql osops-utils }.each do |dep|
	  depends dep
end
