

class Named
  # new Named(shell:Shell)
  constructor: (@shell)->
    @$named = $("<div />")
      .addClass("named")
    @$style = $("<style scoped />")
      .html("""
      .named .scope{
        position: absolute;
        border: none;
        margin: 0px;
        padding: 0px;
        -webkit-user-select:none;
        -webkit-tap-highlight-color:transparent;
      }
      .anchor,.select{
        color:red;
        cursor:pointer;
      }
      .anchor:hover,.select:hover{
        background-color:violet;
      }
      """)
    @$named.append(@$style)
    @element = @$named[0]
    @scopes = []
    @currentScope = null
  # Named#scope(scopeId:Number|undefined):Scope
  scope: (scopeId)->
    if arguments.length is 1
      if !@scopes[scopeId]
        @scopes[scopeId] = new Scope(scopeId, @shell)
      @currentScope = @scopes[scopeId]
      @$named.append(@scopes[scopeId].element)
    @currentScope
