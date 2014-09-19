require "faye/websocket"

module Coinfloor
  class CFClient
    def initialize(domain, uid, pass, api_key = nil, pkey = nil)
      if domain.include?("ws://") || domain.include?("wss://")
        @messages = []
        if uid == 0
          @con = CFAcon.new(uid, pass)
        else
          if api_key.nil?
            abort("An API key is required")
          elsif pkey
            @con = CFcon.new(uid, pass, api_key, pkey)
          else
            @con = CFcon.new(uid, pass, api_key)
          end
        end
        @domain = domain
      else
        puts "domain must be a ws:// or wss:// formatted string, if port is not 80 it must be specified"
      end
    end

    def auth(ws, msg)
      @messages.push(:auth)
      nonce = msg["nonce"]
      result = @con.auth(nonce)
      ws.send(result)
    end

    def begin_connection(sendata)
      puts "begining connection"
      output = nil
      EM.run {
        ws = Faye::WebSocket::Client.new(@domain)
        ws.on :open do |event|
        end

        ws.on :message do |event|
          evtdata = event.data
          msg = JSON.parse(evtdata)
          puts msg
          if msg["notice"] && msg["notice"] == "Welcome"
            auth(ws, msg)
          elsif msg["notice"].nil?
            ret_msg = @messages.delete_at(0)
            case ret_msg
            when nil
              ws.close
              ws = nil
              EM.stop
            when :auth
              if msg["error_code"] == 0
                @messages.push(:reply)
                ws.send(sendata)
              else
                ws.close
                ws = nil
                EM.stop
              end
            when :reply
              if msg["error_code"] == 0
                output = msg
                ws.close
                EM.stop
              else
                output = msg
                ws.close
                EM.stop
              end
            else
              ws.close
              EM.stop
              raise "Reply for unknown action"
            end
          elsif msg["notice"] && (@messages.count > 0)
            #we just ignore this until we get a message we want
          elsif msg["notice"] && (@messages.count == 0)
            ws.close
            EM.stop
          else
            raise "Somethings gone wrong with the client"
          end
        end

        ws.on :error do |event|
          EM.stop
          ws = nil
        end

        ws.on :close do |event|
          EM.stop
          ws = nil
        end
      }
      return output
    end

    def exec(cfcon_method, args)
      data = @con.send(cfcon_method.to_s, args)
      begin_connection(data)
    end

    def get_balance
      self.exec(:getbalance, {})
    end

    def public_key
      @con.public_key
    end
  end
end
