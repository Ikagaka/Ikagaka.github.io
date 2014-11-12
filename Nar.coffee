
class Nar
  XHRProxy = window["XHRProxy"] || window["XMLHttpRequest"]
  Encoding = window["Encoding"]
  JSZip = window["JSZip"]
  WMDescript = window["WMDescript"]
  constructor: ->
    @tree = null
  # Nar#loadFromBuffer(buffer:ArrayBuffer, callback:Function(err:Error|null, nar:Nar|null):void ):void
  loadFromBuffer: (buffer, callback)->
    @tree = Nar.unzip(buffer)
    setTimeout => callback(null, @)
  # Nar#loadFromBuffer(src:URLString, callback:Function(err:Error|null, nar:Nar|null):void ):void
  loadFromURL: (src, callback)->
    Nar.wget src, "arraybuffer", (err, buffer)=>
      if !!err then return callback(err, null)
      @loadFromBuffer(buffer, callback)
  # Nar.unzip(buffer:ArrayBuffer):Object
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
  # Nar.convert(buffer:ArrayBuffer):String
  @convert = (buffer)->
    Encoding.codeToString(Encoding.convert(new Uint8Array(buffer), 'UNICODE', 'AUTO'))
  # Nar.wget(url:URLString, type:"text"|"json"|"arraybuffer", callback:Function(err:Error|null, response:String|Object|ArrayBuffer):void ):void
  @wget = (url, type, callback)->
    xhr = new XHRProxy()
    xhr.addEventListener "load", ->
      if 200 <= xhr.status && xhr.status < 300
        if !!xhr.response.error
        then callback(new Error(xhr.response.error.message), null)
        else callback(null, xhr.response)
      else callback(new Error(xhr.status), null)
    xhr.open("GET", url)
    xhr.responseType = type
    xhr.send()
    undefined
  # Nar.readDescript(text:String):{[key:String]: value:String}
  @readDescript = (text)->
    WMDescript.parse(text)
