import
  std/jsffi,
  std/jsfetch,
  std/jscore,
  std/asyncjs,
  ../../src/libView
  ./indexViewModel,
  "./page.nimf"
from std/sugar import `=>`

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
