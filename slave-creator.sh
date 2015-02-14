#!/bin/bash

#####################################################################################
#  Date    :  12/18/2014 														    #
#  Author  :  Fahmi Ghediri														    #
#  Brief   :  this script allows user to create a NUM virtual machines				#
#			  based on NUM passed as a parameter. These VMs serve as salves         #
#             to the pre-configured master. they send their activies logs to		#
#             him in order to be processed by elasticsearch, kibana and logstash.	#
#																					#
#####################################################################################


#checking if the number of parameter is right

if [ $# -ne 2 ]
then 

	echo " ERROR   : Invalid number of parameter please provide only two prameters !"
	echo " Example :  ./slave-creator 5 192.168.122.2"
	exit 2
fi


#checking if the parameter $1 is integer

if [ "$1" -eq "$1" ] 2>/dev/null
then

#a VM counter
COUNTER=0
IP=3




while [  $COUNTER -lt $1 ]; do

# Here we create a customized virtual machine  based on the parameter $1
# we set the IP address and other configurations like the ubuntu version and the 64 bits architecture
# and we add the package openssh server so the the host can connect to the target slave 
# password will be set to default which is ubuntu


vmbuilder kvm ubuntu \
--domain "slave$COUNTER" \
--arch amd64 \
-o --debug \
--suite precise \
--flavour virtual
--hostname "slave$COUNTER-pc" \
--mem 1024 \
--user "slave$COUNTER" \
--ip 192.168.122."$IP" \
--mask 255.255.255.0 \
--components main,universe,restricted \
--addpkg openssh-server \
--libvirt qemu:///system ;

# Now we can start our created slave to continue configuration
             
virsh --connect qemu:///system start "slave$counter"


#First we must send the certificate to the slave so he can send securily his logs 
# the certificate, created during the master's configuration, must be copied from the the logstash server to the main host 
# in order to be sent to slaves 

scp logstash-forwarder.crt "slave$COUNTER"@192.168.122."$IP":/tmp

# Then we must send the slaveconfig.sh file to the remote slave in order to be remotely executed and to configure the slave 

scp slaveconfig.sh "slave$COUNTER"@192.168.122."$IP":~

# we connect to the remote slave via an ssh session with a sudo right using the -t option 

ssh -t "slave$COUNTER"@192.168.122."$IP" "./slaveconfig.sh $2"

             let COUNTER=COUNTER+1 
             let IP=IP+1
         done


    
else
    echo "ERROR: first paramter must be an integer."
    exit 1
fi
