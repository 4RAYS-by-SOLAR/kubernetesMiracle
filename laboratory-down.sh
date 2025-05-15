#!/usr/bin/env sh
kubectl delete -k ./kuber
rm -r /wpvolume
rm -r /sqlvolume
rm -r /repository
kubectl delete secret reg-cred-secret

ETC_HOSTS=/etc/hosts
HOSTNAME=docker-registry
#delete registrydns from etc/hosts
if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
    then
        echo "$HOSTNAME Found in your $ETC_HOSTS, Removing now...";
        sudo sed -i".bak" "/$HOSTNAME/d" $ETC_HOSTS
    else
        echo "$HOSTNAME was not found in your $ETC_HOSTS";
    fi