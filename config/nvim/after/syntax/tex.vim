" Support expl3-style identifiers
" https://tex.stackexchange.com/a/44650
syn match texStatement "\\[a-zA-Z_:@]\+"
set iskeyword=@,48-58,64,_,192-255,#
set isident=@,48-58,64,_,192-255
