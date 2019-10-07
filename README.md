# LAB for IPAM developing and testing

---
To deploy lab into Openstack cloud you should do:

- put clouds.yaml with corrsponded credentionals
- run terraform deployment by
  ```
  # terraform apply --var env_name={MY_SUPER_ENV} --var ssh_private_key_file=~/.ssh/id_rsa_{FOR_MY_SUPER_ENV}
  ```
- save IP addresses from ansible output.
  - Master (control plane) host accesible by ssh (to floating IP).
  - Each slave host accssible by ssh to floating IP, using non-standatrt port 20nnn, where nnn is number of host.
- run docker container with corresponded ansible version and deploy k8s by ansible (see below)

Docker container should be started like:
```
  # docker run -it -v $HOME/{ssh-keys}:/root/.ssh:rw -v $(pwd):/root/ipam-lab:rw  -w /root/ipam-lab xenolog/ansible:2.7 sh
```
To deploy k8s by kubespray You should run ansible 2.7.xxx from docker container by commands:
```
  # cd kubespray
  # ansible-playbook -i ../inventory.yaml ./cluster.yml -vv
```
---
