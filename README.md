# IFA-utm
A wrapper script for utmctl written in bash to manage IFA VMs

## Installation
```bash
# Install utmctl
$ sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl

# Create a symbolink link for utm.sh in your bin directory
$ sudo ln -sf /path/to/utm.sh /usr/local/bin/utm
```

## Usage 
```bash
# Display help 
utm -h 

# Start VMs for selected class
utm -a start -c class

# Stop VMs for selected class
utm -a stop -c class
```