// Generated by CoffeeScript 1.7.1
var Nar;

Nar = (function() {
  var Encoding, JSZip, URL, WMDescript, XMLHttpRequest;

  XMLHttpRequest = window["XHRProxy"];

  Encoding = window["Encoding"];

  JSZip = window["JSZip"];

  WMDescript = window["WMDescript"];

  URL = window["URL"];

  function Nar() {
    this.directory = null;
    this.install = null;
  }

  Nar.prototype.loadFromBuffer = function(buffer, callback) {
    this.directory = Nar.unzip(buffer);
    if (!this.directory["install.txt"]) {
      return callback(new Error("install.txt not found"));
    }
    return setTimeout((function(_this) {
      return function() {
        _this.install = Nar.parseDescript(Nar.convert(_this.directory["install.txt"].asArrayBuffer()));
        return callback(null);
      };
    })(this));
  };

  Nar.prototype.loadFromURL = function(src, callback) {
    return Nar.wget(src, "arraybuffer", (function(_this) {
      return function(err, buffer) {
        if (!!err) {
          return callback(err);
        }
        return _this.loadFromBuffer(buffer, callback);
      };
    })(this));
  };

  Nar.prototype.loadFromBlob = function(blob, callback) {
    var url;
    url = URL.createObjectURL(blob);
    return this.loadFromURL(url, function(err) {
      URL.revokeObjectURL(url);
      return callback(err);
    });
  };

  Nar.unzip = function(buffer) {
    var zip;
    zip = new JSZip();
    zip.load(buffer);
    return zip.files;
  };

  Nar.convert = function(buffer) {
    return Encoding.codeToString(Encoding.convert(new Uint8Array(buffer), 'UNICODE', 'AUTO'));
  };

  Nar.wget = function(url, type, callback) {
    var xhr;
    xhr = new XMLHttpRequest();
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
    xhr.open("GET", url);
    xhr.responseType = type;
    xhr.send();
    return void 0;
  };

  Nar.parseDescript = function(text) {
    return WMDescript.parse(text);
  };

  return Nar;

})();
