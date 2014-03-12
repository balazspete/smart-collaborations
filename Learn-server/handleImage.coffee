
fs = require 'fs'
crypto = require 'crypto'
path = require 'path'

createHashID = ->
  crypto.createHash('sha1').update("#{Math.random()}").digest('hex');

module.exports = (file, callback) ->
  return callback("No `image` file. Make sure the `image` field is being set.") unless file

  path = path.normalize "#{global.image_path}#{createHashID()}_#{file.name}"
  fs.rename file.path, path, (error) ->
    return callback(error) if error
    callback null, path

