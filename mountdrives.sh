#!/bin/bash
#
#####################################################################################
# Info:
####################################################################################
#
# Updated 21/04/2017
# Contact cjackson@support-expert.co.uk / @cjacksonuk
# Tested: Working on 10.12.4 in lab
#
# Reminders:
# call script: sh /Users/admin/scripts/mountdrives.sh 
# Set permisisons :
# make executable:   sudo chmod +x ./path/to/script.sh
# correct users:     sudo chown root:wheel /filepath
# check permissions  ls -lah  /filepath
#
# Description:
# Script checks to see if connected to correct network (by pinging something) 
# then loops through the variables and correctly mounts.
#
# Instructions:
# 1. Install https://github.com/chilcote/outset/releases
# 2. Then drop script into /usr/local/outset/login-every
# 3. for good measure: sudo chmod +x /usr/local/outset/login-every/mountdrives.sh
# 4. sudo chown root:wheel /usr/local/outset/login-every/mountdrives.sh
#####################################################################################
#Determin user
#UserName="$1" #Doenst work presumably only for a loginhook not launch agent.
#$USER is determined by OS X (current user who is executing the script)
USER=$(id -u -n);
echo $USER;
#Prepare logging:
set -x;exec 1>>/tmp/login.log 2>&1;date
logger -t LOGIN.SH "login script start for $USER"
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
#################################################### script open


#####################################################################################
# Variables:
#####################################################################################
#
Alive_IP=192.168.2.101; #Something (to ping) alive on the network to check we are connected - ie no point mounting if off site
#DOMAIN=server.domain

userMessages=1; ## 1/0 Allow info to be sent to user for debugging
userMessageTimeout=2; #time for message to appear for user in seconds

#Mount Variables
:' // Just uncomment / add as required

Server_name[1]=192.168.2.103;   #IP or Server name		192.168.x.x
Server_path[1]=;				        #Folder to mount		  folder
Server_prot[1]=SMBFS; 			    #Protocol 				    AFP/SMBFS  
Server_cred[1]=0;               #Credentials Fixed		1/0 = yes/no     if fixed use following variables / else use AD/OD/Local 
Server_user[1]=;				        #Username
Server_pass[1]=;				        #Password
Server_meth[1]=OSA; 			      #Method					      SH or OSA		Sometime OSAScript handels differently  

Server_name[2]=192.168.2.103;   #IP or Server name		192.168.x.x
Server_path[2]=;				        #Folder to mount		  folder
Server_prot[2]=SMBFS; 			    #Protocol 				    AFP/SMBFS  
Server_cred[2]=0; 				      #Credentials Fixed		1/0 = yes/no     if fixed use following variables / else use AD/OD/Local 
Server_user[2]=;				        #Username
Server_pass[2]=;				        #Password
Server_meth[2]=OSA; 			      #Method					      SH or OSA		Sometime OSAScript handels differently  

Server_name[3]=192.168.2.103;   #IP or Server name		192.168.x.x
Server_path[3]=;				        #Folder to mount		  folder
Server_prot[3]=SMBFS; 			    #Protocol 				    AFP/SMBFS  
Server_cred[3]=0; 				      #Credentials Fixed		1/0 = yes/no     if fixed use following variables / else use AD/OD/Local 
Server_user[3]=;				        #Username
Server_pass[3]=;				        #Password
Server_meth[3]=OSA; 			      #Method					      SH or OSA		Sometime OSAScript handels differently  
'

############### !!!!! NOTHING SHOULD NEED EDITING BELOW THIS LINE !!!!! ##############
############### !!!!! NOTHING SHOULD NEED EDITING BELOW THIS LINE !!!!! ##############
############### !!!!! NOTHING SHOULD NEED EDITING BELOW THIS LINE !!!!! ##############



######################################################################################
# Main:     
######################################################################################
#
## Notify User #######################################################################
if [ $userMessages == 1 ]; then  
/usr/bin/osascript -e 'tell app "System Events" to display dialog "Run script for '$USER'" with title "Logon Script" giving up after '$userMessageTimeout''
fi 
######################################################################################

## MOUNT NAS3 ############################################



#
if /sbin/ping -q -c 1 $Alive_IP &> /dev/null
then
	echo "File server $Alive_IP is responding. Attempting to mounting network volumes...";

	## MOUNT-Prep ############################################
	/bin/mkdir ~/Library/Application\ Support/Mounts; 
	##########################################################
	
	# This will loop for the number of drives that need processing
	#for (( i=1; i<=$NumberOfDrivesToMount; i++ ))
	i=0;
	for eachItem in "${Server_name[@]}"
	do
		let "i++"; #increment through the array count

		##################################################
		
		## Modify Variables for the loop!
		ModServer=${Server_name[$i]};
		ModServer_path=${Server_path[$i]};
		ModServer_protocol=${Server_prot[$i]};
		ModServer_Credentials_Hardcoded=${Server_cred[$i]};
		ModServer_User=${Server_user[$i]};
		ModServer_Pass=${Server_pass[$i]};
		ModServer_MountType=${Server_meth[$i]};
		
		## mkdir for each path ##########################################
		/bin/mkdir ~/Library/Application\ Support/Mounts/$ModServer_path;
		#################################################################
		
		## Notify User #######################################################################
		if [ $userMessages == 1 ]; then  
		/usr/bin/osascript -e 'tell app "System Events" to display dialog "Mounting drive '$i' \n '$ModServer_protocol' //'$ModServer'/'$ModServer_path' \n via '$ModServer_MountType'" with title "Logon Script" giving up after '$userMessageTimeout''
		fi 
		######################################################################################
		
		if [ $ModServer_protocol == "SMBFS" ]; then FS="smb"; else FS="AFP"; fi 
		    
			###############################################################
			# Run Method Server_MountType=SH; #SH or OSA  	    
			###############################################################
			if [ $ModServer_MountType == "SH" ]; then 
					
					if [ $ModServer_Credentials_Hardcoded == 1 ]; then 
						echo "yes credentials hardcoded"; 
						mount -t $ModServer_protocol $FS://$ModServer_User:$ModServer_Pass@$ModServer/$ModServer_path ~/Library/Application\ Support/Mounts/$ModServer_path
					else 
						echo "no credentials - use system"; #not sure where credentials coming from maybe logged in user for OD/AD??
						mount -t $ModServer_protocol $FS://$USER@$ModServer/$ModServer_path ~/Library/Application\ Support/Mounts/$ModServer_path	
					fi	
			fi	
			# end of SH Mounttype
			###############################################################		
			###############################################################
			# Run Method Server_MountType=OSA; #SH or OSA  	    
			###############################################################		
			#### else Run Method Server_MountType=OSA; #SH or OSA 
			if [ $ModServer_MountType == "OSA" ]; then
				
					if [ $ModServer_Credentials_Hardcoded == 1 ]; then 
						echo "yes credentials hardcoded"; 
					    /usr/bin/osascript -e 'mount volume "'$FS'://'$ModServer_User':'$ModServer_Pass'@'$ModServer'/'$ModServer_path'"'
					else 
						echo "no credentials - use system"; #not sure where credentials coming from maybe logged in user for OD/AD??
						/usr/bin/osascript -e 'mount volume "'$FS'://'$USER'@'$ModServer'/'$ModServer_path'"'
					fi	
			fi
			# end of OSA Mounttype
			###############################################################		
		
			
		##########################################################

		#
		#exit 0
	done	
else
	echo "Timeout. File Server $Alive_IP is not responding. Network volumes WILL NOT be mounted."
	exit 1
fi
