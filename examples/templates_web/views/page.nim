import
  ../../../src/templates,
  ./indexViewModel


proc pageView*(viewModel:IndexViewModel): Component = tmpli html"""
<p>time: $(viewModel.time())</p>
<table border="1">
  <tr>
    <th>rate</th>
    <th>code</th>
    <th>description</th>
  </tr>
  $for row in viewModel.currencies(){
    <tr>
      <td>$(row.rate())</td>
      <td>$(row.code())</td>
      <td>$(row.description())</td>
    </tr>
  }
</table>
"""
