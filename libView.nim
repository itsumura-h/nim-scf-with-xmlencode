from cgi import xmlEncode
import
  std/json,
  std/strutils


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
