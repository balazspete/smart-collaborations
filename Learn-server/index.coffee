
###
# IMAGES FOLDER PATH
###
global.image_path = "./uploads/"

###
# DECLARATIONS & SETUP
###
fs = require 'fs'
express = require 'express'
mongoose = require 'mongoose'

global.app = app = express()
global.db = db = mongoose.createConnection 'mongodb://localhost:27017/learn', {
  server: { auto_reconnect: true }
}

image_handler = require './handle_image'

api = require './api'

fs.exists global.image_path, (exists) ->
  unless exists
    fs.mkdir global.image_path, (err) ->
      return console.log err if err
      console.log "Created folder #{global.image_path}"

app.use express.bodyParser()

sendError = (res, error) ->
  console.log error
  res.status(500).send(error);

###
# THE API
###
app.get '/classes', (req, res) ->
  api.getSummary (err, classes) ->
    return sendError(res, err) if err

    response = 
      url: "/classes"
      classes: []

    for c in classes
      lectures = []
      for l in c.lectures
        l.pages = []
        lectures.push l
      c.lectures = lectures
      response.classes.push c

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.get '/class/:id', (req, res) ->
  api.getClass "/class/#{req.route.params['id']}", (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      class: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.post '/class', (req, res) ->
  name = req.body.name
  return sendError(res, "Null name") unless name

  api.saveClass name, (error, c) ->
    response = 
      class: c

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.post '/class/:id/lecture', (req, res) ->
  c = "/class/#{req.route.params['id']}"
  name = req.body.name
  image = req.body.image

  return sendError(res, "Null name") unless name

  api.saveLecture c, name, image, (err, result) ->
    response = 
      lecture: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.get '/class/:classid/lecture/:lectureid', (req, res) ->
  api.getLecture "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}", (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      lecture: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.post '/class/:classid/lecture/:lectureid/page', (req, res) ->
  l = "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}"

  title = req.body.title
  return sendError(res, "Null title") unless title

  primary = req.body.primary
  secondary = req.body.secondary
  collaboration = req.body.collaboration

  api.savePage l, title, primary, secondary, collaboration, (err, result) ->
    response = 
      page: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.get '/class/:classid/lecture/:lectureid/page/:pageid', (req, res) ->
  api.getPage "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/#{req.route.params['pageid']}", (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      page: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.post '/class/:classid/lecture/:lectureid/page/:pageid', (req, res) ->
  url = "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/#{req.route.params['pageid']}"

  console.log req.body
  title = req.body.title if req.body.title
  primary = req.body.primary if req.body.primary
  secondary = req.body.secondary if req.body.secondary
  collaboration = req.body.collaboration if req.body.collaboration

  api.updatePage url, title, primary, secondary, collaboration, (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      page: result

    res.setHeader 'Content-Type', 'application/json'
    res.send JSON.stringify response

app.get '/collaboration/:id', (req, res) ->
  api.getCollaboration "/collaboration/#{req.route.params['id']}", (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result   

    response = 
      collaboration: result

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.post '/collaboration', (req, res) ->
  api.createCollaboration (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result   

    response =
      collaboration: result    

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.post '/collaboration/:id', (req, res) ->
  url = "/collaboration/#{req.route.params['id']}"
  
  console.log req.body
  user = req.body.user
  return sendError(res, "Null user") unless user

  body = req.body.body
  image = req.body.image
  return sendError(res, "Null content") unless body or image

  api.createCollaborationEntry url, user, body, image, (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result   

    response =
      collaborationEntry: result    

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.get '/image/:id', (req, res) ->
  api.getImage "/image/#{req.route.params['id']}", (err, result) ->
    return res.status(404).send('Not found') unless result  
    res.sendfile result.path

app.post '/image', (req, res) ->
  callback = (path) ->
    api.createImage path, (err, result) ->
      return sendError(res, "failed to create image") unless result

      # response = 
      #   image: result
      #   uploaded: true
      response = result.url

      res.setHeader 'Content-Type', 'text/plain'#'application/json'
      res.send response

  if req.files and req.files.image
    image_handler req.files.image, (err, path) ->
      return sendError(res, err) if err
      callback path
  else
    callback "./placeholder.png"

app.post '/image/:id', (req, res) ->
  image_handler req.files.image, (err, path) ->
    return sendError(res, err) if err

    api.updateImage "/image/#{req.route.params['id']}", path, (err, result) ->
      return sendError(res, err) if err
      return res.status(404).send('Not found') unless result   

      response =
        image: result    

      res.setHeader 'Content-Type', 'application/json'
      res.send response

app.post '/user', (req, res) ->
  name = req.body.name
  return sendError(res, "No name given") unless name

  api.createUser name, (err, result) ->
    return sendError(res, err) if err

    response =
      user: result    

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.get '/devices', (req, res) ->
  api.getDevices (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      devices: result

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.post '/device', (req, res) ->
  api.createDevice (err, result) ->
    if err
      response = 
        registered: no
    else
      response = 
        device: result
        registered: yes
      console.log "Device: #{result.url}"
      
    res.setHeader 'Content-Type', 'application/json'
    res.send response

checkin_callback = (req, res, checkin) ->
  url = "/device/#{req.route.params['id']}"
  api.getDevice url, checkin, (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      device: result

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.get '/device/:id', (req, res) ->
  checkin_callback req, res, false

app.post '/device/:id', (req, res) ->
  checkin_callback req, res, true

app.post '/device/:id/task', (req, res) ->
  device = "/device/#{req.route.params['id']}"
  image = req.body.image
  return sendError(res, "Null image") unless image

  api.createTask device, image, (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      task: result

    res.setHeader 'Content-Type', 'application/json'
    res.send response

app.post '/device/:deviceid/task/:taskid', (req, res) ->
  url = "/device/#{req.route.params['deviceid']}/task/#{req.route.params['taskid']}"
  
  completed = req.body.completed 
  return sendError(res, "Null completed") unless completed

  api.updateTask url, completed, (err, result) ->
    return sendError(res, err) if err
    return res.status(404).send('Not found') unless result

    response = 
      task: result

    res.setHeader 'Content-Type', 'application/json'
    res.send response

port = 80
app.listen port
console.log "Listening on port #{port}"


