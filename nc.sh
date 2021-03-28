#!/bin/bash
rm pipe &> /dev/null
mkfifo pipe
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
                        echo "$(date) - $line" >> log.log
                        answer=$(cat log.log)
                elif [ "$q" = "top" ]; then
                        answer=$(top -b -n 1)
                elif [ "$q" = "bw" ]; then
                        answer=$(vnstat -q)
                elif [ "$q" = "ip" ]; then
                        answer=$(ip a)
                elif [ "$q" = "myip" ]; then
                        answer=$qip
                fi
        elif echo "$line" | grep "^connect to " &> /dev/null; then
               qip=$(echo "$line" | cut -d '[' -f3 | cut -d ']' -f1)
        fi
        if [ "$line" = "" ]; then
                s="HTTP/1.1 200 OK\r\n${s}\n-------------------\n$answer\n"
                echo -e "$s"
                break
        fi
done < pipe
}  | nc -l -q1 -v -p 5019 &> pipe

done
