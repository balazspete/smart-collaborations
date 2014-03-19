
config = require './config'
api = require './api'
capture = require './capture'
display = require './display'

# Set the interval for the operations
interval = 1000

busy = false
device_url = null

api.registerDevice (err, result) ->
  device_url = result.device.url
  console.log device_url

captureTask = (task) ->
  capture (err) ->
    return console.log(err) if err
    api.uploadImage task.image, "./captured-image.jpg", (err, url) ->
      api.updateTask task.url, (err, _task) ->
        busy = false
        console.log("Uploaded camera shot to "+task.image)

displayTask = (task) ->
  display "http://#{config.host}#{task.image}", (error) ->
    return console.log error if error
    console.log "displaying"

executeTask = (task) ->
  return if task.completed
  return if busy

  console.log task
  if task.type is "capture"
    busy = true
    captureTask task
  else if task.type is "display"
    null#displayTask task

getTasks = ->
  return unless device_url
  return if busy
  api.getDevice device_url, (err, result) ->
    executeTask(task) for task in result.device.tasks

setInterval getTasks, interval

