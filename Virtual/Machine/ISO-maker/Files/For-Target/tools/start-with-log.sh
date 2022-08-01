#!/bin/bash

bash -c "/var/local/start.sh 2>&1 |& tee -a /var/local/status/start-and-finish.log |& tee /var/local/status/start.log"


