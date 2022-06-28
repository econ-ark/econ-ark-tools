#!/bin/bash

/var/local/start.sh |& tee -a /var/local/start-and-finish.log |& tee /var/local/start.log

