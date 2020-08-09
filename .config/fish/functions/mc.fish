# Defined in /tmp/fish.OAraps/mc.fish @ line 1
function mc --description 'mkdir -p && cd' --argument dir
	mkdir -p $dir
    and cd $dir
end
