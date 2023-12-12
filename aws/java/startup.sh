#!/bin/bash
cd /home/ec2-user/app/nacos/backend/
tar -xf /home/ec2-user/app/nacos/backend/backend-pkg.tar
echo "执行摘流操作。。AWS 支持load balancer主动摘流，这里休眠15s足够"
#curl --location --request POST 'http://127.0.0.1:8080/nacos/api/v1/maintenance/offline' --header 'Authorization: Basic dmNjLXRyYWFmOGYyZGIxNTQ4'
#sleep 15s
#echo "等待摘流量隔离时间结束。。"

echo "停止进程"

PID=`ps -eaf | grep 'nacos' | grep -v grep | awk '{print $2}'`

if [[ -n "$PID" ]]; then
  echo "killing $PID"
  kill -15 $PID

  # Wait for the process to terminate
  for ((i = 0; i < 20; i++)); do
    sleep 1s

    # Check if the process is still running
    if ! kill -0 $PID 2>/dev/null; then
      echo "Process with PID $PID has been successfully terminated."
      break
    fi
  done

  # If the process is still running after 15 seconds, you can handle it here
  if kill -0 $PID 2>/dev/null; then
    echo "Process with PID $PID is still running after 15 seconds."
    # You can take further action or log an error message.
  fi

else
  echo "No process found with the specified name."
fi

echo "进程已经停止"

echo "开始启动"
if [ "$DEPLOYMENT_GROUP_NAME" == "uat" ]
then
    sh /home/ec2-user/app/nacos/backend/nacos/bin/startup.sh -m standalone

elif [ "$DEPLOYMENT_GROUP_NAME" == "prod" ]
then
    sh /home/ec2-user/app/nacos/backend/nacos/bin/startup.sh -m standalone
else
   "faield...$DEPLOYMENT_GROUP_NAME not found" > catalina-ec2-user.out
fi


sleep 5s

# Check if the "myapp" process is running
if ps aux | grep -v grep | grep "nacos" > /dev/null
then
  echo "Application is running."
  exit 0 # Success (zero exit code)
else
  echo "Application is not running. return non-zero value to stop the deploy process, and you can enable the rollback in your deploy group"
  exit 1 # Failure (non-zero exit code)
fi
sleep 20s
echo "启动时间约30s 部署成功>>>"