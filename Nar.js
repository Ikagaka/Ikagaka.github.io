// Generated by CoffeeScript 1.7.1
var Nar;

Nar = (function() {
  var Encoding, JSZip, WMDescript, XHRProxy;

  XHRProxy = window["XHRProxy"] || window["XMLHttpRequest"];

  Encoding = window["Encoding"];

  JSZip = window["JSZip"];

  WMDescript = window["WMDescript"];

  function Nar() {
    this.tree = null;
  }

  Nar.prototype.loadFromBuffer = function(buffer, callback) {
    this.tree = Nar.unzip(buffer);
    return setTimeout((function(_this) {
      return function() {
        return callback(null, _this);
      };
    })(this));
  };

  Nar.prototype.loadFromURL = function(src, callback) {
    return Nar.wget(src, "arraybuffer", (function(_this) {
      return function(err, buffer) {
        if (!!err) {
          return callback(err, null);
        }
        return _this.loadFromBuffer(buffer, callback);
      };
    })(this));
  };

  Nar.unzip = function(buffer) {
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

  Nar.convert = function(buffer) {
    return Encoding.codeToString(Encoding.convert(new Uint8Array(buffer), 'UNICODE', 'AUTO'));
  };

  Nar.wget = function(url, type, callback) {
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

  Nar.readDescript = function(text) {
    return WMDescript.parse(text);
  };

  return Nar;

})();
