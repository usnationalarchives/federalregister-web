#! /bin/bash
set -eu

persist_logs=${PERSIST_LOGS:-false}

if [ "$persist_logs" = "true" ]; then
  log_bucket=$LOG_BUCKET
  hostname=$(hostname)

  if [ "$K8S" = "true" ]; then
    pod_name=$(hostname | rev | cut -d '-' -f 3- | rev)
  else
    pod_name=$(hostname)
  fi

  logs=(/home/app/log/*.gz)
  for ((i=0; i<${#logs[@]}; i++)); do
    log_name=$(echo "${logs[$i]}" | rev | cut -d '/' -f1 | rev)
    year=$(echo "${logs[$i]}" | cut -d '-' -f2 | cut -c1-4)
    month=$(echo "${logs[$i]}" | cut -d '-' -f2 | cut -c5-6)
    upload_path="${year}/${month}/${pod_name}/${hostname}-${log_name}"
    
    if [ ! "$("aws s3 ls s3://${log_bucket}/${upload_path}")" ]; then
      result=$("aws s3 cp ${logs[$i]} s3://${log_bucket}/${upload_path}")
      echo "${result}"
    else
      echo "file ${upload_path} already exists"
    fi
  done
fi