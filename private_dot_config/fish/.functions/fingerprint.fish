# Defined in /tmp/fish.1ADoJS/fingerprint.fish @ line 1
function fingerprint --argument host
	ssh-keyscan -t rsa $host | ssh-keygen -lf -
end
