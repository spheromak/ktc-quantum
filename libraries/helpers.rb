module KTC
  class Quantum

    def get_quantum_access(http, tenant_name, user_name, user_pass, api_ver)
      headers = build_headers
      path = "#{api_ver}/tokens"
      payload = build_auth_object(tenant_name, user_name, user_pass)
      token = nil
      url = nil
      error = false
      resp = http.send_request('POST', path, JSON.generate(payload), headers)
      if resp.is_a?(Net::HTTPOK)
        data = JSON.parse(resp.body)
        token = data['access']['token']['id']
        data['access']['serviceCatalog'].each do |obj|
          url = obj['endpoints'][0]['publicURL'] if obj['type'] == "network" && obj['name'] == "quantum"
          break if url
        end
      else
        Chef::Log.error("Unknown response from the Keystone Server")
        Chef::Log.error("Response Code: #{resp.code}")
        Chef::Log.error("Response Message: #{resp.message}")
        error = true
      end
      return token,url,error
    end
  
    def build_auth_object(tenantname, username, password)
      auth_obj = Hash.new
      auth_obj.store("tenantName", tenantname)
      credential_obj = Hash.new
      credential_obj.store("username", username)
      credential_obj.store("password", password)
      auth_obj.store("passwordCredentials", credential_obj)
      ret = Hash.new
      ret.store("auth", auth_obj)
      return ret
    end
  
    def find_value(http, path, headers, container, key, match_value, value)
      val = nil
      error = false
      resp = http.request_get(path, headers)
      if resp.is_a?(Net::HTTPOK)
        data = JSON.parse(resp.body)
        data[container].each do |obj|
          val = obj[value] if obj[key] == match_value
          break if val
        end
      else
        Chef::Log.error("Unknown response from the Keystone Server")
        Chef::Log.error("Response Code: #{resp.code}")
        Chef::Log.error("Response Message: #{resp.message}")
        error = true
      end
      return val,error
    end
  
    def build_headers(token=nil)
      ret = Hash.new
      ret.store('X-Auth-Token', token) if token
      ret.store('Content-type', 'application/json')
      ret.store('Accept', 'application/json')
      ret.store('user-agent', 'Chef ktc-quantum cookbook')
      return ret
    end
  end
end
