

class Named
  # new Named(shell:Shell)
  constructor: (@shell)->
    @$named = $("<div />")
      .addClass("named")
    @$style = $("<style scoped />")
      .html("")
    @$named.append(@$style)
    @element = @$named[0]
    @scopes = []
    @currentScope = null
  # Named#scope(scopeId:Number|undefined):Scope
  scope: (scopeId)->
    if scopeId isnt undefined
      if !@scopes[scopeId]
        @scopes[scopeId] = new Scope(scopeId, @shell)
      @currentScope = @scopes[scopeId]
      @$named.append(@scopes[scopeId].element)
    @currentScope
