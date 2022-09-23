Nim SCF with xmlEncode
===

## CLI
expression
```nim
#? stdtmpl(toString="toString") | standard
#import ./libView
#import "header.nimf"
#proc indexView*(str:string, arr:openArray[string]): Component =
# result = Component.new()
<!DOCTYPE html>
<html lang="en">
  ${headerView(title="Nim SCF with xmlEncode")}
  <body>
    <p>${str}</p>
    <ul>
      #for row in arr:
        <li>${row}</li>
      #end for
    </ul>
  </body>
</html>
```

caller
```nim
let str = "<script>alert('aaa')</script>"
let arr = ["aaa", "bbb", "ccc"]
echo indexView(str, arr)
```

output
```htm
<html lang="en">
  <head>
    <title>Nim SCF with xmlEncode</title>
  </head>
  <body>
    <p>&lt;script&gt;alert('aaa')&lt;/script&gt;</p>
    <ul>
      <li>aaa</li>
      <li>bbb</li>
      <li>ccc</li>
    </ul>
  </body>
</html>
```

## web
Successfully use common ViewModel and Component for ServerSideRendering(SSR) and ClientSideRendering(CSR).

### Common component
These procs is called both SSR and CSR.

```html
# page.nimf

#? stdtmpl(toString="toString")
#import ../../src/libView
#import ./indexViewModel
#proc pageView*(viewModel:IndexViewModel): Component =
#  result = Component.new()
<p>time: ${viewModel.time()}</p>
<table border="1">
  <tr>
    <th>rate</th>
    <th>code</th>
    <th>description</th>
  </tr>
  #for row in viewModel.currencies():
    <tr>
      <td>${row.rate()}</td>
      <td>${row.code()}</td>
      <td>${row.description()}</td>
    </tr>
  #end for
</table>
```

```nim
# indexViewModel.nim

type Currency* = ref object
  code:string
  description:string
  rate:float

proc new*(_:type Currency, code:string, description:string, rate:float):Currency =
  return Currency(
    code:code,
    description:description,
    rate:rate
  )

proc code*(self:Currency):string = self.code
proc description*(self:Currency):string = self.description
proc rate*(self:Currency):float = self.rate


type IndexViewModel* = ref object
  time:string
  currencies:seq[Currency]

proc new*(_:type IndexViewModel, time:string, currencies:seq[Currency]):IndexViewModel =
  return IndexViewModel(
    time:time,
    currencies:currencies
  )

proc time*(self:IndexViewModel):string = self.time
proc currencies*(self:IndexViewModel):seq[Currency] = self.currencies
```


### SSR
```nim
# controller.nim

proc index*():Future[string] {.async.} =
  let str = "<script>alert('aaa')</script>"
  let client = newAsyncHttpClient()
  let respBody = await client.getContent("https://api.coindesk.com/v1/bpi/currentprice.json")
  let respJson = parseJson(respBody)
  let viewModel = IndexViewModel.new(
    respJson["time"]["updated"].getStr,
    @[
      Currency.new(
        respJson["bpi"]["USD"]["code"].getStr,
        respJson["bpi"]["USD"]["description"].getStr,
        respJson["bpi"]["USD"]["rate_float"].getFloat,
      ),
      Currency.new(
        respJson["bpi"]["EUR"]["code"].getStr,
        respJson["bpi"]["EUR"]["description"].getStr,
        respJson["bpi"]["EUR"]["rate_float"].getFloat,
      ),
      Currency.new(
        respJson["bpi"]["GBP"]["code"].getStr,
        respJson["bpi"]["GBP"]["description"].getStr,
        respJson["bpi"]["GBP"]["rate_float"].getFloat,
      )
    ]
  )

  return $indexView(str, viewModel)
```

### CSR
```nim
# jsmain.nim

proc jsmain():Future[cstring] {.async, exportc.} =
  var respJson = newJsObject()
  await fetch("https://api.coindesk.com/v1/bpi/currentprice.json".cstring)
    .then((response:Response) => response.json())
    .then((json: JsObject) => (respJson = json))

  let viewModel = IndexViewModel.new(
    $respJson["time"]["updated"].to(cstring),
    @[
      Currency.new(
        $respJson["bpi"]["USD"]["code"].to(cstring),
        $respJson["bpi"]["USD"]["description"].to(cstring),
        respJson["bpi"]["USD"]["rate_float"].to(float),
      ),
      Currency.new(
        $respJson["bpi"]["EUR"]["code"].to(cstring),
        $respJson["bpi"]["EUR"]["description"].to(cstring),
        respJson["bpi"]["EUR"]["rate_float"].to(float),
      ),
      Currency.new(
        $respJson["bpi"]["GBP"]["code"].to(cstring),
        $respJson["bpi"]["GBP"]["description"].to(cstring),
        respJson["bpi"]["GBP"]["rate_float"].to(float),
      )
    ]
  )
  return ($pageView(viewModel)).cstring
```

```html
<!-- index.nimf -->

<div id="component">
  ${pageView(viewModel)} <!-- SSR -->
</div>
<script>
  addEventListener('load', ()=>{
    let dom = document.getElementById('component');
    setInterval(async()=>{
      dom.innerHTML = await jsmain(); // CSR
    }, 10000)
  })
</script>
```

