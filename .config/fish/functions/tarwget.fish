# Defined in /tmp/fish.WJG8Nq/tarwget.fish @ line 2
function tarwget --argument url
	set file (basename $url)
	#set size (curl -ILX GET $url \
		#| sed -En 's/^Content-Length: ([0-9]+)\r/\1/p' \
		#| numfmt --to=iec)
	echo "Downloading to $file"
	if which wget
		wget -q $url -O $file
	else
		curl -L -o $file $url
	end
	and echo "Extracting archive"
	and tar -xf $file
	and rm $file
end
