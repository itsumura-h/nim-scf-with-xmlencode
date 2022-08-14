Nim SCF with xmlEncode
===

expression
```nim
#? stdtmpl(toString="toString") | standard
#import ./libView
#import "header.nimf"
#proc indexView*(title:string, arr:openArray[string]): Component =
# result = Component.new()
<!DOCTYPE html>
<html lang="en">
  ${headerView("Nim SCF with xmlEncode")}
  <body>
    <p>${title}</p>
    <ul>
      #for row in arr:
        <li>${row}</li>
      # end for
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
