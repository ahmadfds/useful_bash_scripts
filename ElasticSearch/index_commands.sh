#!/bin/bash

export ESERVER="http://localhost:9200"

# For a concise list of all indices in your cluster, this will give you a list of indices and their aliases.
curl "${ESERVER}/_aliases"

# If you want it pretty-printed, add pretty=true:
curl "${ESERVER}/_aliases?pretty=true"

# This will give you following self explanatory output in a tabular manner
curl "${ESERVER}/_cat/indices?v"