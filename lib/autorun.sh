source ./logger.sh 

enable_on_boot(){
    debug "Setting up auto-start of $1$2 on reboot"
    command="sudo -H -u root bash -c 'cd $1 && bash $1$2 >> /var/log/apollo-setup.log 2>&1'"
    job="@reboot $command"
    cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
}

disable_on_boot(){
    debug "Remove auto-start of $1$2"
    crontab -l | grep -v "@reboot sudo -H -u root bash -c 'cd $1 && bash $1$2 >> /var/log/apollo-setup.log 2>&1'"  | crontab -
}
