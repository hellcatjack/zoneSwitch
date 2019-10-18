cd ~/zoneswitch
kill `ps aux|grep flask|grep host=0.0.0.0|awk {'print $2'}`
export FLASK_APP=project
nohup flask run --host=0.0.0.0 >nohup.out 2>&1 &
