#!/bin/bash


#####################################################################################
#  Date    :  12/20/2014 														                                #
#  Author  :  Fahmi Ghediri														                              #
#  Brief   :  this script will be sent to the target slave and will be remotely 	  #
#			        executed via an ssh session in order to configure the slave which 	  #
#             will be considered as a logstash client.      						            #
#																					                                          #
#####################################################################################






#these commands install the logstash forwarder package and 

echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list

sudo apt-get update

sudo apt-get install logstash-forwarder

wget https://assets.digitalocean.com/articles/logstash/logstash-forwarder_0.3.1_i386.deb

sudo dpkg -i logstash-forwarder_0.3.1_i386.deb

cd /etc/init.d/; sudo wget https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O logstash-forwarder

sudo chmod +x logstash-forwarder

sudo update-rc.d logstash-forwarder defaults

sudo mkdir -p /etc/pki/tls/certs

sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/

#Now we will configure the Logstash Forwarder by writing some configurations into the logstash forwarder 


echo "{" >> /etc/logstash-forwarder
echo "  \"network\": {" >> /etc/logstash-forwarder

#in the next line we asign the master's IP address as the server address so the slave where to send the data 


echo "    \"servers\": [ \"$1:5000\" ]," >> /etc/logstash-forwarder
echo "    \"timeout\": 15," >> /etc/logstash-forwarder
echo "    \"ssl ca\": \"/etc/pki/tls/certs/logstash-forwarder.crt\"" >> /etc/logstash-forwarder
echo "  }," >> /etc/logstash-forwarder
echo " \"files\": [" >> /etc/logstash-forwarder
echo "    {" >> /etc/logstash-forwarder
echo "      \"paths\": [" >> /etc/logstash-forwarder
echo "        \"/var/log/syslog\"," >> /etc/logstash-forwarder
echo "        \"/var/log/auth.log\"" >> /etc/logstash-forwarder
echo "       ]," >> /etc/logstash-forwarder
echo "      \"fields\": { \"type\": \"syslog\" }" >> /etc/logstash-forwarder
echo "    }" >> /etc/logstash-forwarder
echo "   ]" >> /etc/logstash-forwarder
echo "}" >> /etc/logstash-forwarder

# Restarting the logstash-forwarder service is necessary to connect the slave to the master

sudo service logstash-forwarder restart

# Finally we must disconnect from the ssh session


exit 0
