" Toggle backslash before custom pattern items in the search cmdline
" File:		search_escape.vim
" Created:	2011 Oct 31
" Last Change:	2011 Nov 01
"
" Orig by Christian Brabandt @ vim_dev
" Mod by Andy Wokula

" TODO
" - useful default for g:search_escape_items
" + don't replace chars within collections [...]
" + like orig script, prepare for special items that are longer than one
"   char

if !exists("g:search_escape_items")
    if &magic
	let g:search_escape_items = '+ ( ) | ? @='
	" no '\' allowed
    else
	" literal chars with 'nomagic':
	let g:search_escape_items = '. * [ ~'
    endif
endif

cnoremap <F8> <C-\>e ToggleEscape(g:search_escape_items)<CR>


func! ToggleEscape(special_items)
    " {special_items}	string of space-separated pattern items
    let pat = getcmdline()
    if getcmdtype() !~ '[/?]' || a:special_items == ""
	return pat
    elseif a:special_items =~ '\\'
	echoerr 'No ''\'' allowed in g:search_escape_items'
	return pat
    endif
    " pattern to match instances of special items
    let si_pat = '\V\%('. join(split(a:special_items),'\|'). '\)'
    " (1) pattern for unescaped instances:
    let subst1 = '\m'. s:notesc. si_pat
    " (2) pattern for escaped instances:
    let subst2 = '\m'. s:notesc. '\\'. si_pat
    " (3) pattern for collation instances:
    let subst3 = '\m'. s:notesc1. si_pat
    " decorate escaped instances, for later removal of the backslash:
    let pat = substitute(pat, subst2. '\|'. subst3, '#FIX#&#ME#', 'g')
    "let pat = substitute(pat, subst3, '#FIX#&#ME#', 'g')
    " add backslash before unescaped instances:
    let pat = substitute(pat, subst1, '\\&', 'g')
    " remove decoration and backslash from decorated instances:
    let pat = substitute(pat, '\m#FIX#\\\(.\{1,3}\)#ME#', '\1', 'g')
    return pat
endfunc

" don't match either escaped values
let s:notesc = '\%(\\\@<!\%(\\\\\)*\)\@<='
" or values inside collations
let s:notesc1 = '\%(%\@<!\[[^]]*\)\@<='

