class Surface
  $ = window["Zepto"] || window["jQuery"]
  constructor: (@scopeId, srf, @surfaces)->
    @is = srf.is
    @base = srf.base
    @regions = srf.regions
    @animations = srf.animations
    console.log srf
    @canvas = Ikagaka.copyCanvas(@base)
    @destructed = false
    @layers = []
    @listener = ->
    $(@canvas).on "click", (ev)=>
      Surface.processMouseEvent(ev, @scopeId, @regions, "OnMouseClick", (ev)=> @listener(ev))
    $(@canvas).on "dblclick", (ev)=>
      Surface.processMouseEvent(ev, @scopeId, @regions, "OnDoubleMouseClick", (ev)=> @listener(ev))
    $(@canvas).on "mousemove", (ev)=>
      Surface.processMouseEvent(ev, @scopeId, @regions, "OnMouseMove", (ev)=> @listener(ev))
    $(@canvas).on "mousedown", (ev)=>
      Surface.processMouseEvent(ev, @scopeId, @regions, "OnMouseDown", (ev)=> @listener(ev))
    $(@canvas).on "mouseup", (ev)=>
      Surface.processMouseEvent(ev, @scopeId, @regions, "OnMouseUp", (ev)=> @listener(ev))
    Object
      .keys(@animations)
      .forEach (name)=>
        {is:_is, interval, pattern} = @animations[name]
        console.log interval
        tmp = interval.split(",")
        interval = tmp[0]
        n = Number(tmp.slice(1).join(","))
        switch interval
          when "sometimes" then @sometimes(_is)
          when "rarely"    then @rarely(_is)
          when "random"    then @random(_is, n)
          when "runonce"   then @runonce(_is)
          when "always"    then @always(_is)
    ###
    do animate = =>
      srfs = @surfaces.surfaces
      @layers.forEach (layer)=>
        {surface, type, wait, x, y} = layer
        ovelay = Object
          .keys(srfs)
          .filter((srf)-> srf.is is surface)
        ovelay
        surface

      requestAnimationFrame(animate)
    ###
  setEventListener: (@listener)->
  destructor: ->
    $(@canvas).off() # g.c.
    @stopAnimation()
    @destructed = true
    @base = null
    @canvas = null
  sometimes: (animationId)-> @random(animationId, 2)
  rarely: (animationId)-> @random(animationId, 4)
  random: (animationId, n)->
    if !@destructed
      ms = 1
      ms++ while Math.round(Math.random() * 1000) > 1000/n
      setTimeout(=>
        @playAnimation animationId, =>
          @random(animationId, n)
      , ms*1000)
  runonce: (animationId)->
    if !@destructed
      @playAnimation(animationId, ->)
  always: (animationId)->
    if !@destructed
      @playAnimation(animationId, => @always(animationId))
  playAnimation: (id, callback)->
    console.log(id)
    setTimeout((->callback()), 0)
  stopAnimation: (id)->
  @processMouseEvent = (ev, scopeId, regions, eventName, listener)->
    {left, top} = $(ev.target).offset()
    offsetX = ev.pageX - left
    offsetY = ev.pageY - top
    if Surface.isHit(ev.target, offsetX, offsetY)
      ev.preventDefault()
      event = Surface.createMouseEvent(eventName, scopeId, regions, offsetX, offsetY)
      if !!event["Reference4"]
      then $(ev.target).css({"cursor": "pointer"})
      else $(ev.target).css({"cursor": "default"})
      listener(event)
  @createMouseEvent = (eventName, scopeId, regions, offsetX, offsetY)->
    event =
      "ID": eventName
      "Reference0": offsetX
      "Reference1": offsetY
      "Reference2": 0
      "Reference3": scopeId
      "Reference4": ""
      "Reference5": 0
    hits = Object
      .keys(regions)
      .slice().sort((a, b)-> if a.is > b.is then 1 else -1)
      .filter((name)->
        {name, left, top, right, bottom} = regions[name]
        (left < offsetX < right and top < offsetY < bottom) or
        (right < offsetX < left and bottom < offsetY < top))
    if hits.length isnt 0
      event["Reference4"] = regions[hits[hits.length-1]].name
    event
  @isHit = (canvas, x, y)->
    ctx = canvas.getContext "2d"
    imgdata = ctx.getImageData(0, 0, x, y)
    data = imgdata.data
    data[data.length-1] isnt 0

