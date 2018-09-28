# TODOs

#### TODO for prod (high-priority): 
- Create our own systemd service. Wait for network manager, preferably run last, and prevent boot until complete so that the status appears on screen via HDMI. Or even better create a service that reports back to host when setup is complete.
- Process to monitor lidar eth connection and/or dnsmaq to automatically configure static ip / hostname
- Stop if step fails
- install.sh resume / skip uneeded parts
- Clean/remove L4T patched files

#### TODO for dev env (low-priority):
- Remove locked launcher shortcuts. https://askubuntu.com/questions/409086/add-and-remove-launcher-icons-from-command-line
- Add our launcher shortcuts.
- Don't auto-install sh-env-setup, make the dev dependencies an option.

