
require 'rest-client'
require 'json'

require 'pp'


module Teslamatic
  module API

    class CommandFailed < Exception

    end

    class Portal

      #
      # Implementation of a simple command that requires no arguments, other than vehicle id.
      #
      def self.simple_command(*args)
        args.each { |a| define_method(a) {|id| send_command a.to_s, id } }
      end

      # State query commands
      simple_command :mobile_enabled, :charge_state, :climate_state, :drive_state, :vehicle_state, :gui_settings

      # Climate Control Commands
      simple_command :auto_conditioning_start, :auto_conditioning_stop

      # Charging commands
      simple_command :charge_start, :charge_stop, :charge_standard, :charge_max_range, :charge_port_door_open

      # Additional commands
      simple_command :door_lock, :door_unlock, :honk_horn, :flash_lights, :wake_up

      def initialize(username, password, host = "portal.vn.teslamotors.com", protocol = "https")
        @username = username
        @password = password
        @host = host
        @protocol = protocol
        login
      end

      def username
        @username
      end

      def login
        response = RestClient.post("#{@protocol}://#{@host}/login",
                                   { "user_session[email]" => @username, "user_session[password]" => @password }) { |response, request, result, &block|
          # The Portal returns a 302 currently, so ignore and treat as a 200 response.
          if [200..207, 302].include? response.code
            response
          else
            response.return!(request, result, &block)
          end
        }
        @login_cookies = response.cookies
      end

      def vehicles
        response = RestClient.get "#{@protocol}://#{@host}/vehicles", { :cookies => @login_cookies, :accept => :json }
        JSON.parse(response)
      end

      def vehicle(id)
        response = RestClient.get "#{@protocol}://#{@host}/vehicles/#{id}", { :cookies => @login_cookies, :accept => :json }
        JSON.parse(response)
      end

      def mobile_enabled(id)
        response = RestClient.get "#{@protocol}://#{@host}/vehicles/#{id}/mobile_enabled", { :cookies => @login_cookies, :accept => :json }
        JSON.parse(response)
      end

      def send_command(command, id, params = {})
        response = RestClient.get "#{@protocol}://#{@host}/vehicles/#{id}/command/#{command}", { :cookies => @login_cookies, :accept => :json }
        if response.code == 200
          JSON.parse(response)
        else
          raise CommandFailed response
        end
      end

    end

  end
end
