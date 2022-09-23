import 
  ../../../src/templates


proc headerView*(title=""): Component = tmpli html"""
<head>
  <title>$(title)</title>
  <script src="/jsmain.js"></script>
</head>
"""
