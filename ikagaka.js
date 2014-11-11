// Generated by CoffeeScript 1.7.1
var Ikagaka, Surface;

Surface = (function() {
  var $;

  $ = window["Zepto"] || window["jQuery"];

  function Surface(scopeId, srf, surfaces) {
    this.scopeId = scopeId;
    this.surfaces = surfaces;
    this.is = srf.is;
    this.base = srf.base;
    this.regions = srf.regions;
    this.animations = srf.animations;
    console.log(srf);
    this.canvas = Ikagaka.copyCanvas(this.base);
    this.destructed = false;
    this.layers = [];
    this.listener = function() {};
    $(this.canvas).on("click", (function(_this) {
      return function(ev) {
        return Surface.processMouseEvent(ev, _this.scopeId, _this.regions, "OnMouseClick", function(ev) {
          return _this.listener(ev);
        });
      };
    })(this));
    $(this.canvas).on("dblclick", (function(_this) {
      return function(ev) {
        return Surface.processMouseEvent(ev, _this.scopeId, _this.regions, "OnDoubleMouseClick", function(ev) {
          return _this.listener(ev);
        });
      };
    })(this));
    $(this.canvas).on("mousemove", (function(_this) {
      return function(ev) {
        return Surface.processMouseEvent(ev, _this.scopeId, _this.regions, "OnMouseMove", function(ev) {
          return _this.listener(ev);
        });
      };
    })(this));
    $(this.canvas).on("mousedown", (function(_this) {
      return function(ev) {
        return Surface.processMouseEvent(ev, _this.scopeId, _this.regions, "OnMouseDown", function(ev) {
          return _this.listener(ev);
        });
      };
    })(this));
    $(this.canvas).on("mouseup", (function(_this) {
      return function(ev) {
        return Surface.processMouseEvent(ev, _this.scopeId, _this.regions, "OnMouseUp", function(ev) {
          return _this.listener(ev);
        });
      };
    })(this));
    Object.keys(this.animations).forEach((function(_this) {
      return function(name) {
        var interval, n, pattern, tmp, _is, _ref;
        _ref = _this.animations[name], _is = _ref.is, interval = _ref.interval, pattern = _ref.pattern;
        console.log(interval);
        tmp = interval.split(",");
        interval = tmp[0];
        n = Number(tmp.slice(1).join(","));
        switch (interval) {
          case "sometimes":
            return _this.sometimes(_is);
          case "rarely":
            return _this.rarely(_is);
          case "random":
            return _this.random(_is, n);
          case "runonce":
            return _this.runonce(_is);
          case "always":
            return _this.always(_is);
        }
      };
    })(this));

    /*
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
     */
  }

  Surface.prototype.setEventListener = function(listener) {
    this.listener = listener;
  };

  Surface.prototype.destructor = function() {
    $(this.canvas).off();
    this.stopAnimation();
    this.destructed = true;
    this.base = null;
    return this.canvas = null;
  };

  Surface.prototype.sometimes = function(animationId) {
    return this.random(animationId, 2);
  };

  Surface.prototype.rarely = function(animationId) {
    return this.random(animationId, 4);
  };

  Surface.prototype.random = function(animationId, n) {
    var ms;
    if (!this.destructed) {
      ms = 1;
      while (Math.round(Math.random() * 1000) > 1000 / n) {
        ms++;
      }
      return setTimeout((function(_this) {
        return function() {
          return _this.playAnimation(animationId, function() {
            return _this.random(animationId, n);
          });
        };
      })(this), ms * 1000);
    }
  };

  Surface.prototype.runonce = function(animationId) {
    if (!this.destructed) {
      return this.playAnimation(animationId, function() {});
    }
  };

  Surface.prototype.always = function(animationId) {
    if (!this.destructed) {
      return this.playAnimation(animationId, (function(_this) {
        return function() {
          return _this.always(animationId);
        };
      })(this));
    }
  };

  Surface.prototype.playAnimation = function(id, callback) {
    console.log(id);
    return setTimeout((function() {
      return callback();
    }), 0);
  };

  Surface.prototype.stopAnimation = function(id) {};

  Surface.processMouseEvent = function(ev, scopeId, regions, eventName, listener) {
    var event, left, offsetX, offsetY, top, _ref;
    _ref = $(ev.target).offset(), left = _ref.left, top = _ref.top;
    offsetX = ev.pageX - left;
    offsetY = ev.pageY - top;
    if (Surface.isHit(ev.target, offsetX, offsetY)) {
      ev.preventDefault();
      event = Surface.createMouseEvent(eventName, scopeId, regions, offsetX, offsetY);
      if (!!event["Reference4"]) {
        $(ev.target).css({
          "cursor": "pointer"
        });
      } else {
        $(ev.target).css({
          "cursor": "default"
        });
      }
      return listener(event);
    }
  };

  Surface.createMouseEvent = function(eventName, scopeId, regions, offsetX, offsetY) {
    var event, hits;
    event = {
      "ID": eventName,
      "Reference0": offsetX,
      "Reference1": offsetY,
      "Reference2": 0,
      "Reference3": scopeId,
      "Reference4": "",
      "Reference5": 0
    };
    hits = Object.keys(regions).slice().sort(function(a, b) {
      if (a.is > b.is) {
        return 1;
      } else {
        return -1;
      }
    }).filter(function(name) {
      var bottom, left, right, top, _ref;
      _ref = regions[name], name = _ref.name, left = _ref.left, top = _ref.top, right = _ref.right, bottom = _ref.bottom;
      return ((left < offsetX && offsetX < right) && (top < offsetY && offsetY < bottom)) || ((right < offsetX && offsetX < left) && (bottom < offsetY && offsetY < top));
    });
    if (hits.length !== 0) {
      event["Reference4"] = regions[hits[hits.length - 1]].name;
    }
    return event;
  };

  Surface.isHit = function(canvas, x, y) {
    var ctx, data, imgdata;
    ctx = canvas.getContext("2d");
    imgdata = ctx.getImageData(0, 0, x, y);
    data = imgdata.data;
    return data[data.length - 1] !== 0;
  };

  return Surface;

})();

