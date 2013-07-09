module KTC
  class Quantum
    require 'fog'

    attr_accessor :auth_uri, :user, :api_key, :tenant, :net

    def intialize(*args)
      auth_url= args[:auth_url]
      user    = args[:user]
      api_key = args[:api_key]
      tenant  = args[:tenant]

      validate
      net
    end

    def net
      @net ||= Fog::Network.new(
        :provider           => "OpenStack"
        :openstack_tenant   => tenant,
        :openstack_api_key  => api_key,
        :openstack_username => user,
        :openstack_auth_url => auth_url
      )
    end

    def validate
      %w/uri user pass tennant api_ver/.each do |opt|
        if opt.to_sym.nil?
          raise "Argument must not be empty '#{opt.to_sym}'"
        end
      end
    end

  end
end
