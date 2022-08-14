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
