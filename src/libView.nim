import
  std/json,
  std/strutils


# ========== xmlEncode ==========
# extract from `cgi` to be able to run for JavaScript.
# https://nim-lang.org/docs/cgi.html#xmlEncode%2Cstring

proc addXmlChar(dest: var string, c: char) {.inline.} =
  case c
  of '&': add(dest, "&amp;")
  of '<': add(dest, "&lt;")
  of '>': add(dest, "&gt;")
  of '\"': add(dest, "&quot;")
  else: add(dest, c)

proc xmlEncode*(s: string): string =
  ## Encodes a value to be XML safe:
  ## * `"` is replaced by `&quot;`
  ## * `<` is replaced by `&lt;`
  ## * `>` is replaced by `&gt;`
  ## * `&` is replaced by `&amp;`
  ## * every other character is carried over.
  result = newStringOfCap(s.len + s.len shr 2)
  for i in 0..len(s)-1: addXmlChar(result, s[i])


# ========== libView ==========
proc toString*(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr.xmlEncode
  of JInt:
    return $(val.getInt)
  of JFloat:
    return $(val.getFloat)
  of JBool:
    return $(val.getBool)
  of JNull:
    return ""
  else:
    raise newException(JsonKindError, "val is array")

proc toString*(val:string):string =
  return val.strip.xmlEncode

proc toString*(val:bool | int | float):string =
  return val.`$`.xmlEncode


# ========== Component ==========
type Component* = ref object
  value:string

proc new*(_:type Component):Component =
  return Component(value:"")

proc add*(self:Component, value:string) =
  self.value.add(value)

proc toString*(self:Component):string =
  return self.value

proc `$`*(self:Component):string =
  return self.toString()
