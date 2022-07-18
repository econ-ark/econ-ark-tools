#!/bin/bash

bash -c "/var/local/start.sh |& tee -a /var/local/status/start-and-finish.log |& tee /var/local/status/start.log"


