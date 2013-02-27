svn_add() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^\?/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			$original_command add $ARGS
		fi
	else
		$original_command add "$@"
	fi
}

svn_ci() {
	svn_commit "$@"
}
svn_commit() {
	$original_command up && $original_command ci "$@"
}

svn_ct() {
	svn_commit-ticket "$@"
}
svn_commit-ticket() {
	ticket_number="$1"
	shift

	$original_command up
	if [[ $# > 0 ]]; then
		$original_command ci -m "For Ticket #$ticket_number: $*"
	else
		$original_command ci -m "Completed Ticket #$ticket_number"
	fi
}

svn_del() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^\!/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			$original_command del $ARGS
		fi
	else
		$original_command del "$@"
	fi
}

svn_help() {
	if [ -z "$1" ]; then
		$original_command help
		echo "The following commands have been overloaded:"
		echo " * svn add"
		echo " * svn commit"
		echo " * svn commit-ticket"
		echo " * svn del"
		echo " * svn help"
		echo " * svn push"
		echo " * svn revert"
		echo " * svn upstatus"
		echo " * svn shortlog"
	else
		$original_command help "$@"
	fi
}

svn_push() {
	for f in $(svn st | awk '/^[AM]/{print $2}'); do
		upload $f
	done
}

svn_revert() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^M/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			$original_command revert $ARGS
		fi
	else
		$original_command revert "$@"
	fi
}

svn_root() {
	echo $(svn info | mawk '/^Working Copy/{print $5}')
}

svn_setup() {
	if [ -z "$1" ]; then
		echo "Usage: svn setup DOMAIN"
	else
		svn co https://svn.imarc.net/$1/trunk $HOME/Workbench/$1
	fi
}

svn_sl() {
	svn_shortlog "$@"
}
svn_shortlog() {
	$original_command log "$@" | grep [^-] | sed -e 'N;s/\n/ /'
}

svn_us() {
	svn_upstatus "$@"
}
svn_upstatus() {
	$original_command up "$@" && $original_command st "$@"
}

svn_who() {
	if [ -n "$1" ]; then
		file="$1"
	else
		file="."
	fi
	$original_command log -q $file | awk '/^r/{print $3}' | sort | uniq -c | sort -rn
}
