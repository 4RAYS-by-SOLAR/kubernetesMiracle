#!/bin/bash

mkdir /wpvolume
mkdir /sqlvolume
mkdir /repository

kubectl apply -k ./kuber

kubectl create secret docker-registry reg-cred-secret --docker-server=docker-registry:5000 --docker-username=admin --docker-password=123 -n outsideserver
REGISTRY_NAME="docker-registry"
REGISTRY_IP=$(kubectl get service $REGISTRY_NAME -o jsonpath='{.spec.clusterIP}')
echo "registryname: $REGISTRY_NAME"
echo "registry ip: $REGISTRY_IP"

echo "$REGISTRY_IP $REGISTRY_NAME" >> /etc/hosts
rm -rf /etc/docker/certs.d/$REGISTRY_NAME:5000
mkdir -p /etc/docker/certs.d/$REGISTRY_NAME:5000
cp ./registry/certs/tls.crt /etc/docker/certs.d/$REGISTRY_NAME:5000/ca.crt
cp ./registry/certs/tls.crt /etc/ssl/certs/registry.crt

target_directory="/wpvolume/wp-content/plugins"
source_files="./plugins/*"

while [ ! -d "$target_directory" ]; do
  echo "Wait for Wordpress UP $target_directory..."
  sleep 5
done

if [ -d "$target_directory" ]; then
  echo "Dir $target_directory is exists, copy files.."
  cp -r $source_files "$target_directory/"
  echo "Files success copy into $target_directory."
else
  echo "SOmething Wrong"
  exit 1
fi

WORDPRESSPODIP=$(kubectl get pods -l app=wordpress-frontend -o jsonpath='{.items[0].status.podIP}')
echo "wordpresspodip: $WORDPRESSPODIP"

WORDPRESSPODNAME=$(kubectl get pods -l app=wordpress-frontend -o jsonpath='{.items[0].metadata.name}')
echo "wordpresspodname: $WORDPRESSPODNAME"

if [ -n "$WORDPRESSPODIP" ] && [ -n "$WORDPRESSPODNAME" ]; then
  kubectl exec -it "$WORDPRESSPODNAME" -- /bin/bash -c "
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    wp core install --title='VulnWordpress' --admin_user='admin' --admin_password='admin' --admin_email='admin@example.com' --url='http://$WORDPRESSPODIP:80/' --skip-email --allow-root && \
    wp plugin activate social-warfare --allow-root
  "
fi

docker login docker-registry:5000 -u admin -p 123
docker pull nginx:latest
docker tag nginx:latest docker-registry:5000/nginx:v1
docker push docker-registry:5000/nginx:v1
