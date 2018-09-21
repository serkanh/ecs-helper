#!/bin/sh
#set -x

usage(){
	echo 'ecs-helper {profile} {cluster}'
}
PROFILE=$1
CLUSTER=$2

if [  $# -le 1 ] 
	then 
		usage
		exit 1
	fi 

getTaskArns(){
	aws --profile=${PROFILE} ecs list-tasks --cluster ${CLUSTER} --output text --query 'taskArns[*]'
}


# Gets currently running task arns in a given cluster
taskArns=$(getTaskArns)


getTaskDefArns(){
	for taskArn in ${taskArns[@]}
	do 
		aws --profile=${PROFILE} ecs describe-tasks --cluster ${CLUSTER} --tasks $(echo ${taskArn} | cut -d '/' -f2) --query 'tasks[].taskDefinitionArn' --output text
	done
}

# Get the task definions associated with running tasks
taskDefArns=$(getTaskDefArns)

getTaskImages(){
	for taskDefArn in ${taskDefArns[@]}
	do
		echo $(aws --profile=${PROFILE} ecs describe-task-definition --task-definition 	${taskDefArn} --query 'taskDefinition.{family:family,image:containerDefinitions[].image[]}')
	done
}

getTaskImages