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
        @auth_protocol = nil
        @auth_host = nil
        @auth_port = nil
      end

      def auth_protocol(arg=nil)
        set_or_return(
          :auth_protocol,
          arg,
          :kind_of => String,
          :equal_to => [ "http", "https" ],
          :required => true
        )
      end

      def auth_host(arg=nil)
        set_or_return(
          :auth_host,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def auth_port(arg=nil)
        set_or_return(
          :auth_port,
          arg,
          :kind_of => String,
          :required => true
        )
      end

      def auth_api_ver(arg=nil)
        set_or_return(
          :auth_api_ver,
          arg,
          :default => "/v2.0",
          :kind_of => String
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

      def user_pass(arg=nil)
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
