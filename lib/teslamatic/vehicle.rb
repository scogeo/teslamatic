module Teslamatic

  #
  #
  #
  class Vehicle

    require 'pp'

    def self.vehicles(portal)
      vehicles = []
      portal.vehicles.each { |v| vehicles.push(Vehicle.new(v, portal)) }
      vehicles
    end

    def initialize(descriptor, portal)
      @descriptor = descriptor
      @id = descriptor["id"]
      @portal = portal
      @state = {}
      @timestamp = {}
    end

    def descriptor
      @descriptor
    end

    def mobile_enabled?
      @portal.mobile_enabled(@id)["result"]
    end

    def charging?
      load :charge_state
      @state[:charge_state]["charging_state"] == "Charging"
    end

    def start_charging
      @portal.charge_start @id
    end

    def stop_charging
      @portal.charge_stop @id
    end

    def charge_state
      load :charge_state
      @state[:charge_state]
    end

    def vehicle_state
      load :vehicle_state
      @state[:vehicle_state]
    end

    def honk_horn
      @portal.honk_horn @id
    end

    def flash_lights
      @portal.flash_lights @id
    end

    def lock_doors
      @portal.lock_doors @id
    end

    def unlock_doors
      @portal.unlock_doors @id
    end

    def climate_state
      load :climate_state
      @state[:climate_state]
    end

    def drive_state
      load :drive_state
      @state[:drive_state]
    end

    def wake_up
      @portal.wake_up @id
    end

    def refresh_descriptor
      @descriptor = @portal.vehicle @id
    end

    def live_stream(&block)
      refresh_descriptor

      stream_password = @descriptor["tokens"][0]
      vehicle_id = @descriptor["vehicle_id"]

      streaming = Teslamatic::API::Streaming.new(@portal.username, stream_password, vehicle_id)

      streaming.stream_data do |value|
        yield value
      end
    end

    def odometer
      value = nil
      live_stream do |data|
        value = data[:odometer]
        break
      end
      value.to_f

    end

    def stale?(type)
      # TODO add a timestamp check, refresh every N seconds (configurable)
      @state[type].nil?
      true
    end

    def load(type)
      if stale?(type)
        case type
          when :charge_state
            @state[:charge_state] = @portal.charge_state @id
            @timestamp[:charge_state] = Time.now
          when :climate_state
            @state[:climate_state] = @portal.climate_state @id
            @timestamp[:climate_state] = Time.now
          when :drive_state
            @state[:drive_state] = @portal.drive_state @id
            @timestamp[:drive_state] = Time.now
          when :vehicle_state
            @state[:vehicle_state] = @portal.vehicle_state @id
            @timestamp[:vehicle_state] = Time.now
        end
      end
    end

  end

end
