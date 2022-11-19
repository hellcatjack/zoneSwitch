cd ~/zoneSwitch
pid=$(ps -ef| grep "flask run"| grep -v "grep" | grep -v "init.d" |grep -v "service" |awk '{print $2}')
[[ ! -z ${pid} ]] && kill $pid
export FLASK_APP=project
nohup flask run --host=0.0.0.0 >nohup.out 2>&1 &
