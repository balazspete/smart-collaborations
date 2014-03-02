
###
# DECLARATIONS & SETUP
###
express = require 'express'
mongoose = require 'mongoose'

global.app = app = express()
global.db = db = mongoose.createConnection 'mongodb://localhost:27017/learn', {
  server: { auto_reconnect: true }
}
global.image_path = "/Users/balazspete/Documents/"

imageHandler = require './handleImage'

api = require './api'

app.use express.bodyParser()

sendError = (res, error) ->
  res.status(500).send('An error occurred');

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
  
  user = req.body.user
  return sendError(res, "Null user") unless user

  body = req.body.body
  image = req.body.image
  return sendError(res, "Null content") unless body is null or image is null

  api.addCollaborationEntry url, (err, result) ->
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
  imageHandler req.files.image, (err, path) ->
    return sendError(res, err) if err

    api.createImage path, (err, result) ->
      return sendError(res, "failed to create image") unless result

      response = 
        image: result
        uploaded: true

      res.setHeader 'Content-Type', 'application/json'
      res.send response

app.post '/image/:id', (req, res) ->
  imageHandler req.files.image, (err, path) ->
    return sendError(res, err) if err

    api.updateImage "/image/#{req.route.params['id']}", path, (err, result) ->
      return sendError(res, err) if err
      return res.status(404).send('Not found') unless result   

      response =
        image: result    

      res.setHeader 'Content-Type', 'application/json'
      res.send response

port = 80
app.listen port
console.log "Listening on port #{port}"


