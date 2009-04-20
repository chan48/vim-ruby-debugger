" *** RubyDebugger Commands *** 


" <breakpoint file="test.rb" line="1" threadId="1" />
function! RubyDebugger.commands.jump_to_breakpoint(cmd) dict
  let attrs = s:get_tag_attributes(a:cmd) 
  call s:jump_to_file(attrs.file, attrs.line)
endfunction


" <breakpointAdded no="1" location="test.rb:2" />
function! RubyDebugger.commands.set_breakpoint(cmd)
  let attrs = s:get_tag_attributes(a:cmd)
  let file_match = matchlist(attrs.location, '\(.*\):\(.*\)')
  exe ":sign place " . attrs.no . " line=" . file_match[2] . " name=breakpoint file=" . file_match[1]
endfunction


" <variables>
"   <variable name="array" kind="local" value="Array (2 element(s))" type="Array" hasChildren="true" objectId="-0x2418a904"/>
" </variables>
function! RubyDebugger.commands.set_variables(cmd)
  let tags = s:get_tags(a:cmd)
  let list_of_variables = []
  for tag in tags
    let attrs = s:get_tag_attributes(tag)
    let variable = s:Var.new(attrs)
    call add(list_of_variables, variable)
  endfor
  if !has_key(g:RubyDebugger.variables, 'list')
    let g:RubyDebugger.variables.list = s:VarParent.new({'hasChildren': 'true'})
    let g:RubyDebugger.variables.list.is_open = 1
    let g:RubyDebugger.variables.list.children = []
  endif
  if has_key(g:RubyDebugger, 'current_variable')
    let variable = g:RubyDebugger.variables.list.find_variable({'name': g:RubyDebugger.current_variable})
    unlet g:RubyDebugger.current_variable
    if variable != {}
      call variable.add_childs(list_of_variables)
    else
      return 0
    endif
  else
    if g:RubyDebugger.variables.list.children == []
      call g:RubyDebugger.variables.list.add_childs(list_of_variables)
    endif
  endif

  call s:collect_variables()
endfunction

" *** End of debugger Commands ***



