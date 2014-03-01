
express = require 'express'
app = express()

app.get '/classes', (req, res) ->

  response = """{
    "url": "/classes", 
    "classes": [
      {
        "url": "/class/1",
        "name": "Mobile and Autonomous Innovation",
        "lectures": [
          {
            "url": "/class/1/lecture/1",
            "name": "Lecture One",
            "image": "/class/1/lecture/1/images/thumbnail",
          },{
            "url": "/class/1/lecture/2",
            "name": "Lecture Two",
            "image": "/class/1/lecture/2/images/thumbnail",
          }
        ]
      },{
        "url": "/class/2",
        "name": "Data Communications and Wireless Practical",
        "lectures": [
          {
            "url": "/class/2/lecture/1",
            "name": "Lecture One",
            "image": "/class/2/lecture/1/images/thumbnail"
          },{
            "url": "/class/2/lecture/2",
            "name": "Lecture Two",
            "image": "/class/2/lecture/2/images/thumbnail"
          }
        ]
      },{
        "url": "/class/3",
        "name": "Information Architecture",
        "lectures": [
          {
            "url": "/class/3/lecture/1",
            "name": "Lecture One",
            "image": "/class/3/lecture/1/images/thumbnail"
          },{
            "url": "/class/3/lecture/2",
            "name": "Lecture Two",
            "image": "/class/3/lecture/2/images/thumbnail"
          }
        ]
      }
    ]
  }"""

  res.setHeader 'Content-Type', 'application/json'
  res.send response

app.get '/class/:id', (req, res) ->

  response = """{
    "url": "/class/#{req.route.params['id']}"
  }"""

  res.setHeader 'Content-Type', 'application/json'
  res.send response

app.get '/class/:classid/lecture/:lectureid', (req, res) ->

  response = """{
    "lecture": {
      "url": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}",
      "name": "Lecture One",
      "image": "/class/1/lecture/1/images/thumbnail",
      "pages": [
        {
          "url": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/1",
          "title": "Slide One",
          "primary": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/images/page-1-primary",
          "secondary": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/images/page-1-secondary",
          "notes": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/1/collaboration"
        }
      ]
    }
  }"""

  res.setHeader 'Content-Type', 'application/json'
  res.send response

app.get '/class/:classid/lecture/:lectureid/page/:pageid/collaboration', (req, res) ->
	
  response = """{
    "url": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/#{req.route.params['pageid']}/collaboration"
  }"""

  res.setHeader 'Content-Type', 'application/json'
  res.send response

app.get '/class/:classid/lecture/:lectureid/page/:pageid/collaboration/:collaborationid', (req, res) ->
	
  response = """{
    "url": "/class/#{req.route.params['classid']}/lecture/#{req.route.params['lectureid']}/page/#{req.route.params['pageid']}/collaboration/#{req.route.params['collaborationid']}"
  }"""

  res.setHeader 'Content-Type', 'application/json'
  res.send response

app.get '/class/:classid/lecture/:lectureid/images/:name', (req, res) ->

  #temporary
  res.sendfile 'files/placeholder.png'


port = 80
app.listen port
console.log "Listening on port #{port}"


