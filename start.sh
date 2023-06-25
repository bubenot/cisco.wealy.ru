#!/bin/sh
echo $$ > /var/run/lava.pid
path='/home/wealy/web/cisco.wealy.ru/python-scripts'
echo [Cisco IOS Commands v2] `date +%Y/%m/%d\ %H:%M:%S` start >> $path/restarts.log
cd $path
while true
do 
    python3 app.py
    echo [Cisco IOS Commands v2] `date +%Y/%m/%d\ %H:%M:%S` restart >> $path/restarts.log
	echo "[Cisco IOS Commands v2] Чтобы остановить запуск сервера, нажмите CTRL + C (Flask web framework запустится через 10 секунд)"
	sleep 10
done