#!/bin/bash

echo "wail for Kibana ready"
sleep 60

while :
do
    echo "run collector"
    ruby collector.rb
    echo "done. Waiting for next collection.."
    sleep $(( 1 +COLLECTION_INTERVAL_IN_MINUTES * 60))
done

