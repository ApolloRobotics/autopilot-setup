source ./logger.sh

# Helper function for running a script as a user, in their home directory.
# Arg1: user
# Arg2: script
run_script_as() {
  debug "Run $2 as $1"
  sudo -H -u $1 bash -c "cd ~ && bash" < $2
}