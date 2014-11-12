

class Balloon
  # new Balloon(shell:Shell):Balloon
  constructor: (@shell)->
    @$balloon = $("<div />")
      .addClass("box")
    @$style = $("<style scoped />")
      .html("""
        .box {
          background: #ccc;
          height: 150px;
          width: 300px;
          overflow-y: scroll;
          white-space: pre;
          white-space: pre-wrap;
          white-space: pre-line;
          word-wrap: break-word;
        }
        .anchor,.select{
          color:red;
          cursor:pointer;
        }
        .anchor:hover,.select:hover{
          background-color:violet;
        }
      """)
    @$balloon.append(@$style)
    @element = @$balloon[0]
  talk: (text)->
  clear: ->
