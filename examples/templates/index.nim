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
