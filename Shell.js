// Generated by CoffeeScript 1.7.1
var Shell;

Shell = (function() {
  var SurfacesTxt2Yaml, jsyaml;

  SurfacesTxt2Yaml = window["SurfacesTxt2Yaml"];

  jsyaml = window["jsyaml"];

  function Shell(nar) {
    this.nar = nar;
    this.surfaces = null;
    this.descript = null;
  }

  Shell.prototype.load = function(shellName, callback) {
    var merged, surfaces, text, tree;
    tree = this.nar.tree;
    this.descript = Nar.readDescript(Nar.convert(tree["shell"][shellName]["descript.txt"].asArrayBuffer()));
    text = Nar.convert(tree["shell"][shellName]["surfaces.txt"].asArrayBuffer());
    surfaces = Shell.parseSurfaces(text);
    merged = Shell.mergeSurfacesAndSurfacesFiles(surfaces, tree["shell"][shellName]);
    return Shell.loadSurfaces(merged, tree["shell"][shellName], (function(_this) {
      return function(err, loaded) {
        if (!!err) {
          return callback(err, null);
        }
        _this.surfaces = Shell.createBaseSurfaces(loaded);
        return callback(null, _this);
      };
    })(this));
  };

  Shell.prototype.getSurface = function(scopeId, surfaceId) {
    var hits, n, srfs;
    n = surfaceId;
    srfs = this.surfaces.surfaces;
    hits = Object.keys(srfs).filter(function(name) {
      return srfs[name].is === n;
    });
    if (hits.length === 0) {
      return null;
    }
    return new Surface(scopeId, srfs[hits[0]], this.surfaces);
  };

  Shell.createBaseSurfaces = function(loaded) {
    var srfs;
    srfs = loaded.surfaces;
    Object.keys(srfs).forEach(function(name) {
      var cnv, sorted, srfutil;
      cnv = srfs[name].canvas;
      if (!srfs[name].elements) {
        srfs[name].base = cnv;
      } else {
        sorted = Object.keys(srfs[name].elements).sort(function(a, b) {
          if (a.is > b.is) {
            return 1;
          } else {
            return -1;
          }
        });
        srfutil = new SurfaceUtil(sorted[0].canvas || srfs[name].canvas);
        srfutil.composeElements(sorted);
        srfs[name].base = srfutil;
      }
      return srfs[name].canvas = null;
    });
    return loaded;
  };

  Shell.loadSurfaces = function(merged, surfacesDir, callback) {
    var promises, srfs;
    srfs = merged.surfaces;
    promises = Object.keys(srfs).map(function(name) {
      return new Promise(function(resolve, reject) {
        var buffer, url;
        buffer = srfs[name].file.asArrayBuffer();
        url = Shell.bufferToURL(buffer, "image/png");
        return Shell.loadImage(url, function(err, img) {
          var transed, _promises;
          if (!!err) {
            return reject(err);
          }
          srfs[name].file = null;
          transed = Shell.transImage(img);
          srfs[name].canvas = transed;
          if (!srfs[name].elements) {
            return resolve();
          } else {
            _promises = Object.keys(srfs[name].elements).map(function(elm) {
              return new Promise(function(_resolve, _reject) {
                var file, type, x, y, _is;
                _is = elm.is, type = elm.type, file = elm.file, x = elm.x, y = elm.y;
                buffer = surfacesDir[file].asArrayBuffer();
                url = Shell.bufferToURL(buffer);
                return Shell.loadImage(url, function(err, img) {
                  var _transed;
                  if (!!err) {
                    return _reject(err.error);
                  }
                  _transed = Shell.transImage(img);
                  elm.canvas = transed;
                  return _resolve();
                });
              });
            });
            return Promise.all(_promises).then(resolve)["catch"](reject);
          }
        });
      });
    });
    Promise.all(promises).then(function() {
      return callback(null, merged);
    })["catch"](function(err) {
      console.error(err, err.stack);
      return callback(err, null);
    });
    return void 0;
  };

  Shell.transImage = function(img) {
    var a, b, cnv, ctx, data, g, i, imgdata, r;
    cnv = SurfaceUtil.copy(img);
    ctx = cnv.getContext("2d");
    imgdata = ctx.getImageData(0, 0, img.width, img.height);
    data = imgdata.data;
    r = data[0], g = data[1], b = data[2], a = data[3];
    i = 0;
    if (a !== 0) {
      while (i < data.length) {
        if (r === data[i] && g === data[i + 1] && b === data[i + 2]) {
          data[i + 3] = 0;
        }
        i += 4;
      }
    }
    ctx.putImageData(imgdata, 0, 0);
    return cnv;
  };

  Shell.loadImage = function(url, callback) {
    var img;
    img = new Image;
    img.src = url;
    img.addEventListener("load", function() {
      return callback(null, img);
    });
    img.addEventListener("error", function(ev) {
      console.error(ev);
      return callback(ev.error, null);
    });
    return void 0;
  };

  Shell.bufferToURL = function(buffer, type) {
    return URL.createObjectURL(new Blob([buffer], {
      type: type
    }));
  };

  Shell.mergeSurfacesAndSurfacesFiles = function(surfaces, surfacesDir) {
    return Object.keys(surfacesDir).filter(function(filename) {
      return /^surface\d+\.png$/i.test(filename);
    }).map(function(filename) {
      return [Number((/^surface(\d+)\.png$/i.exec(filename) || ["", "-1"])[1]), surfacesDir[filename]];
    }).reduce((function(surfaces, _arg) {
      var file, n, name, srfs;
      n = _arg[0], file = _arg[1];
      name = "surface" + n;
      srfs = surfaces.surfaces;
      if (!srfs[name]) {
        srfs[name] = {
          is: n
        };
      }
      srfs[name].file = file;
      srfs[name].canvas = null;
      srfs[name].base = null;
      return surfaces;
    }), surfaces);
  };

  Shell.parseSurfaces = function(text) {
    var yaml;
    yaml = SurfacesTxt2Yaml.txt_to_yaml(text);
    return jsyaml.load(yaml);
  };

  return Shell;

})();
