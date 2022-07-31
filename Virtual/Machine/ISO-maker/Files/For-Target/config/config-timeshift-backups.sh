#!/bin/bash
# timeshift makes automated backups

cp /etc/timeshift.json /etc/timeshift_orig.json

rpl  '"schedule_hourly" : "false",' '"schedule_hourly" : "true",' /etc/timeshift.json
rpl  '"count_monthly" : "2",'       '"count_monthly" : "6",'      /etc/timeshift.json



