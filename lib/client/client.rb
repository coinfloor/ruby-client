=begin
Copyright 2014 Coinfloor LTD.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end
require 'faye/websocket'
module Coinfloor
  class CFClient
    def initialize(domain,uid,api_key,pass,pkey=nil)
      
      if domain.include?("ws://")||domain.include?("wss://")
        @messages=[]
        if uid==0
          @con=CFAcon.new(uid,pass)
        else
          if pkey
            @con=CFcon.new(uid,pass,api_key,pkey)
          else
            @con=CFcon.new(uid,api_key,pass)
          end
        end
        @domain=domain
      else
        puts "domain must be a ws:// or wss:// formatted string, if port is not 80 it must be specified"
      end
      
    end
    def auth(ws,msg)
      @messages.push(:auth)
      nonce=msg["nonce"]
      result=@con.auth(nonce)
      ws.send(result)
    end
    
    def begin_connection(sendata)
      output=nil
      EM.run {
        ws = Faye::WebSocket::Client.new(@domain)
        ws.on :open do |event|
        end
        
        ws.on :message do |event|
          evtdata=event.data
          msg=JSON.parse(evtdata)
          if msg["notice"]&&msg["notice"]=="Welcome"
            auth(ws,msg)
          elsif msg["notice"].nil?
            ret_msg=@messages.delete_at(0)
            case ret_msg
            when nil
              ws.close
              ws=nil
              EM.stop
            when :auth
              if msg["error_code"]==0
                @messages.push(:reply)
                ws.send(sendata)
              else
                ws.close
                ws=nil
                EM.stop
              end
            when :reply
              if msg["error_code"]==0
                output=msg
                ws.close
                EM.stop
              else
                output=msg
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
        end# end of on message event 
        
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
    
    def exec(cfcon_method,arguments)
      
      data=@con.send(cfcon_method.to_s,arguments)
      
      begin_connection(data)
    end
    
    def get_balance
      self.exec(:getbalance,{})
    end
    
    def public_key
      @con.public_key
    end
  end
end
