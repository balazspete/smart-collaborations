
{ spawn } = require 'child_process'

module.exports = (url, callback) ->
  global.display_process.kill 'SIGINT' if global.display_process

  d = spawn 'eog', [ '-f', '--display=:0', url ]

  d.on 'error', (error) ->
    callback error

  callback()
