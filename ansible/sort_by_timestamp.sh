perl -pe 's/^(.*[^\d](\d{2}):(\d{2}):(\d{2})[^:].*)$/$2\t$3\t$4\t$1/' | sort -t $'\t' -n | perl -pe 's/^.*\t//'
