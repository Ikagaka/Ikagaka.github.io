class SakuraScriptPlayer
  constructor: ()->
  reg =
    "YY": /^\\\\/
    "Y0": /^\\0/
    "Y1": /^\\1/
    "Yp": /^\\p\[(\d+)\]/
    "Ys": /^\\s\[([^\]]+)\]/
    "Yb": /^\\b\[([^\]]+)\]/
    "Yi": /^\\i\[(\d+)\]/
    "YwN": /^\\w(\d+)/
    "Y_w": /^\\_w\[(\d+)\]/
    "Yq": /^\\q\[([^\]]+)\]/
    "Y_aS": /^\\_a\[([^\]]+)\]/
    "Y_aE": /^\\_a/
    "Yc": /^\\c/
    "Yn": /^\\n/
    "Yn[half]": /^\\n\[half\]/
    "Ye": /^\\e/
  play: (script, callback)->
    switch true
      when reg["Y0"].test(script)  then script = script.replace(reg["Y0"],  ""); @scope(0)
      when reg["Y1"].test(script)  then script = script.replace(reg["Y1"],  ""); @scope(1)
      when reg["Yp"].test(script)  then script = script.replace(reg["Yp"],  ""); @scope(Number(reg["Yp"].exec(script)[1]))
      when reg["Ys"].test(script)  then script = script.replace(reg["Ys"],  ""); @scope().surface(Number(reg["Ys"].exec(script)[1])
      when reg["Yb"].test(script)  then script = script.replace(reg["Yb"],  ""); @scope().balloon(Number(reg["Yb"].exec(script)[1])
      when reg["Yi"].test(script)  then script = script.replace(reg["Yi"],  ""); @scope().surface().animation(Number(reg["Yi"].exec(script)[1]))
      when reg["YwN"].test(script) then script = script.replace(reg["YwN"], ""); wait = Number(reg["YwN"].exec(script)[1])*100
      when reg["Y_w"].test(script) then script = script.replace(reg["Y_w"], ""); wait = Number(reg["Y_w"].exec(script)[1])
      when reg["Yq"].test(script)  then script = script.replace(reg["Yq"],  ""); [title, id] = reg["Yq"].exec(script)[1].split(",", 2); @scope().balloon().select(title, id)
      else ;
    @scope().blimp().anchor(id)
