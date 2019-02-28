function lpjob --argument jobnumber
	grep "\[Job $jobnumber\]" /var/log/cups/error_log | sed "s/^.\+\[Job $jobnumber\] //g" | uniq
end
