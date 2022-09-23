import 
  ../../../src/templates,
  ./header,
  ./page,
  ./indexViewModel


proc indexView*(str:string, viewModel:IndexViewModel): Component = tmpli html"""
<!DOCTYPE html>
<html lang="en">
  $(headerView(title="Nim SCF with xmlEncode"))
  <body>
    <p>$(str)</p>
    <div id="$(result.id())">
      $(pageView(viewModel))
    </div>
    <script>
      addEventListener('load', ()=>{
        let dom = document.getElementById('$(result.id())');
        setInterval(async()=>{
          dom.innerHTML = await jsmain();
        }, 10000)
      })
    </script>
  </body>
</html>
"""
