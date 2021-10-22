#!/bin/bash -e
watch_files=${1}
service=$(echo ${watch_files} | cut -d '.' -f 2 | cut -d '/' -f 3)
echo "service=$service" >> $GITHUB_ENV
echo $service
#for i in `cat $watch_files`;do
  #foldername=`echo $i | cut -d '/' -f 1`
curl -v -X POST https://97f1c09de1c29177f915da607c5920afd9fa5aa7@sonarcloud.io/api/alm_integration/provision_monorepo_projects -d '{"projects":[{"projectKey":"'"ASCOmonodemo.$service"'","projectName":"'"ASCOmonodemo.$service"'","installationKey":"Harishsingh2707/ASCOmonodemo|416288470"}],"organization":"harishsingh2707"}'
#done
oldIFS=${IFS}
IFS=$'\r\n' GLOBIGNORE='*' command eval 'IGNORE_FILES=($(cat $watch_files))'
IFS=${oldIFS}
trigger_deploy="false"

detect_changed_folders() {
  GIT_COMMIT=$(git log --pretty=format:'%h' -n 1)
  GIT_PREVIOUS_COMMIT=$(git log --first-parent origin/master --pretty=format:'%h' -n 1 --skip 1)
  # echo $GIT_COMMIT
  # echo $GIT_PREVIOUS_COMMIT
  folders=$(git diff --name-only ${GIT_COMMIT} ${GIT_PREVIOUS_COMMIT} | sort -u | cut -d '/' -f 1,2 | uniq)
  echo "${folders}"
  export changed_components=${folders}
  # echo "${changed_components}"
}

run_tests() {
  for component in ${changed_components}; do
    # echo "${component}"
    for file in ${IGNORE_FILES[@]}; do
      # echo "$component | $file"
      if echo ${component} | grep -wq ${file}; then
        echo $service >> invoke.list
        break 3
      else
        export trigger_deploy="false"
      fi
    done
  done
}

detect_changed_folders
run_tests

