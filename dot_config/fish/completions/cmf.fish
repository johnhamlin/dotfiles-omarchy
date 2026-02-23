# Help flag
complete -c cmf -s h -l help -d "Show help message"

# First arg: suggest common useful patterns
complete -c cmf -n "test (count (commandline -opc)) -lt 2" -f \
    -a TODO -d "Find TODOs"
complete -c cmf -n "test (count (commandline -opc)) -lt 2" -f \
    -a FIXME -d "Find FIXMEs"
complete -c cmf -n "test (count (commandline -opc)) -lt 2" -f \
    -a HACK -d "Find HACKs"
complete -c cmf -n "test (count (commandline -opc)) -lt 2" -f \
    -a NOTE -d "Find NOTEs"

# After pattern: offer common grep/rg flags
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s i -d "Case insensitive"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s w -d "Word boundaries"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s F -d "Fixed string (literal)"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s v -d "Invert match"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s x -d "Exact line match"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s c -d "Count matches only"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -l hidden -d "Include hidden files"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s e -d "Pattern (for multiple patterns)"
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s A -d "Lines after match" -x
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s B -d "Lines before match" -x
complete -c cmf -n "test (count (commandline -opc)) -ge 2" -s C -d "Lines around match" -x
