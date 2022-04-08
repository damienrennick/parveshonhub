Readme

1. Execute the mksetup.sh as root user with argument non-root user (non-root user which will run Minikube setup)
# cd /opt/MiniKube_fastapi/mksetup

# sh mksetup.sh localuser

2. Execute MiniKube_fastapi\mksetup\mkrun as a non-root user
# sh mkrun.sh localuser

3. Use relevant commands to build infrasturce with Terraform: MiniKube_fastapi\FastApi

# cd /opt/MiniKube_fastapi/FastApi
# #terrform init
# #terraform plan
# #terraform apply
# #terraform destory
