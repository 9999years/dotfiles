function scp
	command env SHELL=(command -v bash) scp $argv
end
