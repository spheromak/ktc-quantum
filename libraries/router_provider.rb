require 'chef/provider'


class Chef
  class Provider
    class QuantumRouter < Chef::Provider

      def whyrun_supported?
        false
      end

      def initialize(new_resource, run_context)
        super
        # create the fog connection
        @quantum = KTC::Quantum.new
          auth_url: new_resource.auth_url,
          api_key:  new_resource.user_pass,
          tenant:   new_resource.tenant_name
          user:     new_resource.user_name,
        )
      end

      def load_current_resource
        current_resource ||= Chef::Provider::QuantumRouter.new(new_resource.name)
        current_resource.auth_url new_resource.auth_url
        current_resource.api_key  new_resource.api_key
        current_resource.tenant   new_resource.tenant
        current_resource.user     new_resource.user

        # load the router from quantum if it exists
        # fog returnss nil if its not found
        current_resource.router @quantum.get_router(current_resource.name)
      end


      def action_create
        #
        # for now we only create, we don't set
        # external_gateway
        #
        if current_resource.router
          # if it exists already store its id and return
          store_router_id current_resource.router.id
          return
        end

        new_resource.router = @quantum.router.new(name: new_resource.name)
        new_resource.router.create
        store_router_id new_resource.router.id
        new_resource.updated_by_last_action(true)
      end

    private

      def store_router_id(id)
       node.set['quantum']['l3']['router_id'] = id
      end

    end
  end
end
