# Defined in - @ line 2
function ls --description 'List files and directories' --wraps exa
	command exa $argv
end
