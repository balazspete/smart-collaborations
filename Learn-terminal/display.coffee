
{ spawn } = require 'child_process'

module.exports = (url, callback) ->
  dw = spawn 'wget', [ '-O', 'image', url ]
  dw.on 'close', (code) ->
    global.display_process.kill 'SIGINT' if global.display_process

    d = spawn 'eog', [ '-f', '--display=:0', 'image' ]

    d.on 'error', (error) ->
      callback error

    callback()

  dw.on 'error', (error) ->
    callback error

