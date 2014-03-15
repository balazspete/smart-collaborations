
models = require './mongo_models'

module.exports.getSummary = (callback) ->
  models.class
    .find()
    .populate('lectures')
    .exec (error, result) ->
      callback error, result

module.exports.getClass = (url, callback) ->
  models.class
    .findOne({'url': url})
    .populate('lectures')
    .exec(callback)

module.exports.saveClass = (name, callback) ->
  c = new models.class { name: name }
  c.save callback

module.exports.getLecture = (url, callback) ->
  models.lecture
    .findOne({ 'url': url })
    .populate('pages')
    .exec callback

module.exports.saveLecture = (c, name, image, callback) ->
  l = new models.lecture { class: c, name: name, image: image }
  l.save (err, result) ->
    return callback(err) if err

    models.class.findOne {url:result.class}, (_err, c) ->
      return callback(_err) if _err

      c.lectures.push result._id
      c.save (_err2, _c) ->
        return callback(_err2) if _err2
        callback null, result

module.exports.getPage = (url, callback) ->
  models.page
    .findOne({ 'url': url })
    .exec callback

module.exports.savePage = (lecture, title, primary, secondary, notes, callback) ->
  p = new models.page { 
    lecture: lecture 
    title: title
    primary: primary
    secondary: secondary
    notes: notes
  }
  p.save (err, result) ->
    return callback(err) if err

    models.lecture.findOne { url:result.lecture }, (_err, l) ->
      return callback(_err) if _err
      l.pages.push result._id
      l.save (_err2, _l) ->
        return callback(_err2) if _err2
        callback null, result

module.exports.updatePage = (url, title, primary, secondary, collaboration, callback) ->
  models.page.findOne {url: url}, (err, result) ->
    return callback(err) if err

    result.title = title if title
    result.primary = primary if primary
    result.secondary = secondary if secondary
    result.collaboration = collaboration if collaboration

    result.save callback

module.exports.getCollaboration = (url, callback) ->
  models.collaboration
    .findOne({ url: url })
    .populate('entries')
    .exec (err, result) ->
      return callback(err) if err
      models.collaboration_entry.populate result.entries, {path: 'creator'}, (_err, result) ->
        return callback(_err) if _err
        console.log result
        callback null, { url: url, entries: result }

module.exports.createCollaboration = (callback) ->
  c = new models.collaboration()
  c.save callback

module.exports.createCollaborationEntry = (collaboration, user, body, image, callback) ->
  models.user
    .findOne({ "url": user })
    .exec (err, result) ->
      return callback(err) if err
      e = new models.collaboration_entry {
        collaboration: collaboration
        creator: result._id
        body: body
        image: image
      }
      e.save (_err, _result) ->
        return callback(_err) if _err
        models.collaboration
          .findOne({ url: collaboration })
          .populate('creator')
          .exec (e, r) ->
            return callback(e) if e
            console.log r
            r.entries.push _result._id
            r.save (_e, _r) ->
              return callback(_e) if _e
              models.collaboration_entry
                .findOne({url: _result.url})
                .populate('creator')
                .exec callback

module.exports.createImage = (path, callback) ->
  i = new models.image {
    path: path
  }
  i.save callback

module.exports.updateImage = (url, path, callback) ->
  models.image.findOne { url: url }, (err, image) ->
    image.path = path
    image.save callback

module.exports.getImage = (url, callback) ->
  models.image
    .findOne({ url: url })
    .exec callback

module.exports.createUser = (name, callback) ->
  i = new models.user {
    name: name
  }
  i.save callback

module.exports.createDevice = (callback) ->
  d = new models.device()
  d.save callback

module.exports.getDevice = (url, checkin, callback) ->
  models.device
    .findOne({ url: url })
    .populate('tasks')
    .exec (err, device) ->
      return callback err if err
      callback null, device #call back here, do update async
      return unless checkin
      device.checkin = new Date()
      device.save (e, d)->
        console.log e if e
        console.log d.checkin

module.exports.createTask = (device, image, callback) ->
  t = new models.task {
    device: device
    image: image
  }
  t.save (err, task) ->
    return callback(err) if err
    models.device
      .findOne({ url: device })
      .exec (_e, d) ->
        return callback(_e) if _e
        d.tasks.push task._id
        d.save (_e2, r) ->
          return callback(_e2) if _e2
          callback null, task

module.exports.updateTask = (url, completed, callback) ->
  models.task
    .findOne({ url: url })
    .exec (err, task) ->
      return callback err if err
      task.completed = completed
      task.save (_err, result) ->
        return callback _err if _err
        callback null, result


