complete -c arduino-new -f
complete -c arduino-new -n 'test (count (commandline -opc)) -eq 2' -a uno -d 'Uno R3'
complete -c arduino-new -n 'test (count (commandline -opc)) -eq 2' -a mega -d 'Mega 2560'