Ikagaka = (function() {
  var Encoding, JSZip, SurfacesTxt2Yaml, XHRProxy, jsyaml;

  XHRProxy = window["XHRProxy"];

  Encoding = window["Encoding"];

  JSZip = window["JSZip"];

  SurfacesTxt2Yaml = window["SurfacesTxt2Yaml"];

  jsyaml = window["jsyaml"];

  function Ikagaka(src, callback) {
    this.tree = null;
    this.surfaces = null;
    Ikagaka.wget(src, "arraybuffer", (function(_this) {
      return function(err, buffer) {
        var merged, surfaces, text, tree;
        if (!!err) {
          return callback(err, null);
        }
        tree = Ikagaka.unzip(buffer);
        text = Ikagaka.convert(tree["shell"]["master"]["surfaces.txt"].asArrayBuffer());
        surfaces = Ikagaka.parseSurfaces(text);
        merged = Ikagaka.mergeSurfacesAndSurfacesFiles(surfaces, tree["shell"]["master"]);
        return Ikagaka.loadSurfaces(merged, tree["shell"]["master"], function(err, loaded) {
          var composed;
          if (!!err) {
            return callback(err, null);
          }
          composed = Ikagaka.composeBaseSurfaces(loaded);
          _this.tree = tree;
          _this.surfaces = composed;
          return callback(null, _this);
        });
      };
    })(this));
  }

  Ikagaka.prototype.getSurface = function(scopeId, surfaceId) {
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

  Ikagaka.composeBaseSurfaces = function(loaded) {
    var srfs;
    srfs = loaded.surfaces;
    Object.keys(srfs).forEach(function(name) {
      var base, cnv, sorted;
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
        base = Ikagaka.composeElements(sorted[0].canvas || srfs[name].canvas, sorted);
        srfs[name].base = base;
      }
      return srfs[name].canvas = null;
    });
    return loaded;
  };

  Ikagaka.loadSurfaces = function(merged, surfacesDir, callback) {
    var promises, srfs;
    srfs = merged.surfaces;
    promises = Object.keys(srfs).map(function(name) {
      return new Promise(function(resolve, reject) {
        var buffer, url;
        buffer = srfs[name].file.asArrayBuffer();
        url = Ikagaka.bufferToURL(buffer, "image/png");
        return Ikagaka.loadImage(url, function(err, img) {
          var transed, _promises;
          if (!!err) {
            return reject(err);
          }
          srfs[name].file = null;
          transed = Ikagaka.transImage(img);
          srfs[name].canvas = transed;
          if (!srfs[name].elements) {
            return resolve();
          } else {
            _promises = Object.keys(srfs[name].elements).map(function(elm) {
              return new Promise(function(_resolve, _reject) {
                var file, type, x, y, _is;
                _is = elm.is, type = elm.type, file = elm.file, x = elm.x, y = elm.y;
                buffer = surfacesDir[file].asArrayBuffer();
                url = Ikagaka.bufferToURL(buffer);
                return Ikagaka.loadImage(url, function(err, img) {
                  var _transed;
                  if (!!err) {
                    return _reject(err.error);
                  }
                  _transed = Ikagaka.transImage(img);
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

  Ikagaka.composeElements = function(target, elements) {
    var canvas, comporsed, file, type, x, y, _is, _ref;
    if (elements.length === 0) {
      return target;
    } else {
      _ref = elements[0], canvas = _ref.canvas, _is = _ref.is, file = _ref.file, type = _ref.type, x = _ref.x, y = _ref.y;
      comporsed = (function() {
        switch (type) {
          case "base":
            return Ikagaka.copyCanvas(canvas);
          case "overlay":
            return Ikagaka.overlayfastCanvas(target, canvas, x, y);
          case "overlayfast":
            return Ikagaka.overlayfastCanvas(target, canvas, x, y);
        }
      })();
      return Ikagaka.composeElements(comporsed, elements.slice(1));
    }
  };

  Ikagaka.overlayfastCanvas = function(base, part, x, y) {
    var ctx;
    ctx = base.getContext("2d");
    ctx.drawImage(part, x || 0, y || 0);
    return target;
  };

  Ikagaka.transImage = function(img) {
    var a, b, cnv, ctx, data, g, i, imgdata, r;
    cnv = Ikagaka.copyCanvas(img);
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

  Ikagaka.copyCanvas = function(cnv) {
    var copy, ctx;
    copy = document.createElement("canvas");
    ctx = copy.getContext("2d");
    copy;
    copy.width = cnv.width;
    copy.height = cnv.height;
    ctx.drawImage(cnv, 0, 0);
    return copy;
  };

  Ikagaka.loadImage = function(url, callback) {
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

  Ikagaka.bufferToURL = function(buffer, type) {
    return URL.createObjectURL(new Blob([buffer], {
      type: type
    }));
  };

  Ikagaka.mergeSurfacesAndSurfacesFiles = function(surfaces, surfacesDir) {
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

  Ikagaka.parseSurfaces = function(text) {
    var yaml;
    yaml = SurfacesTxt2Yaml.txt_to_yaml(text);
    return jsyaml.load(yaml);
  };

  Ikagaka.unzip = function(buffer) {
    var ary, dir, files, i, obj, parent, path, root, val, zip, _i, _len;
    zip = new JSZip();
    zip.load(buffer);
    files = zip.files;
    parent = root = {};
    for (path in files) {
      val = files[path];
      ary = path.split("/");
      for (i = _i = 0, _len = ary.length; _i < _len; i = ++_i) {
        dir = ary[i];
        obj = i === ary.length - 1 ? val : {};
        parent = parent[dir] = parent[dir] || obj;
      }
      parent = root;
    }
    return root;
  };

  Ikagaka.convert = function(buffer) {
    return Encoding.codeToString(Encoding.convert(new Uint8Array(buffer), 'UNICODE', 'AUTO'));
  };

  Ikagaka.wget = function(url, type, callback) {
    var xhr;
    xhr = new XHRProxy();
    xhr.addEventListener("load", function() {
      if (200 <= xhr.status && xhr.status < 300) {
        if (!!xhr.response.error) {
          return callback(new Error(xhr.response.error.message), null);
        } else {
          return callback(null, xhr.response);
        }
      } else {
        return callback(new Error(xhr.status), null);
      }
    });
    xhr.responseType = type;
    xhr.open("GET", url);
    xhr.send();
    return void 0;
  };

  return Ikagaka;

})();
