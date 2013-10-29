class adjoin(
		$domain_name = $adjoin::params::domain_name,
		$admin_user = $adjoin::params::admin_user,
		$admin_password = $adjoin::params::admin_password
		$base_dn = $adjoin::params::base_dn, 
		$ldap_uris = $adjoin::params::ldap_uris,  
		$bind_user = $adjoin::params::bind_user, 
		$bind_password = $adjoin::params::bind_password
	) inherits adjoin::params {

	if $operatingsystem == 'windows' {

		exec { 'join-domain':
				command => "NETDOM /Domain:$domain_name /user:$admin_user /password:$admin_password MEMBER MYCOMPUTER /JOINDOMAIN"
            	unless => "if((gwmi WIN32_ComputerSystem).Domain -ne \"$domain_name\") { exit 1 }",
            	provider => powershell
			}
	}
	else {
		package { libpam-ldap: ensure => installed }
		package { nscd: ensure => installed }

		file { "/etc/pam.d/common-account":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			source	=> "puppet:///modules/adjoin/common-account",
		}

		file { "/etc/nscd.conf":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			source	=> "puppet:///modules/adjoin/nscd.conf",
			require => Package["nscd"],
			notify => Service["nscd"],
		}

		service { nscd:
			enable => true,
			ensure => running,
			subscribe => File["/etc/nscd.conf"],
		}

		file { "/etc/pam.d/common-auth":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			source	=> "puppet:///modules/adjoin/common-auth",
		}

		file { "/etc/pam.d/common-session":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			source	=> "puppet:///modules/adjoin/common-session",
		}

		file { "/etc/nsswitch.conf":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			source	=> "puppet:///modules/adjoin/nsswitch.conf",
			notify => Service["nscd"],
		}

		$ldap_conf_content = generate("/etc/puppet/modules/adjoin/files/ldap.conf.sh", $base_dn, $ldap_uris, $bind_user, $bind_password)
		file { "/etc/ldap.conf":
			ensure => file,
			owner	=> root,
			group	=> root,
			mode	=> 644,
			content => $ldap_conf_content,
			notify => Service["nscd"],
		}
	}
}
