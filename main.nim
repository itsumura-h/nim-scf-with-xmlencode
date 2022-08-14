import
  ./libView,
  "index.nimf"

let str = "<script>alert('aaa')</script>"
let arr = ["aaa", "bbb", "ccc"]
echo indexView(str, arr)
