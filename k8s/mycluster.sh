#! /bin/bash

function create_cluster() {
	gcloud container clusters create my-k8s-cluster --num-nodes 2 --zone europe-west1-d
}

function delete_cluster() {
	gcloud container clusters delete my-k8s-cluster --zone europe-west1-d 
}
