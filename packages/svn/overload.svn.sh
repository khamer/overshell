svn_add() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^\?/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			svn st | awk '/^\?/{print $2}' | xargs -d'\n' $original_command add
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
		$original_command ci -m "Completed Ticket #$ticket_number: $*"
	else
		$original_command ci -m "Completed Ticket #$ticket_number"
	fi
}

svn_del() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^\!/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			svn st | awk '/^\!/{print $2}' | xargs -d'\n' $original_command del
		fi
	else
		$original_command del "$@"
	fi
}

svn_df() {
	$original_command diff "$@" | grep -E '^[-+]'
}

svn_help() {
	if [ -z "$1" ]; then
		$original_command help
		echo "The following commands have been overloaded:"
		echo "   add"
		echo "   commit"
		echo "   commit-ticket (ct)"
		echo "   del"
		echo "   help"
		echo "   push"
		echo "   revert"
		echo "   upstatus (us)"
		echo "   shortlog (sl)"
		echo "   who"
	else
		$original_command help "$@"
	fi
}

svn_push() {
	parallel upload ::: $(svn st| awk '/^[AM]/{print $2}')
}

svn_reset() {
	files="$(svn st | awk '/^[AM!D]/{print $2}')"
	parallel svn revert ::: $files
	parallel upload ::: $files
}

svn_revert() {
	if [ -z "$1" ]; then
		ARGS=$(svn st | awk '/^M/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			svn st | awk '/^M/{print $2}' | xargs -d'\n' $original_command revert
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
	$original_command log "$@" | grep '[^-]' | sed -e 'N;s/\n/ /'
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

svn_branch() {
	if [ -n "$1" ]; then
		if [ "$1" == "trunk" ]; then
			svn switch ^/trunk
		else
			if ! svn ls ^/branches/$1 > /dev/null 2>/dev/null; then
				svn cp ^/trunk ^/branches/$1
			fi
			svn switch ^/branches/$1
		fi
	else
		BRANCHES="trunk/ $(svn ls ^/branches)"
		CURRENT="$(svn info | awk '/^Relative URL:/{print $3}')"
		CURRENT="${CURRENT#*/}/"
		CURRENT="${CURRENT#branches/}"
		for BRANCH in $BRANCHES; do
			if [ $BRANCH == $CURRENT ]; then
				echo "* $BRANCH"
			else
				echo "  $BRANCH"
			fi
		done
	fi
}
