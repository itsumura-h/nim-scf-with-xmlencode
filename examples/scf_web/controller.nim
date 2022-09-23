import
  std/asyncdispatch,
  std/httpclient,
  std/json,
  ../../src/libView,
  ./indexViewModel,
  "./index.nimf"

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
