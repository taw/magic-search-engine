if defined?(WEBrick::HTTPRequest)
  WEBrick::HTTPRequest.const_set("MAX_URI_LENGTH", 10240)
end
