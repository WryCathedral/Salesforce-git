#!/bin/bash
username=$1
isdevhub=$2
client_id=$3
orgUrl=$4
alias=$5
serverKey=$6
sf org login jwt --client-id $client_id --jwt-key-file $serverKey --username $username --instance-url $orgUrl --alias $alias 
