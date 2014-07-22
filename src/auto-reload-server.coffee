WebSocketServer = require('ws').Server

class AutoReloadServer
  constructor: (@config) ->
    @ports = @config.ports ? [9812..9822]
    @port = @ports.shift()
    @connections = []
    @startServer()

  startServer: ->
    @server = new WebSocketServer
      host: '0.0.0.0'
      port: @port

    @server.on 'connection', (connection) =>
      @connections.push connection
      connection.on 'close', =>
        @connections.splice connection, 1

    @server.on 'error', (error) =>
      if error.toString().match /EADDRINUSE/
        if @ports.length
          @port = @ports.shift()
          @startServer()
        else
          error = "cannot start because port " + port + " is in use"

      console.error "AutoReload #{error}"

  sendMessage: (message) ->
    @connections
      .filter (connection) ->
        connection.readyState is 1

      .forEach (connection) ->
        connection.send message

  teardown: ->
    @server.close()

module.exports = {
  AutoReloadServer
}
