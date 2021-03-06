node 'atomia.com' inherits 'linux_base' {

        class { 'adjoin' :
                base_dn => $base_dn,
                ldap_uris => $ldap_uris,
                bind_user => $bind_user,
                bind_password => $bind_password
	}
	class { 'apache_agent' :
		apache_agent_user => $apache_agent_user,
		apache_agent_password => $apache_agent_password,
		use_nfs3 => $use_nfs3,
                atomia_web_content_mount_point => $atomia_web_content_mount_point,
                atomia_web_content_nfs_location => $atomia_web_content_nfs_location,
                atomia_web_config_mount_point => $atomia_web_config_mount_point,
                atomia_web_config_nfs_location => $atomia_web_config_nfs_location,
                apache_conf_dir => $apache_conf_dir,
                atomia_iis_config_nfs_location => $atomia_iis_config_nfs_location,
                iis_config_dir => $iis_config_dir
       }
}
