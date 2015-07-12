#!/bin/bash

function usage
{
	echo -e "\nUsage: $1 <bluemix app name> <ElephantSQL service name> <Full path to web2py>\n"
	exit;
}

##### main ##### 
APP_NAME=$1
DB_SERVICE_NAME=$2
WEB2PY_PATH=$3

echo -e "Please first run 'cf login -a https://api.ng.bluemix.net -u <bluemix id> -s <space name> -p <password>'\n"


if [ -z "$APP_NAME" -o -z "$DB_SERVICE_NAME" -o -z "$WEB2PY_PATH" ]; then
	usage $(basename $0);
fi

cf unbind-service $APP_NAME $DB_SERVICE_NAME
cf delete $APP_NAME -f -r
cf delete-service $DB_SERVICE_NAME -f
	cf create-service ElephantSQL turtle $DB_SERVICE_NAME
	cp $WEB2PY_PATH/applications/eden/models/000_config.py.new $WEB2PY_PATH/applications/eden/models/000_config.py
	cp $WEB2PY_PATH/applications/eden/modules/s3cfg.py.new $WEB2PY_PATH/applications/eden/modules/s3cfg.py
cd $WEB2PY_PATH
cf set-env $APP_NAME CF_STAGING_TIMEOUT 60
cf set-env $APP_NAME CF_STARTUP_TIMEOUT 20
cf push $APP_NAME -f ./appveyor.yml -b https://github.com/testmanxyz/heroku-buildpack-geodjango.git -m 500M --no-start
# cf push $APP_NAME -f ./appveyor.yml -b https://github.com/dulaccc/heroku-buildpack-geodjango.git#1.1 -m 512M --no-start
#cf push $APP_NAME -b https://github.com/heroku/heroku-buildpack-python.git -m 1G --no-start
# cf push $APP_NAME -b python_buildpack -m 1G --no-start
# cf push $APP_NAME -f ./appveyor.yml -m 1G --no-start
# cf push $APP_NAME -c "bash ./startup.sh" -f ./appveyor.yml -m 1G --no-start
cf bind-service $APP_NAME $DB_SERVICE_NAME
cf start $APP_NAME
# cf restage $APP_NAME
# cf logs $APP_NAME --recent
