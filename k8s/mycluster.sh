#! /bin/bash

ZONE=europe-west1-d
CLUSTER_NAME=my-k8s-cluster
function create_cluster() {
        NUM_NODE=1 
        if [[ ! -z $1 ]]; then
          echo $1 is number
	  NUM_NODE=$1
        fi
           
	gcloud container clusters create $CLUSTER_NAME --num-nodes $NUM_NODE --zone $ZONE
}

function resize_cluster() {
 if [[ -z $1 ]]; then
   echo Please provide the number to resize to.;
   return 3
 fi
 NUM_NODES=$1
 gcloud container clusters resize   $CLUSTER_NAME --num-nodes=$NUM_NODES --zone $ZONE;
}

function delete_cluster() {
	gcloud container clusters delete $CLUSTER_NAME --zone $ZONE 
}
