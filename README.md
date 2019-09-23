LAB for IPAM developing and testing

Docker container should be started like:

  # docker run -it -v $HOME/ssh-kys:/root/.ssh:rw -v $(pwd):/root/ipam-lab:rw  -w /root/ipam-lab xenolog/ansible:2.7 sh

To deploy k8s by kubespray You should run ansible 2.7.xxx from docker container by commands:

  # cd kubespray
  # ansible-playbook -i ../inventory.yaml ./cluster.yml -vv

.