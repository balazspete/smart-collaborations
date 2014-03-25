
{ exec, spawn } = require 'child_process'

capture = (callback) ->
	c = spawn 'raspistill', [ '-o', 'captured-image.jpg' ]
	c.on 'close', (code) ->
		callback null

	c.on 'error', (error) ->
		callback error

module.exports = (callback) ->
	capture callback


