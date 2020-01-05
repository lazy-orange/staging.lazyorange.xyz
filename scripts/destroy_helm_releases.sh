#!/bin/bash

helm tiller start-ci

helm ls
helm del --purge $(helm ls -q)

helm tiller stop