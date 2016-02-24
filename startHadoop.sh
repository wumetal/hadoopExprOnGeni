#! /bin/bash

##################################################
# startHadoop.sh
# GENI HADOOP Project @ NYU Tandon
# purpose of script: Configure HDFS, similar to what was done in GENI's  "Hadoop on a Slice" tutorial 
#	Specifically this script does the following: 
# 		1) Configures Hadoop
#		2) Place  file in HDFS
##################################################

echo "Are you in /home/hadoop and are you hadoop@master? Do not execute the script unless you are. 
Get to where you need to be then re-run the script. 
(If you have just run install.sh, and executed the 3 commands listed at the end, you are where you need to be and can continue.)
#GET HADOOP STARTED
	# When you do run the script, you'll know your Hadoop environment is configured when you see: 
	#/************************************************************
	#SHUTDOWN_MSG: Shutting down NameNode at master/172.16.1.1
	#************************************************************/

===> Execute script [y/n]?
"	
read response
[ "$response" != "y" ] &&  exit 1 

sleep 3
hdfs namenode -format
start-dfs.sh
start-yarn.sh

# PLACE PARTIAL GUTENBERG FILE IN HDFS
sleep 1
echo "startHadoop.sh: Files will now be placed in HDFS" 
cd /home/hadoop
[[ -f /home/hadoop/stopNStemmedAll ]] && hadoop fs -put /home/hadoop/stopNStemmedAll /  


# EXPAND VIRTUAL MEMORY

cat /home/hadoop/hadoop-2.7.1/etc/hadoop/yarn-site.xml | grep vmem
if [[ $? -ne 0 ]] ; then  #VMEM has not been affected in config file, so change it 
	cd /home/hadoop/hadoop-2.7.1/etc/hadoop/
    line="<property>   
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
    <description>Whether virtual memory limits will be enforced for containers</description>
    </property>
    <property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>4</value>
    <description>Ratio between virtual memory to physical memory when setting memory limits for containers</description>
	</property></configuration>" 
sed  -i '$d' yarn-site.xml
echo $line >> yarn-site.xml 
fi 

( [[ $? -eq 0 ]] && echo "Yarn Memory successfully expanded. DO NOT RE-RUN THIS SCRIPT" ) || echo "startHadoop.sh:Memory was not successfully expanded and the experiment will not work"


cat /home/hadoop/hadoop-2.7.1/etc/hadoop/mapred-site.xml | grep memory
if [[ $? -ne 0 ]] ; then  #VMEM has not been affected in a config file, so change it 
	cd /home/hadoop/hadoop-2.7.1/etc/hadoop/
    line="
 <property>
     <name>mapreduce.map.memory.mb</name>
     <value>8192</value>
   </property>
     <property>
     <name>mapreduce.reduce.memory.mb</name>
     <value>4096</value>
   </property>
     <property>
     <name>mapreduce.map.java.opts</name>
     <value>-Xmx6144m</value>
   </property>
     <property>
     <name>mapreduce.reduce.java.opts</name>
     <value>-Xmx3072m</value>
   </property>
   </configuration> "
sed  -i '$d' mapred-site.xml
echo $line >> mapred-site.xml 
fi 

( [[ $? -eq 0 ]] && echo "Mapred Memory successfully expanded. DO NOT RE-RUN THIS SCRIPT" ) || echo "startHadoop.sh:Memory was not successfully expanded and the experiment will not work"


# SCRIPT GOODBYE 
echo " ###########################################
startHadoop.sh: Script done. 
Now try running the experiment! 

Type something like ./exprStart.sh 1 interst1 interest2
for ex. "./exprStart.sh 1 apples alice" 

NOTE: To make the experiment portable, the corpus is reduced words starting with a. So you need to give the experiment your favortite 'a' words.

NOTE: Also don't forget to enter a number between the scriptname and your interests. 
This number represents the factor to increase the logical block size a map job works on." 

