
api = require './api'
capture = require './capture'

# Set the interval for the operations
interval = 1000

busy = false
device_url = null

api.registerDevice (err, result) ->
  device_url = result.device.url
  console.log device_url

executeTask = (task) ->
  return if task.completed
  return if busy

  busy = true
  capture (err) ->
    return console.log(err) if err
    api.uploadImage task.image, "./captured-image.jpg", (err, url) ->
      api.updateTask task.url, (err, _task) ->
        busy = false
        console.log("Uploaded camera shot to "+task.image)

getTasks = ->
  return unless device_url
  return if busy
  api.getDevice device_url, (err, result) ->
    executeTask(task) for task in result.device.tasks

setInterval getTasks, interval

