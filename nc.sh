#!/bin/bash
trap "rm -f pipe6" EXIT
rm pipe6 &> /dev/null
mkfifo pipe6
port=80
rebootpassword="password"
hostname1=""
hostname2=""
hostname3=""
hostname4=""
hostname5=""

function host1 {

                 q=$(echo -e "$s" | grep "^GET " | cut -d "/" -f2 | cut -d " " -f1)
                 if [ "$q" = "time" ]; then
                         answer=$(date)
                 elif [ "$q" = "top" ]; then
                         answer=$(top -b -n 1)
                 elif [ "$q" = "bw" ]; then
                         answer=$(vnstat -q)
                 elif [ "$q" = "ip" ]; then
                         answer=$(ip a)
                 elif [ "$q" = "myip" ]; then
                        answer=$(echo -e "$s" | grep "^Connection from" | cut -d ' ' -f3)
                 elif [ "$q" = "reboot" ]; then
                         if [ "$rebootpassword" = "$(echo -e "$s" | grep "^GET " | cut -d "/" -f3 | cut -d " " -f1)" ]; then
                                /sbin/shutdown -r
                                answer="Rebooting"
                         else
                                answer="Wrong Password"
                        fi
                 fi
                s="HTTP/1.1 200 OK\n\n$answer\n-------------------${s}"
}
function host2 {
         exit
}
function host3 {
        exit
}
function host4 {
        exit
}
function host5 {
        exit
}

while true
do
{
while read -r line
do
         line=$(echo "$line" | tr -d '\r\n')
         s="${s}\n$line"
         if [ "$line" = "" ]; then
                hostname=$(echo -e "$s" | grep "^Host:" | cut -d " " -f2 )
                if [ "$hostname" = "$hostname1" ]; then
                       host1
                elif [ "$hostname" = "$hostname2" ]; then
                        host2
                elif [ "$hostname" = "$hostname3" ]; then
                        host3
                elif [ "$hostname" = "$hostname4" ]; then
                        host4
                elif [ "$hostname" = "$hostname5" ]; then
                        host5
                #for testing
                #else
                #        s="HTTP/1.1 200 OK\r\n\n------------\n ${s}"
                fi
                echo -e "$s"
                break
         fi
done < pipe6
}  | nc -6 -l -N -v -p $port &> pipe6
done
