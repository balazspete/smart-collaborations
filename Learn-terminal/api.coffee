
fs = require 'fs'
http = require 'http'
request = require 'request'

config = require './config'

options = 
  host: config.host
  port: config.port
  method: 'POST'
  headers: 
    'Content-Type': 'application/json'

module.exports.registerDevice = (callback) ->
  _options = options
  _options.path = '/device'
  req = http.request options, (res) ->
    res.setEncoding 'utf8'
    res.on 'data', (chunk) ->
      callback null, JSON.parse(chunk)

  req.write '{}'
  req.end()

module.exports.getDevice = (url, callback) ->
  _options = options
  _options.path = url
  req = http.request _options, (res) ->
    res.setEncoding 'utf8'
    res.on 'data', (chunk) ->
      callback null, JSON.parse(chunk)

  req.write '{}'
  req.end()

module.exports.updateTask = (url, callback) ->
  _options = options
  _options.path = url

  req = http.request _options, (res) ->
    res.setEncoding 'utf8'
    res.on 'data', (chunk) ->
      callback null, JSON.parse(chunk)

  req.write '{ "completed": true }'
  req.end()

module.exports.uploadImage = (url, image_path, callback) ->
  r = request.post "http://#{config.host}#{url}"
  form = r.form()

  stream = fs.createReadStream image_path
  stream.on 'error', (err) ->
    console.log err

  stream.on 'end', ->
    r.start()

  form.append 'image', stream

  r.on 'end', (data) ->
    callback null, data




