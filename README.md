Role Name
=========

Deploy PostgreSQL 9.3 on Ubuntu Trusty

Requirements
------------

Ansible 2.x and server with Ubuntu Trusty

Role Variables
--------------

	## version ##
	postgresql_version: "9.3"

	## LVM ##
	postgresql_lvcreate: True
	postgresql_vg_name: "vg_vroot"
	postgresql_lv_name: "lv_postgresql"
	postgresql_lv_size: "5g"

	## Variables surchargeables pour le fichier de configuration ##
	## Si non renseignee aucun de soucis ca fonctionne quand meme ##
	postgresql_listen_port: "5432"
	postgresql_listen_addresses: "localhost"
	postgresql_max_connections: "100"
	postgresql_shared_buffers: "128MB"
	postgresql_checkpoint_segments: "3"
	postgresql_effective_cache_size: "128MB"

	## Lieu du template ##
	postgresql_configuration_template: "postgresql.conf.tpl"

	## Locale ##
	postgresql_locale: en_US.UTF8

	## For clustering mode (MANDATORY variables) ##
	postgresql_clustering: yes
	postgresql_wal_level: "hot_standby"
	postgresql_max_wal_senders: 4 ## Should be sum(slave) + 1 for backup ##
	postgresql_hot_standby: "on" ## For clustering, value must be "on"##
	postgresql_replication_user: "replication"
	postgresql_replication_password: "replicationPassword"
	postgresql_listen_addresses: "*"
	postgresql_master_host: 192.168.229.47 ## IP address or full hostname of the master
	postgresql_slaves_hosts: ## must contain the IP address of each cluster node (master and slaves) to allow in pg_hba. ##
		- 192.168.229.47
		- 192.168.229.48
		- 192.168.229.55
	## For clustering mode (OPTIONAL variables) ##
	postgresql_clients_hosts: ## IP address of the client hosts
		- 192.168.229.42


Dependencies
------------

None

Example Playbook Standalone
-----------------------------

	- hosts: servers
    	roles:
        	- { role: ansible-postgresql }
    	vars:
			postgresql_lvcreate: True
			postgresql_lv_size: "42g"

Example Playbook Clustering
-----------------------------
	- hosts: bdd
  	roles:
	    - ansible-postgresql
  	vars:
    	postgresql_clustering: yes
    	postgresql_wal_level: "hot_standby"
    	postgresql_max_wal_senders: 4
    	postgresql_hot_standby: "on"
    	postgresql_replication_user: "replication"
    	postgresql_replication_password: "MonPassWordeuh"
    	postgresql_listen_addresses: "*"
    	postgresql_master_host: 192.168.229.47
			## add master host too to facilitate slave promote ##
    	postgresql_slaves_hosts: ## MANDATORY for clustering ##
	      - 192.168.229.47
	      - 192.168.229.48
	      - 192.168.229.55
    	postgresql_clients_hosts:
	      - 192.168.229.42

Inventory for clustering
---------------------------
	# USAGE FORMAT :
	## postgresql_cluster_state="m" = MASTER  <- MANDATORY
	## postgresql_cluster_state="s" = SLAVE  <- MANDATORY
	## postgresql_slave_sync=True -> DROP SLAVE DATA AND Sync Slave data from MASTER ##  <- FALSE BY DEFAULT, MANDATORY FOR INITIAL CLUSTER CREATION ##
	## postgresql_slave_sync=False -> DO NOT DROP SLAVE DATA AND DO NOT Sync Slave data from MASTER (usefull for adding new node and do not remove already configured node) ##

	[bdd]
	jlstrusty01l.btsys.local postgresql_cluster_state="m"
	jlstrusty02l.btsys.local postgresql_cluster_state="s" postgresql_slave_sync=False
	jlstrusty03l.btsys.local postgresql_cluster_state="s" postgresql_slave_sync=True

Playbook launch
----------------
	 export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -k --ask-become-pass -i hosts --tags installation postgresql.yml


Tags
-------
    [installation] : PostgreSQL server installation
    [rollback] : Go back to a previous PostgreSQL version ### DO NOTHING FOR THE MOMENT ###
    [testing] : Unit testing for a server

 
