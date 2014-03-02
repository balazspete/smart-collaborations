#API Documentation


### GET /classes
_Returns the list of classes and lectures_

__Response__
```JSON
{
  "url": "/classes"
  "classes": [
    {
      "url": "/class/{class id}"
      "name": "{class name}"
      "lectures": [
        {
          "url": "/class/{class id}/lecture/{lecture id}"
          "class": "/class/{class id}"
          "time": "{time stamp}"
        } ...
      ]
    } ...
  ]
}
```

### GET /class/{class id}
_Returns the requested class_

__Response__
```JSON
{
  "class": {
    "url": "/class/{class id}"
    "name": "{class name}"
    "lectures": [
      {
        "url": "/class/{class id}/lecture/{lecture id}"
        "class": "/class/{class id}"
        "time": "{time stamp}"
      } ...
    ]
  }
}
```

### POST /class
_Create a class_

__Request__
* `name`: `String` - Required - the name of the class

__Response__
```JSON
{
  "class": {
    "url": "/class/{class id}"
    "name": "{class name}"
    "lectures": []
  }
}
```

### POST /class/{class id}/lecture
_Create a lecture within a class_

__Request__
* `name`: `String` - Required _ The name of the lecture
* `image`: `Image URL` - Optional - The lecture image's URL

__Response__
```JSON
{
  "lecture": {
    "url": "/class/{class id}/lecture/{lecture id}"
    "class": "/class/{class id}"
    "name": "{name of the lecture}"
    "time": "{date of creation}"
    "image": "{The url to an image or null}"
    "pages": []
  }
}
```

### GET /class/{class id}/lecture/{lecture id}
_Get a lecture_

__Response__
```JSON
{
  "lecture": {
    "url": "/class/{class id}/lecture/{lecture id}"
    "class": "/class/{class id}"
    "name": "{name of the lecture}"
    "time": "{date of creation}"
    "image": "{The url to an image or null}"
    "pages": [
      {
        "url": "/class/{class id}/lecture/{lecture id}/page/{page id}"
        "lecture": "/class/{class id}/lecture/{lecture id}"
        "title": "{Page title}"
        "time": "{creation time}"
        "primary": "{A url to an image}"
        "secondary": "{A url to an image}"
        "collaboration": "{A url to a collaboration object}"
      } ...
    ]
  }
}
```

### POST /class/{class id}/lecture/{lecture id}/page
_Create a page_

__Request__
* `title`: `String` - Required - The title of the page
* `primary`: `Image URL` - Optional - The image as the primary image
* `secondary`: `Image URL` - Optional - The image as the secondary image
* `collaboration`: `Collaboration URL` - Optional - The collaboration object associated with the page

__Response__
```JSON
{
  "page": {
    "url": "/class/{class id}/lecture/{lecture id}/page/{page id}"
    "lecture": "/class/{class id}/lecture/{lecture id}"
    "title": "{Page title}"
    "time": "{creation time}"
    "primary": "{A url to an image or null}"
    "secondary": "{A url to an image or null}"
    "collaboration": "{A url to a collaboration object or null}"
  } 
}
```

### GET /class/{class id}/lecture/{lecture id}/page/{page id}
_Get a page_

__Response__
```JSON
{
  "page": {
    "url": "/class/{class id}/lecture/{lecture id}/page/{page id}"
    "lecture": "/class/{class id}/lecture/{lecture id}"
    "title": "{Page title}"
    "time": "{creation time}"
    "primary": "{A url to an image or null}"
    "secondary": "{A url to an image or null}"
    "collaboration": "{A url to a collaboration object or null}"
  } 
}
```


### POST /collaboration
_Create a collaboration_

__Request__
_No body required_

__Response__
```JSON
{
  "collaboration" : {
    "url": "/collaboration/{collaboration id}"
    "entries": []
  }
}
```

### GET /collaboration/{collaboration id}
_Get a collaboration_

__Response__
```JSON
{
  "collaboration" : {
    "url": "/collaboration/{collaboration id}"
    "entries": [
      {
        "url": "/collaboration/{collaboration id}/entry/{entry id}"
        "collaboration": "/collaboration/{collaboration id}"
        "creator": {
          "url": "/user/{user id}"
          "name": "{user name}"
        }
        "time": "{creation time}"
        "body": "{entry text or null}"
        "image": "{image url or null}"
      } ...
    ]
  }
}
```

### POST /collaboration/{collaboration id}
_Add an entry to the collaboration_

__Request__
* `user`: `User URL` - Required - The url of the creator
* `body`: `String` - Required if no `image`, otherwise optional - Text for the entry
* `image`: `Image URL` - Required if no `body`, otherwise optional - An image url

__Response__
``` JSON
{
  "collaborationEntry": {
    "url": "/collaboration/{collaboration id}/entry/{entry id}"
    "collaboration": "/collaboration/{collaboration id}"
    "creator": {
      "url": "/user/{user id}"
      "name": "{user name}"
    }
    "time": "{creation time}"
    "body": "{entry text or null}"
    "image": "{image url or null}"
  }
}
```

### GET /image/{image id}
_Download an image_

### POST /image
_Upload a new image_

__Request__
* `image`: `Image` - Required

__Response__
```JSON
{
  "image": {
    "url": "/image/{image id}"
  },
  "uploaded": true
}
```

### POST /image/{image id}
_Upload a new version of an image_

__Request__
* `image`: `Image` - Required

__Response__
```JSON
{
  "image": {
    "url": "/image/{image id}"
  },
  "uploaded": true
}
```



