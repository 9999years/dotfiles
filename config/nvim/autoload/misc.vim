" Delete all end-of-line whitespace in the current buffer.
function misc#StripWhitespace(start, end) abort
  " Save cursor position.
  let l:cursor = getcurpos()
  " Display number of matches.
  exe a:start . "," . a:end . " smagic/\\s\\+$//en"
  " Do not error if no matches.
  keepjumps exe a:start . "," . a:end . " smagic/\\s\\+$//eg"
  nohlsearch
  call setpos('.', l:cursor)
endfunction

function misc#HighlightNonASCII()
	normal! /[^\x0a\x09\x20-\x7e]
endfunction

function misc#EditFtplugin(...) abort
	if a:0 == 0
		let ft = &ft
	else
		let ft = a:1
	endif
	exe "split " . stdpath("config") . "/ftplugin/" . ft . ".vim"
endfunction

function misc#EditAfterFtplugin(...) abort
	if a:0 == 0
		let ft = &ft
	else
		let ft = a:1
	endif
	exe "split " . stdpath("config") . "/after/ftplugin/" . ft . ".vim"
endfunction

function misc#EditUltiSnips(...) abort
	if a:0 == 0
		let ft = &ft
	else
		let ft = a:1
	endif
	exe "sp " . stdpath("config") . "/plugged/vim-snippets/UltiSnips/" . ft . ".snippets"
endfunction
