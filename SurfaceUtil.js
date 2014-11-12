// Generated by CoffeeScript 1.7.1
var SurfaceUtil;

SurfaceUtil = (function() {
  function SurfaceUtil(cnv) {
    this.cnv = cnv;
    this.ctx = this.cnv.getContext("2d");
  }

  SurfaceUtil.prototype.composeElements = function(elements) {
    var canvas, copyed, offsetX, offsetY, type, x, y, _ref;
    if (elements.length === 0) {
      return;
    }
    _ref = elements[0], canvas = _ref.canvas, type = _ref.type, x = _ref.x, y = _ref.y;
    offsetX = offsetY = 0;
    switch (type) {
      case "base":
        this.overlayfast(canvas, offsetX, offsetY);
        break;
      case "overlay":
        this.overlayfast(canvas, offsetX + x, offsetY + y);
        break;
      case "overlayfast":
        this.overlayfast(canvas, offsetX + x, offsetY + y);
        break;
      case "move":
        offsetX = x;
        offsetY = y;
        copyed = SurfaceUtil.copy(this.cnv);
        SurfaceUtil.clear(this.cnv);
        this.overlayfast(copyed, offsetX, offsetY);
        break;
      default:
        console.error(elements[0]);
        this.cnv;
    }
    this.composeElements(elements.slice(1));
    return void 0;
  };

  SurfaceUtil.prototype.overlayfast = function(part, x, y) {
    this.ctx.drawImage(part, x || 0, y || 0);
    this.cnv;
    return void 0;
  };

  SurfaceUtil.clear = function(cnv) {
    cnv.width = cnv.width;
    return void 0;
  };

  SurfaceUtil.copy = function(cnv) {
    var copy, ctx;
    copy = document.createElement("canvas");
    ctx = copy.getContext("2d");
    copy.width = cnv.width;
    copy.height = cnv.height;
    ctx.drawImage(cnv, 0, 0);
    return copy;
  };

  return SurfaceUtil;

})();
