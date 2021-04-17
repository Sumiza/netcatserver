#!/bin/bash
trap "rm -f pipe" EXIT
rm pipe &> /dev/null
mkfifo pipe
rebootpassword="password"
while true
do
{
while read -r line
do
         line=$(echo "$line" | tr -d '\r\n')
         s="${s}\n$line"
         if echo "$line" | grep "^GET " &> /dev/null; then
                 q=$(echo "$line" | cut -d "/" -f2 | cut -d " " -f1)
                 if [ "$q" = "test" ]; then
                         answer=$(date)
                 elif [ "$q" = "top" ]; then
                         answer=$(top -b -n 1)
                 elif [ "$q" = "bw" ]; then
                         answer=$(vnstat -q)
                 elif [ "$q" = "ip" ]; then
                         answer=$(ip a)
                 elif [ "$q" = "myip" ]; then
                         answer=$qip
                 elif [ "$q" = "reboot" ]; then
                         if [ "$rebootpassword" = "$(echo "$line" | cut -d "/" -f3 | cut -d " " -f1)" ]; then
                                answer="Rebooting now"
                                reboot now
                         else
                                answer="Wrong Password"
                        fi
                 fi
         elif echo "$line" | grep "^Connection from" &> /dev/null; then
                qip=$(echo "$line" | cut -d ' ' -f3)
         fi
         if [ "$line" = "" ]; then
                 s="HTTP/1.1 200 OK\n\n$answer\n-------------------${s}"
                 echo -e "$s"
                 break
         fi
done < pipe
}  | nc -6 -l -q0 -v -p 8880 &> pipe
done
