namespace :ngrok do
    desc "Update ngrok URL in config/settings.yml (HTTPS only)"
    task update: :environment do
      require "net/http"
      require "json"
      require "yaml"
  
      uri = URI("http://127.0.0.1:4040/api/tunnels")
  
      begin
        response = Net::HTTP.get(uri)
        tunnels = JSON.parse(response)["tunnels"]
  
        https_tunnel = tunnels.find { |t| t["public_url"].start_with?("https://") }
  
        if https_tunnel.nil?
          next
        end
  
        https_url = https_tunnel["public_url"]
  
        settings_path = Rails.root.join("config/settings.yml")
        settings = YAML.unsafe_load_file(settings_path)
  
        settings["ngrok"] = https_url
  
        File.write(settings_path, settings.to_yaml)
  
      rescue Errno::ECONNREFUSED
      rescue => e
        puts " #{e.message}"
      end
    end
  end
