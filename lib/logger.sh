# Custom logger util made by Jake
debug() {
	echo -e "\033[42m[$0:${BASH_LINENO[0]}] $1\033[0m"
}

error() {
	echo -e "\033[41m[$0:${BASH_LINENO[0]}] $1\033[0m"
}