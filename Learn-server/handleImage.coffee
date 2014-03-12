
fs = require 'fs'
crypto = require 'crypto'
path = require 'path'

createHashID = ->
  crypto.createHash('sha1').update("#{Math.random()}").digest('hex');

module.exports = (file, callback) ->
  return callback("No `image` file. Make sure the `image` field is being set.") unless file

  _path = path.normalize("#{global.image_path}#{createHashID()}_#{file.name}")
  is = fs.createReadStream file.path
  os = fs.createWriteStream _path

  is.pipe os
  is.on 'end', ->
    fs.unlinkSync file.path
    callback null, _path
