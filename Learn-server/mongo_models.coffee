
crypto = require 'crypto'

db = global.db
mongoose = require('mongoose')
Schema = mongoose.Schema

createHashID = ->
  crypto.createHash('sha1').update("#{Math.random()}").digest('hex');

# A description for an image
image_object = new Schema {
  url: String
  path: String
}

image_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "/image/#{id}"
  next()

module.exports.image = db.model 'Image', image_object

# A description for a user
user_object = new Schema {
  url: String
  name: String
}

user_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "/user/#{id}"
  next()

module.exports.user = db.model 'User', user_object

# A description for a collaboration entry
collaboration_entry_object = new Schema {
  url: String
  collaboration: String
  creator: { type: Schema.ObjectId, ref: 'User' }
  time: { type: Date, default: Date.now }
  body: String
  image: String
}

collaboration_entry_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "#{this.collaboration}/#{id}"
  next()

module.exports.collaboration_entry = db.model 'CollaborationEntry', collaboration_entry_object

# A description for a collaboration
collaboration_object = new Schema {
  url: String
  entries: [{ type: Schema.ObjectId, ref: 'CollaborationEntry' }]
}

collaboration_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "/collaboration/#{id}"
  next()

module.exports.collaboration = db.model 'Collaboration', collaboration_object

# A description for a page
page_object = new Schema {
  lecture: String
  url: String
  title: String
  primary: String
  secondary: String
  collaboration: String
  time: { type: Date, default: Date.now }
}

page_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "#{this.lecture}/page/#{id}"
  next()

module.exports.page = db.model 'Page', page_object

# A description for a lecture
lecture_object = new Schema {
  class: String
  name: String
  url: String
  image: String
  time: { type: Date, default: Date.now }
  pages: [{ type: Schema.ObjectId, ref: 'Page' }]
}

lecture_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "#{this.class}/lecture/#{id}"
  next()

module.exports.lecture = db.model 'Lecture', lecture_object

# A description for a class
class_object = new Schema {
  name: String
  url: String
  lectures: [{ type: Schema.ObjectId, ref: 'Lecture' }] 
}

class_object.pre 'save', (next) ->
  unless this.url
    id = createHashID()
    this.url = "/class/#{id}"
  next()

# class_object.post 'find', (doc) ->
#   module.exports.lecture.find {'class': doc.class}, (err, result) ->
#     doc

module.exports.class = db.model 'Class', class_object

