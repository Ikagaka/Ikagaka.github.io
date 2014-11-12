

class Scope
  # new Scope(scopeId:Number, shell:Shell):Scope
  constructor: (@scopeId, @shell)->
    @$scope = $("<div />")
      .addClass("scope")
      .css({"bottom": "0px", "right": (@scopeId*240)+"px"})
    @$surface= $("<div />")
      .addClass("surface")
    @$balloon = $("<div />")
      .addClass("balloon")
    @$scope
      .append(@$surface)
      .append(@$balloon)
    @element = @$scope[0]
    @currentSurface = null
    @currentBalloon = null
  # Scope#surface(surfaceId:Number|Undefined):Surface|null
  surface: (surfaceId)->
    if arguments.length is 1
      $(@currentSurface.canvas).remove() if !!@currentSurface
      @currentSurface = @shell.getSurface(@scopeId, surfaceId)
      @$surface.append(@currentSurface.canvas)
    @currentSurface
  # Scope#baloon(balloonId:Number|Undefined):Balloon
  baloon: (balloonId)->
    if arguments.length is 1
      @currentBalloon
    @currentBalloon
