
class Shell
  SurfacesTxt2Yaml = window["SurfacesTxt2Yaml"]
  jsyaml  = window["jsyaml"]

  constructor: (@nar)->
    @surfaces = null
    @descript = null
  # Shell#load(nar:Nar, callback:Function(err:Error|null, shell:Shell|null):void):void
  load: (shellName, callback)->
    tree = @nar.tree
    @descript = Nar.readDescript(Nar.convert(tree["shell"][shellName]["descript.txt"].asArrayBuffer()))
    text = Nar.convert(tree["shell"][shellName]["surfaces.txt"].asArrayBuffer())
    surfaces = Shell.parseSurfaces(text)
    merged = Shell.mergeSurfacesAndSurfacesFiles(surfaces, tree["shell"][shellName])
    Shell.loadSurfaces merged, tree["shell"][shellName], (err, loaded)=>
      if !!err then return callback(err, null)
      @surfaces = Shell.createBaseSurfaces(loaded)
      callback(null, @)
  # Shell#getSurface(scopeId:Number, surfaceId:Number|String):Surface|null
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
  # Shell.createBaseSurfaces(surfaces:SurfacesYAMLObject):SurfacesYAMLObject
  @createBaseSurfaces = (loaded)->
    srfs = loaded.surfaces
    Object.keys(srfs).forEach (name)->
      cnv = srfs[name].canvas
      if !srfs[name].elements
        srfs[name].base = cnv
      else
        sorted = Object
          .keys(srfs[name].elements)
          .sort((a, b)-> if a.is > b.is then 1 else -1)
        srfutil = new SurfaceUtil(sorted[0].canvas || srfs[name].canvas)
        srfutil.composeElements(sorted)
        srfs[name].base = srfutil
      srfs[name].canvas = null # g.c.
    loaded
  # Shell.createBaseSurfaces(surfaces:SurfacesYAMLObject, surfacesDirTree:Object, callback:Function(err:Error|null, surfaces:SurfacesYAMLObject|null):void):void
  @loadSurfaces = (merged, surfacesDir, callback)->
    srfs = merged.surfaces
    promises = Object.keys(srfs).map (name)->
      new Promise (resolve, reject)->
        buffer = srfs[name].file.asArrayBuffer()
        url = Shell.bufferToURL(buffer, "image/png")
        Shell.loadImage url, (err, img)->
          if !!err then return reject(err)
          srfs[name].file = null # g.c.
          transed = Shell.transImage(img)
          srfs[name].canvas = transed
          if !srfs[name].elements
          then resolve()
          else
            _promises = Object.keys(srfs[name].elements).map (elm)->
              new Promise (_resolve, _reject)->
                {is:_is, type, file, x, y} = elm
                buffer = surfacesDir[file].asArrayBuffer()
                url = Shell.bufferToURL(buffer)
                Shell.loadImage url, (err, img)->
                  if !!err then return _reject(err.error)
                  _transed = Shell.transImage(img)
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
  # Shell.transImage(img:HTMLCanvasElement|HTMLImageElement):HTMLCanvasElement
  @transImage = (img)->
    cnv = SurfaceUtil.copy(img)
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
  # Shell.transImage(url:URLString, callback:Function(err:Error|null, img:HTMLImageElement|null):void):void
  @loadImage = (url, callback)->
    img = new Image
    img.src = url
    img.addEventListener "load", -> callback(null, img)
    img.addEventListener "error", (ev)-> console.error(ev); callback(ev.error, null)
    undefined
  # Shell.bufferToURL(buffer:ArrayBuffer, type:MimeTypeString):BlobURLString
  @bufferToURL = (buffer, type)->
    URL.createObjectURL(new Blob([buffer], {type}))
  # Shell.mergeSurfacesAndSurfacesFiles(surfaces:SurfacesYAMLObject, surfacesDirTree:Object):SurfacesYAMLObject
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
  # Shell.parseSurfaces(text:SurfacesTxtString):SurfacesYAMLObject
  @parseSurfaces = (text)->
    yaml = SurfacesTxt2Yaml.txt_to_yaml(text)
    jsyaml.load(yaml)
