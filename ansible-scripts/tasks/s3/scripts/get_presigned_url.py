## this scripts read from file and echoes pre signed url for file share

import boto3
import sys 
import os

present_dir = os.environ['PWD']
upload_path = "tasks/s3/tmp"

#script_dir = os.path.dirname(__file__) #<-- absolute dir the script is in
# does not work because this is read by ansible

file_path_to_bucket = "share_private_bucket_name"
file_path_to_file = "share_private_file_name"

abs_file_path_of_share_dir_pre = os.path.join(present_dir, upload_path)

abs_file_path_of_share_dir = os.path.join(abs_file_path_of_share_dir_pre, file_path_to_bucket)
abs_file_path_of_share_file = os.path.join(abs_file_path_of_share_dir_pre, file_path_to_file)

f_d = open(abs_file_path_of_share_dir, 'r')
f_f = open(abs_file_path_of_share_file, 'r')

content_d = f_d.read()
content_f = f_f.read()

f_d.close()
f_f.close()

s3 = boto3.client('s3')
url = s3.generate_presigned_url(
    ClientMethod='get_object',
    Params={
        'Bucket': content_d,
        'Key': content_f 
     },
     ExpiresIn=604800 # 7days
)
print(url)
