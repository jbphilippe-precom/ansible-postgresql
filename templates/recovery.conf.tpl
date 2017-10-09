standby_mode = 'on'
primary_conninfo = 'host={{ postgresql_master_host }} port=5432 user={{ postgresql_replication_user }}'
recovery_target_timeline = 'latest'
