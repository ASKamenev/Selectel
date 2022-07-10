# Selectel
This code was designed to implement several rabbitmq servers with haproxy as the load balancer. 
All code was prepaired to work with Openstack provider.

Here is a file tree:
.
├── roles
│   ├── haproxy
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   |   └── haproxy_config.j2
│   └── rabbitmq
│       ├── files
│       │   ├── erlang-latest.repo
│       │   └── rabbitmq.conf
│       └── tasks
│           └── main.yml
├── templates
│   └── inventory.tmpl
├── deploy_servers.yml
├── main.tf
├── old_terraform_code
├── receive.py
├── send.py
└── vars.tf

To deploy the rabbitmq servers, you need to run terrafor code firstly:
[user@host ~]$ terraform apply

It will create all necessry resources in Openstack such as: network, subnet, fip, volumes, instances, etc and also generated inventpry and some var file for ansible.
After all deployment wil done, please wait until all three nodes will become available and run ansible code:
[user@host ~]$ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ./inventory --private-key $(PATH_TO_KEY) deploy_servers.yml

In this step, ansible will install all necessery packages and copy haproxy and rabbitmq configs in to the nodes. 
Right after ansible is done, you can check how it's working with two python scripts: send.py and recieve.py
Please note, that you will need to set a correct IP for pika.ConnectionParameters functions.
First, execute send.py - it will create a queue with name hello and send about 10 messages. You'll want to check the queues status on your nodes. One of the was to check all three server at once is ansible-console tool:
[user@host ~]$ ANSIBLE_HOST_KEY_CHECKING=False ansible-console -i inventory -l rabbitmq -b

then type: rabbitmqctl list_queues. It shows you something like that:
root@all (3)[f:5]# rabbitmqctl list_queues
92.53.100.163 | CHANGED | rc=0 >>
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
hello	48
45.136.180.191 | CHANGED | rc=0 >>
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
hello	28
45.136.180.132 | CHANGED | rc=0 >>
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
hello	26

Now, let's try to recieve all messeges from one of the servers. just run recieve.py with appropriate IP and voila! Here is your's messeges. 
