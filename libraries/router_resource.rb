#
# Cookbook Name:: ktc-quantum
# Resource:: router
#
require 'chef/resource'

class Chef
  class Resource
    class QuantumRouter < Chef::Resource

      def initialize(name, run_context=nil)
        super(name, run_context)
        @resource_name = :quantum_router
        @action = "create"
        @allowed_actions.push(:create)
        @provider = Chef::Provider::QuantumRouter
        @auth_url = nil
      end

      def auth_url(arg=nil)
        set_or_return(
          :auth_protocol,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def tenant_name(arg=nil)
        set_or_return(
          :tenant_name,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def user_name(arg=nil)
        set_or_return(
          :user_name,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def api_key(arg=nil)
        set_or_return(
          :user_pass,
          arg,
          :kind_of => String,
          :required => true
        )
      end

    end
  end
end
