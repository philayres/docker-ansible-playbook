if [ -z VAGRANT_IP ]; then
ADD_HOST_FLAG=
else
ADD_HOST_FLAG=--add-host="$VAGRANT_HOSTNAME:$VAGRANT_IP"
fi

docker run --rm -it \
$ADD_HOST_FLAG \
-u $( id -u $USER ):$( id -g $USER ) \
-v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro \
-v ~/.ansible:/home/$USER/.ansible \
-v ~/.ssh/known_hosts:/home/$USER/.ssh/known_hosts \
-v ~/.ssh/id_rsa:/home/$USER/.ssh/id_rsa \
-v ~/.ssh/id_rsa.pub:/home/$USER/.ssh/id_rsa.pub \
-v $(pwd)/.vagrant/machines/vagrant-fphs-webapp-box/virtualbox/private_key:/home/$USER/.ssh/vagrant_id_rsa \
-v $(pwd)/ssh-config-docker:/home/$USER/.ssh/config \
-v $(pwd):/ansible/playbooks \
--entrypoint bash \
philayres/docker-ansible-playbook
