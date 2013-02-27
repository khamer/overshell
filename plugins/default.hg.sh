hg_rm() {
	if [ -z "$1" ]; then
		ARGS=$(hg st $(hg root) | awk '/^\!/{print $2}' | xargs)
		if [ -n "$ARGS" ]; then
			$original_command rm $ARGS
		fi
	else
		$original_command rm "$@"
	fi
}
