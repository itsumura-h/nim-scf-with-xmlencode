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