# For templates
Upper examles is able for templates usage

## CLI
expression
```nim
import
  ../../src/templates,
  ./header


proc indexView*(str:string, arr:openArray[string]): Component = tmpli html"""
<!DOCTYPE html>
<html lang="en">
  $(headerView(title="Nim SCF with xmlEncode"))
  <body>
    <p>$(str)</p>
    <ul>
      $for row in arr{
        <li>$(row)</li>
      }
    </ul>
  </body>
</html>
"""
```

caller
```nim
let str = "<script>alert('aaa')</script>"
let arr = ["aaa", "bbb", "ccc"]
echo indexView(str, arr)
```

output
```htm
<html lang="en">
  <head>
    <title>Nim SCF with xmlEncode</title>
  </head>
  <body>
    <p>&lt;script&gt;alert('aaa')&lt;/script&gt;</p>
    <ul>
      <li>aaa</li>
      <li>bbb</li>
      <li>ccc</li>
    </ul>
  </body>
</html>
```

## web
Successfully use common ViewModel and Component for ServerSideRendering(SSR) and ClientSideRendering(CSR).

### Common component
The pageView proc is called both SSR and CSR.
```nim
# page.nim

import
  ../../../src/templates,
  ./indexViewModel


proc pageView*(viewModel:IndexViewModel): Component = tmpli html"""
<p>time: $(viewModel.time())</p>
<table border="1">
  <tr>
    <th>rate</th>
    <th>code</th>
    <th>description</th>
  </tr>
  $for row in viewModel.currencies(){
    <tr>
      <td>$(row.rate())</td>
      <td>$(row.code())</td>
      <td>$(row.description())</td>
    </tr>
  }
</table>
"""
```

```nim
# indexViewModel.nim

type Currency* = ref object
  code:string
  description:string
  rate:float

proc new*(_:type Currency, code:string, description:string, rate:float):Currency =
  return Currency(
    code:code,
    description:description,
    rate:rate
  )

proc code*(self:Currency):string = self.code
proc description*(self:Currency):string = self.description
proc rate*(self:Currency):float = self.rate


type IndexViewModel* = ref object
  time:string
  currencies:seq[Currency]

proc new*(_:type IndexViewModel, time:string, currencies:seq[Currency]):IndexViewModel =
  return IndexViewModel(
    time:time,
    currencies:currencies
  )

proc time*(self:IndexViewModel):string = self.time
proc currencies*(self:IndexViewModel):seq[Currency] = self.currencies
```

### SSR
```nim
# controller.nim

proc index*():Future[string] {.async.} =
  let str = "<script>alert('aaa')</script>"
  let client = newAsyncHttpClient()
  let respBody = await client.getContent("https://api.coindesk.com/v1/bpi/currentprice.json")
  let respJson = parseJson(respBody)
  let viewModel = IndexViewModel.new(
    respJson["time"]["updated"].getStr,
    @[
      Currency.new(
        respJson["bpi"]["USD"]["code"].getStr,
        respJson["bpi"]["USD"]["description"].getStr,
        respJson["bpi"]["USD"]["rate_float"].getFloat,
      ),
      Currency.new(
        respJson["bpi"]["EUR"]["code"].getStr,
        respJson["bpi"]["EUR"]["description"].getStr,
        respJson["bpi"]["EUR"]["rate_float"].getFloat,
      ),
      Currency.new(
        respJson["bpi"]["GBP"]["code"].getStr,
        respJson["bpi"]["GBP"]["description"].getStr,
        respJson["bpi"]["GBP"]["rate_float"].getFloat,
      )
    ]
  )

  return $indexView(str, viewModel)
```

### CSR
```nim
# jsmain.nim

proc jsmain():Future[cstring] {.async, exportc.} =
  var respJson = newJsObject()
  await fetch("https://api.coindesk.com/v1/bpi/currentprice.json".cstring)
    .then((response:Response) => response.json())
    .then((json: JsObject) => (respJson = json))

  let viewModel = IndexViewModel.new(
    $respJson["time"]["updated"].to(cstring),
    @[
      Currency.new(
        $respJson["bpi"]["USD"]["code"].to(cstring),
        $respJson["bpi"]["USD"]["description"].to(cstring),
        respJson["bpi"]["USD"]["rate_float"].to(float),
      ),
      Currency.new(
        $respJson["bpi"]["EUR"]["code"].to(cstring),
        $respJson["bpi"]["EUR"]["description"].to(cstring),
        respJson["bpi"]["EUR"]["rate_float"].to(float),
      ),
      Currency.new(
        $respJson["bpi"]["GBP"]["code"].to(cstring),
        $respJson["bpi"]["GBP"]["description"].to(cstring),
        respJson["bpi"]["GBP"]["rate_float"].to(float),
      )
    ]
  )
  return ($pageView(viewModel)).cstring
```

```html
<!-- index.nimf -->

<div id="component">
  ${pageView(viewModel)} <!-- SSR -->
</div>
<script>
  addEventListener('load', ()=>{
    let dom = document.getElementById('component');
    setInterval(async()=>{
      dom.innerHTML = await jsmain(); // CSR
    }, 10000)
  })
</script>
```
