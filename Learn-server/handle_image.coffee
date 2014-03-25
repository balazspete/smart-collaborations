
fs = require 'fs'
crypto = require 'crypto'
path = require 'path'

createHashID = ->
  crypto.createHash('sha1').update("#{Math.random()}").digest('hex');

module.exports = (file, callback) ->
  return callback("No `image` file. Make sure the `image` field is being set.") unless file

  _path = path.normalize("#{global.image_path}#{createHashID()}_#{file.name}")
  input = fs.createReadStream file.path
  output = fs.createWriteStream _path

  input.pipe output
  input.on 'end', ->
    fs.unlinkSync file.path
    callback null, _path
