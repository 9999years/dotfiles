function wpa_restart
	wpa_cli -iwlan0 reconfigure
    and sudo /etc/init.d/networking restart
end
