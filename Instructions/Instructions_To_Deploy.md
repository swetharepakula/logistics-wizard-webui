# Instructions to Deploy

## Set up the ERP

1. Set up the database for the ERP:
```
bx cf create-service bx cf create-service elephantsql turtle logistics-wizard-erp-db
```
1. Then clone `logistics-wizard-erp` repo:
```
git clone https://IBM-Bluemix/logistics-wizard-erp
cd logistics-wizard-erp
```

1. Build and push the image to docker hub or you can use the already created image at `swayr/logistics-wizard-erp-cf-docker`.
```
docker build -t <username>/logistics-wizard-erp:latest .
docker push <username>/logistics-wizard-erp:latest
```
1. Create the ERP microservice in bluemix without starting it using the docker image you created above
```
bx cf push <erp-name> --docker-image=<username>/logistics-wizard-erp:latest --no-start
bx cf bind-service <erp-name> logistics-wizard-erp-db
```
1. Start the ERP microservice
```
bx cf start <erp-name>
```
1. After starting the ERP microservice, you can verify it is running by hitting `https://<erp-name>.mybluemix.net/explorer`

## Set up the Controller Service

1. Clone the controller repo:
```
git clone https://IBM-Bluemix/logistics-wizard-controller
cd logistics-wizard-controller
```
1. Build and push the image to docker hub or you can use the already created image at `swayr/logistics-wizard-controller`.
```
docker build -t <username>/logistics-wizard-controller:latest .
docker push <username>/logistics-wizard-controller:latest
```
1. Create the controller microservice in bluemix without starting it using the docker image you created above
```
bx cf push <controller-name> --docker-image=<username>/logistics-wizard-controller:latest --no-start
```
1. Set the environment variables for the controller to connect to the ERP and use OpenWhisk actions
```
bx cf set-env <controller-name> ERP_SERVICE 'https://lw-erp-cf-docker.mybluemix.net/explorer'
bx cf set-env <controller-name> OPENWHISK_AUTH <openwhisk-auth>
bx cf set-env <controller-name> OPENWHISK_PACKAGE lwr
```
1. Start the controller microservice
```
bx cf start <controller-name>
```

## Set up the OpenWhisk Actions

1. Create the services needed for OpenWhisk
```
bx cf create-service weatherinsights Free-v2 logistics-wizard-weatherinsights
bx cf create-service cloudantNoSQLDB Lite logistics-wizard-recommendation-db
```

1. Create service keys for both services and take note of the URL values:
```
bx cf create-service-key logistics-wizard-weatherinsights for-openwhisk
bx cf create-service-key logistics-wizard-recommendation-db for-openwhisk
bx cf service-key logistics-wizard-weatherinsights for-openwhisk
bx cf service-key logistics-wizard-recommendation-db for-openwhisk
```

1. Clone the logistics-wizard-recommendation repo:
```
git clone https://IBM-Bluemix/logistics-wizard-recommendation
cd logistics-wizard-recommendation
```
1. Copy the local env template file
```
cp template-local.env local.env
```
1. Using the URL values from above update the `local.env` file to look like the following:
```
PACKAGE_NAME=lwr
CONTROLLER_SERVICE=<controller-service-url>
WEATHER_SERVICE=<logistics-wizard-weatherinsights-url>
CLOUDANT_URL=<logistics-wizard-recommendation-db-url>
CLOUDANT_DATABASE=recommendations
```
1. Build your openwhisk actions:
```
npm install
npm run build
```
1. Deploy your OpenWhisk actions:
```
./deploy.sh --install
```

## Set up the WebUI

1. Clone the logistics-wizard-webui repo:
```
git clone https://github.com/IBM-Bluemix/logistics-wizard-webui
cd logistics-wizard-webui
```
1. Install the dependencies
```
npm install
```
1. Build the static files for the UI using the appropriate environment variables
```
CONTROLLER_SERIVCE='<controller-service-url>' GOOGLE_MAPS_KEY='<google-maps-api-key>' npm run deploy:prod
```
1. Deploy the app to bluemix
```
cd dist
bx cf push <webui-name> -b staticfile_buildpack
```
