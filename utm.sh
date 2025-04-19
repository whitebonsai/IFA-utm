#!/bin/bash

# ===================================================================
# Filename:        utm.sh
# Author:          Lorenzo De Simone
# Version:         1.0
# Created:         2025-04-16
# Description:     CLI Script to start UTM VMs based by Class
# ===================================================================


# to-do: implement delete action

##########################
### Preparation Tasks ####
##########################

# Declare VMs, classes and actions array
declare -a _IFA_VMS
declare -a _IFA_CLASSES
declare -a _UTM_ACTIONS=("start" "stop" "suspend")

# Search for IFA VMs and save to _IFA_VMS
function funcCheckVmIFA() {
	while IFS= read -r line
		do
			if [[ "${line: -5:1}" == "-" ]]; then
				_IFA_VMS+=("$line")
			fi
	done < <(utmctl list | sed '1d' | awk '{print $3}')
}

# Get class from VM Name and save to _IFA_CLASSES
function funcCheckClassesIFA() {
	for _vm in "${_IFA_VMS[@]}"
	do
		if ! [[ $(echo ${_IFA_CLASSES[@]} | fgrep -w "${_vm: -4}") ]]; then
				_IFA_CLASSES+=("${_vm: -4}")
		fi
	done
}

funcCheckVmIFA
funcCheckClassesIFA


############
## COLORS ##
############

cOFF='\033[0m'			# color off / default color
BON='\033[1m'			# bold text on
rON='\033[0;31m'		# red color on
gON='\033[0;32m'		# green color on
bON='\033[0;34m'		# blue color on
yON='\033[0;33m'		# yellow color on 
BrON='\033[1;31m'		# bold red color on
BgON='\033[1;32m'		# bold green color on
BbON='\033[1;34m'		# bold blue color on
ByON='\033[1;33m'		# bold yellow color on 	 


##########################
### Built-in Functions ###
##########################

# List Classes 
function funcListClasses() {
	for _class in "${_IFA_CLASSES[@]}"
	do
		echo "  ${_class}"
	done
}

# List Actions
function funcListActions() {
	for _action in "${_UTM_ACTIONS[@]}"
	do
		echo "  ${_action}"
	done
}

# List VMs sorted by Class
function funcListVmByClass() {
	for _class in "${_IFA_CLASSES[@]}"
	do
		echo -e "${BON}VMs for class:${cOFF} ${BbON}${_class}${cOFF}"
		for _vm in "${_IFA_VMS[@]}"
		do
			if [[ "${_vm: -4}" == "${_class}" ]]; then
				echo -e "  ${BON}*${cOFF} ${ByON}${_vm}${cOFF}"
			fi
		done
		echo ""
	done
}


#########################
### Script Usage Text ###
#########################

function funcHelp(){
	echo "USAGE:"
	echo "  utm -a <action> -c <class>"
	echo ""
	echo "EXAMPLE:"
	echo "  utm -a start -c BMBS"
	echo "  utm -a stop -c BMBS"
	echo ""
	echo "OPTIONS:"
	echo "  -l, list - List VMs sorted by Class"
	echo "  -h, help - this text"
	echo "  -a, action - what to do with the VMs"
	echo "  -c, class - which class VMs you want to operate"
	echo ""
	echo "ACTIONS:"
	funcListActions
	echo ""
	echo "CLASSES:"
	funcListClasses	
}


###############################
#### GETOPTS - TOOL OPTIONS ###
###############################

_OPTSTRING="a:c:lh"

while getopts "${_OPTSTRING}" opt; do
	case "${opt}" in
		h) funcHelp; exit 0;;
		a) _ACTION_OPT="${OPTARG}"; _CHECKARG1=1;;
		c) _CLASS_OPT="${OPTARG}"; _CHECKARG2=2;;
		l) funcListVmByClass; exit 0;;
		\?) echo "**Unknown option**" >&2; echo ""; funcHelp; exit 1;;
		:) echo "**Missing option argument**" >&2; echo ""; funcHelp; exit 1;;
	esac
done

shift $(( OPTIND - 1 ))

# Check if Argument Action and Argument Class has been set
if [ "${_CHECKARG1}" == "" ] || [ "${_CHECKARG2}" == "" ]; then
	echo "**At least one argument is missing**"
	echo ""
	funcHelp
	exit
fi


########################
### SCRIPT FUNCTIONS ###
########################

# Function to check if action is valid
function funcCheckAction() {
	local _action_opt=${1}
	local _not_valid=0

	for _action in "${_UTM_ACTIONS[@]}"
	do
		if [[ "${_action_opt}" == "${_action}" ]]
		then
			return 0
		else
			_not_valid=1
		fi
	done

	if [[ "${_not_valid}" -eq 1 ]]; then
		echo -e "${BrON}ERROR${cOFF}: ${_action_opt} is not a valid action"
		exit 1
	fi
}

# Function to check if class is valid
function funcCheckClass() {
	local _class_opt=${1}
	local _not_valid=0

	for _class in "${_IFA_CLASSES[@]}"
	do
		if [[ "${_class_opt}" == "${_class}" ]]
		then
			return 0
		else
			_not_valid=1
		fi
	done

	if [[ "${_not_valid}" -eq 1 ]]; then
		echo -e "${BrON}ERROR${cOFF}: No VMs for class ${_class_opt}"
		exit 1
	fi
}

# Function to operate VMs for chosen class
function funcManageVms() {
	local _action_opt=${1}
	local _class_opt=${2}

	echo -e "Working in class: ${BbON}${_class_opt}${cOFF}"

	for _vm in "${_IFA_VMS[@]}"
	do
		if [[ "${_vm: -4}" == "${_class_opt}" ]]; then
			utmctl "${_action_opt}" "${_vm}"
			case "${_action_opt}" in
				start) echo -e "  ${BgON}${_action_opt} VM${cOFF}:  ${BON}*${cOFF} ${BbON}${_vm}${cOFF}";;
				stop) echo -e "  ${BrON}${_action_opt} VM${cOFF}:  ${BON}*${cOFF} ${BbON}${_vm}${cOFF}";;
				suspend) echo -e "  ${ByON}${_action_opt} VM${cOFF}:  ${BON}*${cOFF} ${BbON}${_vm}${cOFF}";;
			esac
		fi
	done
}


###################
### MAIN SCRIPT ###
###################

# Check if _ACTION_OPT and _CLASS_OPT are valid
funcCheckAction "${_ACTION_OPT}"
funcCheckClass "${_CLASS_OPT}"

# Execute Commands
funcManageVms "${_ACTION_OPT}" "${_CLASS_OPT}"