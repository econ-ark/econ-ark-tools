#!/bin/bash

bash -c 'sudo /var/local/finish.sh |& sudo tee /var/local/status/finish.log |& sudo tee -a /var/local/status/start-and-finish.log'
