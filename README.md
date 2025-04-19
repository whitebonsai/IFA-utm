# IFA-utm
A wrapper script for utmctl written in bash to manage IFA VMs

## Installation
```bash
# Install utmctl
$ sudo ln -sf /Applications/UTM.app/Contents/MacOS/utmctl /usr/local/bin/utmctl

# Clone this repo
$ git clone https://github.com/whitebonsai/IFA-utm.git

# Make script executable
$ chmod +x utm.sh

# Create a symbolink link for utm.sh in your bin directory
$ sudo ln -sf /path/to/utm.sh /usr/local/bin/utm
```

## Usage 
```bash
# Display help 
utm -h 

# Start VMs for selected class
utm -a start -c <class>

# Stop VMs for selected class
utm -a stop -c <class>    
```

## Example 
![Script Demo](images/example.png