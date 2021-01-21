function untar -a archive
	tar -xf $archive
	and rm $archive
end
