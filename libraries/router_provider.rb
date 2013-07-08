require 'chef/provider'


class Chef
  class Provider
    class QuantumRouter < Chef::Provider
      include KTC

      def whyrun_supported?
        false
      end

      def load_current_resource
      end

      def action_create
        quantum = KTC::Quantum.new
        host = new_resource.auth_host
        port = new_resource.auth_port
        protocol = new_resource.auth_protocol
        api_ver = new_resource.auth_api_ver
        tenant_name = new_resource.tenant_name
        user_name = new_resource.user_name
        user_pass = new_resource.user_pass
        router_name = new_resource.name

        # construct a HTTP object for requesting keystone
        auth_http = Net::HTTP.new(host, port)

        # Check to see if connection is http or https
        if protocol == "https"
          auth_http.use_ssl = true
        end

        # Get x-auth-token and the quantum api endpoint url
        token, url, post_error = quantum.get_quantum_access(auth_http, tenant_name, user_name, user_pass, api_ver)
        Chef::Log.error("There was an error getting token and the quantum api endpoint for user/tenant '#{user_name}/#{tenant_name}'") if post_error
        Chef::Log.fatal(post_error)

        # construct a HTTP object for requesting quantum
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)

        # Build out the required header and body info
        router_headers = quantum.build_headers(token)

        # Make sure this router does not already exist
        router_container = "routers"
        router_key = "name"
        router_path = "/v2.0/routers"
        router_uuid, router_error = quantum.find_value(http, router_path, router_headers, router_container, router_key, router_name, 'id')

        unless router_uuid or router_error
          # Create router
          router_path = "/v2.0/router"
          router_obj = Hash.new
          router_obj.store("name", router_name)
          ret = Hash.new
          ret.store("router", router_obj)
          router_body = JSON.generate(ret)
          resp = http.send_request('POST', router_path, router_body, router_headers)
          if resp.is_a?(Net::HTTPOK)
            Chef::Log.info("Created router '#{resp["router"]["name"]}' with ID '#{resp["router"]["id"]}' for tenant '#{tenant_name}'")

            # Set router_id attribute to be used to configure l3-agent.ini
            node.set['quantum']['l3']['router_id'] = resp['router']['id']

            new_resource.updated_by_last_action(true)
          else
            Chef::Log.error("Unable to create router '#{router_name}' for tenant '#{tenant_name}'")
            Chef::Log.error("Response Code: #{resp.code}")
            Chef::Log.error("Response Message: #{resp.message}")
            Chef::Log.fatal(true)
          end
        else
          Chef::Log.info("Router '#{router_name}' already exists with Tenant '#{tenant_name}'.. Not creating.") if router_uuid
          Chef::Log.info("Router UUID: #{router_uuid}") if router_uuid
          node.set['quantum']['l3']['router_id'] = router_uuid if router_uuid
          Chef::Log.error("There was an error looking up router '#{router_name}' for tenant '#{tenant_name}'") if router_error
          Chef::Log.fatal(router_error)
          new_resource.updated_by_last_action(false)
        end
      end


    end
  end
end
