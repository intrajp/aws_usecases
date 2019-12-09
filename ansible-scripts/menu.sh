#!/bin/bash

##
##  menu.sh 
##  This file contains the contents of aws_usecases.
##
##  Copyright (C) 2019 Shintaro Fujiwara
##
##  This library is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This library is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
##  02110-1301 USA
##

AWS_REGION="ap-northeast-1"
BUCKET_PRIVATE_SHARE=""
FILE_PRIVATE_SHARE=""
CREATE_BUCKET_NAME=""
PRIVATE_SHARE_BUCKET_NAME_FILE="./tasks/s3/tmp/share_private_bucket_name"
PRIVATE_SHARE_FILE_NAME_FILE="./tasks/s3/tmp/share_private_file_name"
BUCKET_NAME_FILE="./tasks/s3/tmp/bucket_file_name"
PROJECT_FILE="./group_vars/project.ansibled.yml"
## just because PWD includes slashes
PWD_COMMENTED=$(echo "${PWD}" | sed 's/\//\\\//g')
sed -i "s/pwd:[ \/a-zA-Z0-9\._\-]*/pwd: ${PWD_COMMENTED}/" "${PROJECT_FILE}"

initialize_variables()
{
    sed -i "s/pwd:[ \/a-zA-Z0-9._\-]*/pwd: \/tmp/" "${PROJECT_FILE}"
    sed -i "s/task_designated:[ \/a-zA-Z0-9\._\-]*/task_designated: sample\.yml/" "${PROJECT_FILE}"
    sed -i "s/bucket_name_create_general:[ \/a-zA-Z0-9\._\-]*/bucket_name_create_general: mybucket/" "${PROJECT_FILE}"
    sed -i "s/aws_region:[ a-zA-Z0-9_\-]*/aws_region: ap-northeast-1/" "${PROJECT_FILE}"
}

show_menu_aws_region()
{
    echo -n "AWS region:"
}

show_menu_create_bucket_name()
{
    echo -n "Bucket name to creat:"
}

show_menu_share_private_dir_name()
{
    echo -n "Bucket name for private share:"
}

show_menu_share_file_name()
{
    echo -n "File name for private share:"
}

ask_aws_region()
{
    show_menu_aws_region
    
    read AWS_REGION
    if [ -z "${AWS_REGION}" ]; then
        AWS_REGION="ap-northeast-1"
    fi
}

ask_share_private_dir_name()
{
    show_menu_share_private_dir_name
    read BUCKET_PRIVATE_SHARE 
    if [ -z "${BUCKET_PRIVATE_SHARE}" ]; then
        echo "share private dir name was not suplied"
        exit 1
    fi
}

ask_share_file_name()
{
    show_menu_share_file_name
    read FILE_PRIVATE_SHARE 
    if [ -z "${FILE_PRIVATE_SHARE}" ]; then
        echo "share file name was not supplied"
        exit 1
    fi
}

ask_create_bucket_name()
{
    show_menu_create_bucket_name
    read CREATE_BUCKET_NAME 
    if [ -z "${CREATE_BUCKET_NAME}" ]; then
        echo "create bucket name was not supplied"
        exit 1
    fi
}

share_private_file_pre_signed_url()
{
    if [ -f "${PRIVATE_SHARE_BUCKET_NAME_FILE}" ]; then
        rm -f "${PRIVATE_SHARE_BUCKET_NAME_FILE}"
    fi
    if [ -f "${PRIVATE_SHARE_FILE_NAME_FILE}" ]; then
        rm -f ${PRIVATE_SHARE_FILE_NAME_FILE} 
    fi

    while true
    do
        ask_share_private_dir_name
        ask_share_file_name
        echo "${BUCKET_PRIVATE_SHARE}" > "${PRIVATE_SHARE_BUCKET_NAME_FILE}" 
        echo "${FILE_PRIVATE_SHARE}" > "${PRIVATE_SHARE_FILE_NAME_FILE}" 
        if [ ! -z "${BUCKET_PRIVATE_SHARE}" ] && [ ! -z "${FILE_PRIVATE_SHARE}" ]; then
            break
        fi
    done

    ## set yml file 
    sed -i "s/task_designated:[ \/a-zA-Z0-9\._\-]*/task_designated: tasks\/s3\/get_presigned_url\.s3.yml/" "${PROJECT_FILE}"
    ## now we execute ansible playbook
    ansible-playbook -vvv -i hosts.inventory s3.yml --ask-vault-pass
    unlink "${PRIVATE_SHARE_BUCKET_NAME_FILE}" 
    unlink "${PRIVATE_SHARE_FILE_NAME_FILE}" 
}

