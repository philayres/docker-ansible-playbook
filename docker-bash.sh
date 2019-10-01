#VAGRANT_IP=192.168.1.12
#VAGRANT_HOSTNAME=vagrant-fphs-webapp-box

if [ -z VAGRANT_IP ]; then
ADD_HOST_FLAG=
VAGRANT_PK=
else
ADD_HOST_FLAG=--add-host="$VAGRANT_HOSTNAME:$VAGRANT_IP"
VAGRANT_PK='-v $(pwd)/.vagrant/machines/vagrant-fphs-webapp-box/virtualbox/private_key:/home/$USER/.ssh/vagrant_id_rsa'
fi


docker run --rm -it \
$ADD_HOST_FLAG \
-u $( id -u $USER ):$( id -g $USER ) \
-v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro \
-v ~/.ansible:/home/$USER/.ansible \
-v ~/.ssh/known_hosts:/home/$USER/.ssh/known_hosts \
-v ~/.ssh/id_rsa:/home/$USER/.ssh/id_rsa \
-v ~/.ssh/id_rsa.pub:/home/$USER/.ssh/id_rsa.pub \
$VAGRANT_PK \
-v $(pwd)/ssh-config-docker:/home/$USER/.ssh/config \
-v $(pwd):/ansible/playbooks \
--entrypoint bash \
philayres/docker-ansible-playbook
