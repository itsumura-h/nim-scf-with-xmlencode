import
  ../../src/templates


proc headerView*(title=""): Component = tmpli html"""
<head>
  <title>$(title)</title>
</head>
"""