create_bucket()
{
    if [ -f "${BUCKET_NAME_FILE}" ]; then
        rm -f ${BUCKET_NAME_FILE} 
    fi

    while true
    do
        ask_create_bucket_name
        echo "${CREATE_BUCKET_NAME}" > "${BUCKET_NAME_FILE}" 
        if [ ! -z "${CREATE_BUCKET_NAME}" ]; then
            break
        fi
    done

    ## set yml file 
    sed -i "s/task_designated:[ \/a-zA-Z0-9\._\-]*/task_designated: tasks\/s3\/create_bucket\.general\.s3.yml/" "${PROJECT_FILE}"
    sed -i "s/bucket_name_create_general:[ \/a-zA-Z0-9\._\-]*/bucket_name_create_general: ${CREATE_BUCKET_NAME}/" "${PROJECT_FILE}"
    ## now we execute ansible playbook
    ansible-playbook -vvv -i hosts.inventory s3.yml --ask-vault-pass
    unlink "${BUCKET_NAME_FILE}" 
}

sed -i "s/pwd:[ \/a-zA-Z0-9\._\-]*/pwd: ${PWD_COMMENTED}/" "${PROJECT_FILE}"

while true
do
    echo "-- Select AWS region --"
    echo " 1: us-east-2"
    echo " 2: us-east-1"
    echo " 3: us-west-1"
    echo " 4: ap-east-1"
    echo " 5: ap-south-1"
    echo " 6: ap-northeast-3"
    echo " 7: ap-northeast-2"
    echo " 8: ap-southeast-1"
    echo " 9: ap-southeast-2"
    echo " 10: ap-northeast-1"
    echo " 11: ca-central-1"
    echo " 12: cn-north-1"
    echo " 13: cn-northwest-1"
    echo " 14: eu-central-1"
    echo " 15: eu-west-1"
    echo " 16: eu-west-2"
    echo " 17: eu-west-3"
    echo " 18: eu-north-1"
    echo " 19: me-south-1"
    echo " 20: sa-east-1"
    echo " 21: us-gov-east-1"
    echo " 22: us-gov-west-1"
    echo " q: Exit the program"
    read ANS_REGION
    if [ "${ANS_REGION}" = "q" ]; then
        initialize_variables
        exit 0
    fi
    if [ ! -z "${ANS_REGION}" ]; then
        if [ "${ANS_REGION}" = "1" ]; then
            AWS_REGION="us-east-2"
        elif [ "${ANS_REGION}" = "2" ]; then
            AWS_REGION="us-east-1"
        elif [ "${ANS_REGION}" = "3" ]; then
            AWS_REGION="us-west-1"
        elif [ "${ANS_REGION}" = "4" ]; then
            AWS_REGION="ap-east-1"
        elif [ "${ANS_REGION}" = "5" ]; then
            AWS_REGION="ap-south-1"
        elif [ "${ANS_REGION}" = "6" ]; then
            AWS_REGION="ap-northeast-3"
        elif [ "${ANS_REGION}" = "7" ]; then
            AWS_REGION="ap-northeast-2"
        elif [ "${ANS_REGION}" = "8" ]; then
            AWS_REGION="ap-southheast-1"
        elif [ "${ANS_REGION}" = "9" ]; then
            AWS_REGION="ap-southheast-2"
        elif [ "${ANS_REGION}" = "10" ]; then
            AWS_REGION="ap-northeast-1"
        elif [ "${ANS_REGION}" = "11" ]; then
            AWS_REGION="ca-central-1"
        elif [ "${ANS_REGION}" = "12" ]; then
            AWS_REGION="ca-north-1"
        elif [ "${ANS_REGION}" = "13" ]; then
            AWS_REGION="cn-northwest-1"
        elif [ "${ANS_REGION}" = "14" ]; then
            AWS_REGION="eu-central-1"
        elif [ "${ANS_REGION}" = "15" ]; then
            AWS_REGION="eu-west-1"
        elif [ "${ANS_REGION}" = "16" ]; then
            AWS_REGION="eu-west-2"
        elif [ "${ANS_REGION}" = "17" ]; then
            AWS_REGION="eu-west-3"
        elif [ "${ANS_REGION}" = "18" ]; then
            AWS_REGION="eu-north-1"
        elif [ "${ANS_REGION}" = "19" ]; then
            AWS_REGION="me-south-1"
        elif [ "${ANS_REGION}" = "20" ]; then
            AWS_REGION="sa-east-1"
        elif [ "${ANS_REGION}" = "21" ]; then
            AWS_REGION="us-gov-east-1"
        elif [ "${ANS_REGION}" = "22" ]; then
            AWS_REGION="us-gov-west-1"
        fi
        break 
    fi
done

sed -i "s/aws_region:[ a-zA-Z0-9_\-]*/aws_region: ${AWS_REGION}/" "${PROJECT_FILE}"

while true
do
    echo "-- Select what you want to do --"
    echo " 1: Share private file with pre signed url"
    echo " 2: Create a Bucket"
    echo " q: Exit the program"
    read ANS
    if [ "${ANS}" = "q" ]; then
        initialize_variables
        exit 0
    fi
    if [ ! -z "${ANS}" ]; then
        break 
    fi
done

if [ "${ANS}" = "1" ]; then
    share_private_file_pre_signed_url
elif [ "${ANS}" = "2" ]; then
    create_bucket 
fi

initialize_variables

exit 0