class Ikagaka
  XHRProxy = window["XHRProxy"]
  Encoding = window["Encoding"]
  JSZip = window["JSZip"]
  SurfacesTxt2Yaml = window["SurfacesTxt2Yaml"]
  jsyaml  = window["jsyaml"]
  constructor: (src, callback)->
    @tree = null
    @surfaces = null
    Ikagaka.wget src, "arraybuffer", (err, buffer)=>
      if !!err then return callback(err, null)
      tree = Ikagaka.unzip(buffer)
      text = Ikagaka.convert tree["shell"]["master"]["surfaces.txt"].asArrayBuffer()
      surfaces = Ikagaka.parseSurfaces(text)
      merged = Ikagaka.mergeSurfacesAndSurfacesFiles(surfaces, tree["shell"]["master"])
      Ikagaka.loadSurfaces merged, tree["shell"]["master"], (err, loaded)=>
        if !!err then return callback(err, null)
        composed = Ikagaka.composeBaseSurfaces(loaded)
        @tree = tree
        @surfaces = composed
        callback(null, @)
  getSurface: (scopeId, surfaceId)->
    # alias choice process with scopeID
    # @surfaces.sakrua
    n = surfaceId
    srfs = @surfaces.surfaces
    hits = Object
      .keys(srfs)
      .filter((name)-> srfs[name].is is n)
    if hits.length is 0
    then return null
    new Surface(scopeId, srfs[hits[0]], @surfaces)
  @composeBaseSurfaces = (loaded)->
    srfs = loaded.surfaces
    Object.keys(srfs).forEach (name)->
      cnv = srfs[name].canvas
      if !srfs[name].elements
        srfs[name].base = cnv
      else
        sorted = Object
          .keys(srfs[name].elements)
          .sort((a, b)-> if a.is > b.is then 1 else -1)
        base = Ikagaka.composeElements(sorted[0].canvas || srfs[name].canvas, sorted)
        srfs[name].base = base
      srfs[name].canvas = null # g.c.
    loaded
  @loadSurfaces = (merged, surfacesDir, callback)->
    srfs = merged.surfaces
    promises = Object.keys(srfs).map (name)->
      new Promise (resolve, reject)->
        buffer = srfs[name].file.asArrayBuffer()
        url = Ikagaka.bufferToURL(buffer, "image/png")
        Ikagaka.loadImage url, (err, img)->
          if !!err then return reject(err)
          srfs[name].file = null # g.c.
          transed = Ikagaka.transImage(img)
          srfs[name].canvas = transed
          if !srfs[name].elements
          then resolve()
          else
            _promises = Object.keys(srfs[name].elements).map (elm)->
              new Promise (_resolve, _reject)->
                {is:_is, type, file, x, y} = elm
                buffer = surfacesDir[file].asArrayBuffer()
                url = Ikagaka.bufferToURL(buffer)
                Ikagaka.loadImage url, (err, img)->
                  if !!err then return _reject(err.error)
                  _transed = Ikagaka.transImage(img)
                  elm.canvas = transed
                  _resolve()
            Promise
              .all(_promises)
              .then(resolve)
              .catch(reject)
    Promise
      .all(promises)
      .then(-> callback(null, merged))
      .catch((err)-> console.error(err, err.stack); callback(err, null))
    undefined
  @composeElements = (target, elements)->
    if elements.length is 0
    then target
    else
      {canvas, is:_is, file, type, x, y} = elements[0]
      comporsed = switch type
        when "base"    then Ikagaka.copyCanvas(canvas)
        when "overlay" then Ikagaka.overlayfastCanvas(target, canvas, x, y)
        when "overlayfast" then Ikagaka.overlayfastCanvas(target, canvas, x, y)
      Ikagaka.composeElements(comporsed, elements.slice(1))
  @overlayfastCanvas = (base, part, x, y)->
    ctx = base.getContext("2d")
    ctx.drawImage(part, x||0, y||0)
    target
  @transImage = (img)->
    cnv = Ikagaka.copyCanvas(img)
    ctx = cnv.getContext("2d")
    imgdata = ctx.getImageData(0, 0, img.width, img.height)
    data = imgdata.data
    [r, g, b, a] = data
    i = 0
    if a isnt 0
      while i < data.length
        if r is data[i] and
           g is data[i+1] and
           b is data[i+2]
          data[i+3] = 0
        i += 4
    ctx.putImageData(imgdata, 0, 0)
    cnv
  @copyCanvas = (cnv)->
    copy = document.createElement("canvas")
    ctx = copy.getContext("2d")
    copy
    copy.width  = cnv.width
    copy.height = cnv.height
    ctx.drawImage(cnv, 0, 0)
    copy
  @loadImage = (url, callback)->
    img = new Image
    img.src = url
    img.addEventListener "load", -> callback(null, img)
    img.addEventListener "error", (ev)-> console.error(ev); callback(ev.error, null)
    undefined
  @bufferToURL = (buffer, type)->
    URL.createObjectURL(new Blob([buffer], {type}))
  @mergeSurfacesAndSurfacesFiles = (surfaces, surfacesDir)->
    Object
      .keys(surfacesDir)
      .filter((filename)-> /^surface\d+\.png$/i.test(filename))
      .map((filename)-> [Number((/^surface(\d+)\.png$/i.exec(filename) or ["", "-1"])[1]), surfacesDir[filename]])
      .reduce(((surfaces, [n, file])->
        name = "surface" + n
        srfs = surfaces.surfaces
        if !srfs[name]
          srfs[name] = {is: n}
        srfs[name].file = file
        srfs[name].canvas = null
        srfs[name].base = null
        surfaces
      ), surfaces)
  @parseSurfaces = (text)->
    yaml = SurfacesTxt2Yaml.txt_to_yaml(text)
    jsyaml.load(yaml)
  @unzip = (buffer)->
    zip = new JSZip()
    zip.load(buffer)
    files = zip.files
    parent = root = {}
    for path, val of files
      ary = path.split("/")
      for dir, i in ary
        obj = if i is ary.length - 1 then val else {}
        parent = parent[dir] = parent[dir] or obj
      parent = root
    root
  @convert = (buffer)->
    Encoding.codeToString(Encoding.convert(new Uint8Array(buffer), 'UNICODE', 'AUTO'))
  @wget = (url, type, callback)->
    xhr = new XHRProxy()
    xhr.addEventListener "load", ->
      if 200 <= xhr.status && xhr.status < 300
        if !!xhr.response.error
        then callback(new Error(xhr.response.error.message), null)
        else callback(null, xhr.response)
      else callback(new Error(xhr.status), null)
    xhr.responseType = type
    xhr.open("GET", url)
    xhr.send()
    undefined
