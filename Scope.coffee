

class Scope
  constructor: (@scopeId)->
    @$scope = $("<div />").addClass("scope").css({"bottom": "0px", "right": (@scopeId*240)+"px"})
    @$balloon = $("<div />").addClass("balloon")
    @$scope
      .append(@surface.canvas)
      .append(@$balloon)
  surface: ()->
  baloon: ()->
