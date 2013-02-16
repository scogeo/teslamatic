
require 'teslamatic/vehicle'


require 'pp'
module Teslamatic
  module TRC
    class Application


      DEFAULT_CONFIG = File.expand_path('~/.teslamatic')


      def main
        @config_file = ENV['TESLAMATIC_CONFIG']
        config = load_config

        if config[:username].nil? || config[:password].nil?
          puts "No username password found in config"
          exit 1
        end

        pp config

        portal = Teslamatic::API::Portal.new(config[:username], config[:password])

        #portal.login

        vehicles = Vehicle.vehicles(portal)
        vehicle = vehicles.first

        #vehicle = portal.vehicles.first

        if vehicle
          p vehicle.climate_state
          p vehicle.descriptor
          pp vehicle.wake_up
          puts "mobile enabled #{vehicle.mobile_enabled?}"
          pp vehicle.charge_state
          pp vehicle.drive_state
          puts "odometer is #{vehicle.odometer}"

=begin
          puts "vehicle charging #{vehicle.charging?}"
          pp vehicle.charge_state
          #vehicle.honk_horn
          pp vehicle.drive_state
          pp vehicle.climate_state
          pp vehicle.vehicle_state
=end
        else
          puts "No vehicles found in portal."
        end




      end

      def load_config
        require 'yaml'
        if @config_file && File.readable?(@config_file)
          YAML.load(File.read(@config_file))
        elsif File.readable?(DEFAULT_CONFIG)
          YAML.load(File.read(DEFAULT_CONFIG))
        else
          Hash.new
        end
      end

    end
  end
end