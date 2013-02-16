
require 'net/http'
require 'net/https'
require 'uri'

module Teslamatic
  module API

    class Streaming

      def initialize(username, password, vehicle_id, host = "streaming.vn.teslamotors.com", protocol = "https")
        @username = username
        @password = password
        @vehicle_id = vehicle_id
        @host = host
        @protocol = protocol
      end

      #
      # https://streaming.vn.teslamotors.com/stream/1551198381/?values=speed,odometer,soc,elevation,est_heading,est_lat,est_lng,power,shift_state
      #
      # Proxy-connection: Keep-alive
      #

      def stream_data(*args, &block)
        resource = "/stream/#{@vehicle_id}/?values=speed,odometer,soc,elevation,est_heading,est_lat,est_lng,power,shift_state"

        http = Net::HTTP.new(@host, 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        http.start do
          request = Net::HTTP::Get.new(resource)
          request.basic_auth @username, @password
          http.request(request) { |response|
            response.read_body do |str|   # read body now
              lines = str.split('\n')
              lines.each do |line|
                line.strip!
                values = line.split(',')
                result = {
                    :timestamp => values[0],
                    :speed => values[1] != nil ? values[1] : 0,
                    :odometer => values[2],
                    :soc => values[3],
                    :elevation => values[4],
                    :est_heading => values[5],
                    :est_lat => values[6],
                    :est_lng => values[7],
                    :power => values[8],
                    :shift_state => values[9] != nil ? values[9] : 'P'
                }

                yield result

              end
            end
          }

        end
      end

    end
  end

end