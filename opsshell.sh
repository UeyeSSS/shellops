#!/usr/bin/expect
#设置静态网卡
if cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep static
	then echo ip already set static
	else
		sed -i 's/BOOTPROTO=none/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens33
		sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens33
fi
#控制节点"ct"虚拟网卡设置
if cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep 192.168.172.70
	then
		sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens34
		sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens34
		echo "IPADDR=192.168.1.10" >> /etc/sysconfig/network-scripts/ifcfg-ens34
		echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-ens34
		echo "DNS1=114.114.114.114" >> /etc/sysconfig/network-scripts/ifcfg-ens34
		systemctl restart network
	else echo net no operation 70
fi
if [ $? -ne 0 ];then
	echo no transmission
	else
		echo "#/bin/bash" >> net.sh
		echo "if cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep static" >> net.sh
		echo "then echo ip already set static" >> net.sh
		echo "else" >> net.sh
		echo "sed -i 's/BOOTPROTO=none/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens33" >> net.sh
		echo "sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens33" >> net.sh
		echo "fi" >> net.sh
		echo "if cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep 192.168.172.80" >> net.sh
		echo "then" >> net.sh
		echo "sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "IPADDR=192.168.1.20" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "DNS1=114.114.114.114" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "systemctl restart network" >> net.sh
		echo "else echo net no operation 80" >> net.sh
		echo "fi" >> net.sh
		echo "if cat /etc/sysconfig/network-scripts/ifcfg-ens33 | grep 192.168.172.90" >> net.sh
		echo "then" >> net.sh
		echo "sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "IPADDR=192.168.1.30" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "echo "DNS1=114.114.114.114" >> /etc/sysconfig/network-scripts/ifcfg-ens34" >> net.sh
		echo "systemctl restart network" >> net.sh
		echo "else echo net no operation 90" >> net.sh
		echo "fi" >> net.sh
fi
#关闭控制节点防火墙，配置阿里云仓库源
if systemctl status firewalld | grep "running" &>/dev/null
	then
		setenforce 0
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		systemctl stop firewalld
		systemctl disable firewalld
		cd /etc/yum.repos.d/
		mkdir repo.bak
		mv *.repo repo.bak/
		curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
		cd
		yum -y install vim gcc gcc-c++ make cmake wget chrony net-tools bash-completion bind-utils pcre pcre-devel expat-devel bzip2 lrzsz expect
		yum install centos-release-openstack-train -y
		yum install python-openstackclient openstack-selinux -y
		yum -y install openstack-utils
		cd /root
	else
		echo firewalld is already shut
fi
#三个节点免密
expect <<EOF
set timeout 2
spawn ssh-keygen -t rsa
expect "(/root/.ssh/id_rsa):"
send "\r"
expect "(empty for no passphrase):"
send "\r"
expect "again:"
send "\r"
expect eof
EOF
expect << EOF
set timeout 2
spawn ssh-copy-id 192.168.172.70
expect "(yes/no)?"
send "yes"
send "\r"
expect "password:"
send "ops123456"
send "\r"
expect eof
EOF
expect << EOF
set timeout 2
spawn ssh-copy-id 192.168.172.80
expect "(yes/no)?"
send "yes"
send "\r"
expect "password:"
send "ops123456"
send "\r"
expect eof
EOF
expect << EOF
set timeout 2
spawn ssh-copy-id 192.168.172.90
expect "(yes/no)?"
send "yes"
send "\r"
expect "password:"
send "ops123456"
send "\r"
expect eof
EOF
#关闭计算节点、存储节点防火墙，配置软件源
if test -e OpenStackshell.sh
	then 
		echo OpenStackshell is not exists
	else
		echo "#!/bin/bash" >> OpenStackshell.sh
		echo "if cat /etc/selinux/config | grep SELINUX=disabled >> /dev/null" >> OpenStackshell.sh
		echo "then" >> OpenStackshell.sh
		echo "echo firewalld already stop" >> OpenStackshell.sh
		echo "else" >> OpenStackshell.sh
		echo "setenforce 0" >> OpenStackshell.sh
		echo "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config" >> OpenStackshell.sh
		echo "systemctl stop firewalld" >> OpenStackshell.sh
		echo "systemctl disable firewalld" >> OpenStackshell.sh
		echo "fi" >> OpenStackshell.sh
		echo "vim -h >> /etc/null" >> OpenStackshell.sh
		echo "if [ \$? -ne 0 ];then" >> OpenStackshell.sh
		echo "cd /etc/yum.repos.d/" >> OpenStackshell.sh
		echo "mkdir repo.bak" >> OpenStackshell.sh
		echo "mv *.repo repo.bak/" >> OpenStackshell.sh
		echo "curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo" >> OpenStackshell.sh
		echo "cd" >> OpenStackshell.sh
		echo "yum -y install gcc gcc-c++ make cmake wget chrony net-tools bash-completion bind-utils pcre pcre-devel expat-devel bzip2 lrzsz expect vim" >> OpenStackshell.sh
		echo "yum install centos-release-openstack-train -y" >> OpenStackshell.sh
		echo "yum install python-openstackclient openstack-selinux openstack-utils -y" >> OpenStackshell.sh
		echo "rm -rf net.sh" >> OpenStackshell.sh
		echo "else" >> OpenStackshell.sh
		echo "echo Source already installed" >> OpenStackshell.sh
		echo "fi" >> OpenStackshell.sh
fi
scp net.sh root@192.168.172.80:/root
scp net.sh root@192.168.172.90:/root
scp OpenStackshell.sh root@192.168.172.80:/root
scp OpenStackshell.sh root@192.168.172.90:/root
expect << EOF
set timeout 300
spawn ssh -l root 192.168.172.80 "source OpenStackshell.sh"
spawn ssh -l root 192.168.172.80 "source net.sh"
expect eof
EOF
expect << EOF
set timeout 300
spawn ssh -l root 192.168.172.90 "source OpenStackshell.sh"
spawn ssh -l root 192.168.172.90 "source net.sh"
expect eof
EOF
sleep 120 && ls &&
#配置控制节点hosts，并传输脚本给计算节点
if cat /etc/hosts | grep ct
	then
		echo hosts already change
	else
		echo '192.168.1.10 ct' >> /etc/hosts
		echo '192.168.1.20 c1' >> /etc/hosts
		echo '192.168.1.30 c2' >> /etc/hosts
		echo '192.168.172.70 ct' >> /etc/hosts
		echo '192.168.172.80 c1' >> /etc/hosts
		echo '192.168.172.90 c2' >> /etc/hosts
		sed -i 's/::1/#&/' /etc/hosts
		echo "if cat /etc/hosts | grep 'ct' >> /dev/null" >> 1.sh
		echo "then" >> 1.sh
		echo "echo hosts already change" >> 1.sh
		echo "else" >> 1.sh
		echo "echo '192.168.1.10 ct' >> /etc/hosts" >> 1.sh
		echo "echo '192.168.1.20 c1' >> /etc/hosts" >> 1.sh
		echo "echo '192.168.1.30 c2' >> /etc/hosts" >> 1.sh
		echo "echo '192.168.172.70 ct' >> /etc/hosts" >> 1.sh
		echo "echo '192.168.172.80 c1' >> /etc/hosts" >> 1.sh
		echo "echo '192.168.172.90 c2' >> /etc/hosts" >> 1.sh
		echo "sed -i 's/::1/#&/' /etc/hosts" >> 1.sh
		echo "fi" >> 1.sh
fi
#传 输 脚 本 给 计 算 节 点
scp 1.sh root@192.168.172.80:/root
scp 1.sh root@192.168.172.90:/root
##三节点时间同步
if cat /etc/chrony.conf | grep aliyun > /dev/null
	then
		echo it already exists
	else
		sed -i 's/server/#&/' /etc/chrony.conf
		echo server ntp6.aliyun.com iburst >> /etc/chrony.conf
		echo allow all >> /etc/chrony.conf
		systemctl enable chronyd.service
		systemctl restart chronyd.service
		chronyc sources -v
fi
#计算节点跟踪控制节点
if [ $? -ne 0 ];then
echo error
	else
		echo "if cat /etc/chrony.conf | grep 'server ct iburst'" >> 0.sh
		echo "then echo time already" >> 0.sh
		echo "else" >> 0.sh
		echo "sed -i 's/server/#&/' /etc/chrony.conf" >> 0.sh
		echo "echo server ct iburst >>/etc/chrony.conf" >> 0.sh
		echo "systemctl enable chronyd.service" >> 0.sh
		echo "systemctl restart chronyd.service" >> 0.sh
		echo "chronyc sources -v" >> 0.sh
		echo "fi" >> 0.sh
fi
scp 0.sh root@192.168.172.80:/root
scp 0.sh root@192.168.172.90:/root
#基础环境搭建
if test -e /usr/lib64/libibverbs
	then
		echo it already exist
	else
		yum -y install mariadb mariadb-server python2-PyMySQL libibverbs
fi
#初始化数据库
if cat /etc/my.cnf.d/openstack.cnf | grep max > /dev/null
	then
		echo it already exist
	else
		echo [mysqld] >> /etc/my.cnf.d/openstack.cnf
		echo bind-address = 0.0.0.0 >> /etc/my.cnf.d/openstack.cnf
		echo default-storage-engine = innodb >> /etc/my.cnf.d/openstack.cnf
		echo innodb_file_per_table = on >> /etc/my.cnf.d/openstack.cnf
		echo max_connections = 4096 >> /etc/my.cnf.d/openstack.cnf
		echo collation-server = utf8_general_ci >> /etc/my.cnf.d/openstack.cnf
		echo character-set-server = utf8 >> /etc/my.cnf.d/openstack.cnf
		systemctl enable mariadb
		systemctl start mariadb
fi
expect <<EOF
set timeout 1
spawn mysql_secure_installation
expect "(enter for none):"
send "\r"
expect "Set root password?Y/n"
send "y\r"
send "0\r"
send "0\r"
expect "Remove anonymous users?Y/n"
send "y\r"
expect "Disallow root login remotely?Y/n"
send "n\r"
expect "Remove test database and access to it?Y/n"
send "y\r"
expect "Reload privilege tables now?Y/n"
send "y\r"
expect eof
EOF
#安装DB
yum -y install rabbitmq-server
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
sleep 1 && rabbitmqctl add_user openstack RABBIT_PASS &
sleep 2 && rabbitmqctl set_permissions openstack ".*" ".*" ".*" &
sleep 3 && rabbitmq-plugins enable rabbitmq_management &
#安装消息队列
if test -e /etc/sysconfig/memcached
	then
		echo it already exist
	else
		yum install -y memcached python-memcached
fi
if cat /etc/sysconfig/memcached | grep ct >> /dev/null
	then
		echo it already exist
	else
		sed -i 's/::1/::1,ct/g' /etc/sysconfig/memcached
		systemctl enable memcached
		systemctl start memcached
fi
expect << EOF
set timeout 5
spawn ssh -l root 192.168.172.80 "source 0.sh"
spawn ssh -l root 192.168.172.80 "source 1.sh"
spawn ssh -l root 192.168.172.80 "cat 0.sh >> OpenStackshell.sh"
spawn ssh -l root 192.168.172.80 "cat 1.sh >> OpenStackshell.sh"
expect eof
EOF
expect << EOF
set timeout 5
spawn ssh -l root 192.168.172.90 "source 0.sh"
spawn ssh -l root 192.168.172.90 "source 1.sh"
spawn ssh -l root 192.168.172.90 "cat 0.sh >> OpenStackshell.sh"
spawn ssh -l root 192.168.172.90 "cat 1.sh >> OpenStackshell.sh"
expect eof
EOF
#可选择手动密码登录
#read -p "请输入数据库密码：" p
#read -p "请输入需要创建数据库的名称：" name
#echo "passwd:${name}000"
#mysql -p$p << EOF
#create database $name character set utf8;
#grant all privileges on $name.* to $name@'%' identified by "${name}000";
#flush privileges;
#EOF
#自动输入
mysql -p0 <<EOF
create database keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
flush privileges;
exit
EOF
#Keystone初始化配置
if test -f /etc/keystone/keystone.conf
	then
		echo keystone.conf already exist
	else
		yum -y install openstack-keystone httpd mod_wsgi
		cp -a /etc/keystone/keystone.conf{,.bak}
		grep -Ev "^$|#" /etc/keystone/keystone.conf.bak > /etc/keystone/keystone.conf
		openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:KEYSTONE_DBPASS@ct/keystone
		openstack-config --set /etc/keystone/keystone.conf token provider fernet
		su -s /bin/sh -c "keystone-manage db_sync" keystone
		keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
		keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
		keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
		--bootstrap-admin-url http://ct:5000/v3/ \
		--bootstrap-internal-url http://ct:5000/v3/ \
		--bootstrap-public-url http://ct:5000/v3/ \
		--bootstrap-region-id RegionOne
fi
#配置Apache
if test -f /etc/httpd/conf/httpd.conf
	then
		echo "ServerName controller" >> /etc/httpd/conf/httpd.conf
		ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
		systemctl enable httpd
		systemctl start httpd
	else
		echo error
fi
#配置管理员环境变量
cat >> ~/.bashrc << EOF
export OS_USERNAME=admin                        
export OS_PASSWORD=ADMIN_PASS   
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://ct:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
#查看环境变量是否正常
env | grep OS
if [ $? -ne 0 ];then
echo error
	else
		source ~/.bashrc
fi
#创建OpenStack域、项目、用户、角色
openstack project create --domain default --description "Service Project" service
openstack role create user
openstack token issue
#初始化数据库
mysql -p0 <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
flush privileges;
exit
EOF
#创建glance用户
openstack user create --domain default --password GLANCE_PASS glance
#将glance用户添加到service项目中，并且针对这个项目拥有admin权限；注册glance的API，需要对service项目有admin权限
openstack role add --project service --user glance admin
#创建一个service服务，service名称为glance，类型为image；创建完成后可以通过 openstack service list 查看
openstack service create --name glance --description "OpenStack Image" image
#创建镜像服务 API 端点，OpenStack使用三种API端点代表三种服务：admin、internal、public
openstack endpoint create --region RegionOne image public http://ct:9292
openstack endpoint create --region RegionOne image internal http://ct:9292
openstack endpoint create --region RegionOne image admin http://ct:9292
#修改glance-api参数
if [ $? -ne 0 ];then
echo error
	else
		yum -y install openstack-glance
		cp -a /etc/glance/glance-api.conf{,.bak}
		grep -Ev '^$|#' /etc/glance/glance-api.conf.bak > /etc/glance/glance-api.conf
		openstack-config --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:GLANCE_DBPASS@ct/glance
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://ct:5000
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://ct:5000
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers ct:11211
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_name service
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken username glance
		openstack-config --set /etc/glance/glance-api.conf keystone_authtoken password GLANCE_PASS
		openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
		openstack-config --set /etc/glance/glance-api.conf glance_store stores file,http
		openstack-config --set /etc/glance/glance-api.conf glance_store default_store file
		openstack-config --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
fi
if [ $? -ne 0 ];then
echo error
	else
		su -s /bin/sh -c "glance-manage db_sync" glance
		systemctl enable openstack-glance-api.service
		systemctl start openstack-glance-api.service
		chown -hR glance:glance /var/lib/glance/
fi
#测试镜像
if test -f /etc/cirros-0.5.0-x86_64-disk.img
	then
		openstack image create --file /etc/cirros-0.5.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public cirros
	else
		wget --no-check-certificate -P /etc/ https://github.com/cirros-dev/cirros/releases/download/0.5.0/cirros-0.5.0-x86_64-disk.img
		openstack image create --file /etc/cirros-0.5.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public cirros
fi
openstack image list
mysql -p0 <<EOF
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'PLACEMENT_DBPASS';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'PLACEMENT_DBPASS';
flush privileges;
exit
EOF
#创建placement用户
openstack user create --domain default --password PLACEMENT_PASS placement
#给与placement用户对service项目拥有admin权限
openstack role add --project service --user placement admin
#创建一个placement服务，服务类型为placement
openstack service create --name placement --description "Placement API" placement
#注册API端口到placement的service中；注册的信息会写入到mysql中
openstack endpoint create --region RegionOne placement public http://ct:8778
openstack endpoint create --region RegionOne placement internal http://ct:8778
openstack endpoint create --region RegionOne placement admin http://ct:8778
if [ $? -ne 0 ];then
echo error
	else
		yum -y install openstack-placement-api
		cp -a /etc/placement/placement.conf{,.bak}
		grep -Ev '^$|#' /etc/placement/placement.conf.bak > /etc/placement/placement.conf
		openstack-config --set /etc/placement/placement.conf placement_database connection mysql+pymysql://placement:PLACEMENT_DBPASS@ct/placement
		openstack-config --set /etc/placement/placement.conf api auth_strategy keystone
		openstack-config --set /etc/placement/placement.conf keystone_authtoken auth_url  http://ct:5000/v3
		openstack-config --set /etc/placement/placement.conf keystone_authtoken memcached_servers ct:11211
		openstack-config --set /etc/placement/placement.conf keystone_authtoken auth_type password
		openstack-config --set /etc/placement/placement.conf keystone_authtoken project_domain_name Default
		openstack-config --set /etc/placement/placement.conf keystone_authtoken user_domain_name Default
		openstack-config --set /etc/placement/placement.conf keystone_authtoken project_name service
		openstack-config --set /etc/placement/placement.conf keystone_authtoken username placement
		openstack-config --set /etc/placement/placement.conf keystone_authtoken password PLACEMENT_PASS
fi
su -s /bin/sh -c "placement-manage db sync" placement
if [ $? -ne 0 ];then
echo error
	else
		cd /etc/httpd/conf.d
		echo "<Directory /usr/bin>" >> 00-placement-api.conf
		echo "<IfVersion >= 2.4>" >> 00-placement-api.conf
		echo "Require all granted" >> 00-placement-api.conf
		echo "</IfVersion>" >> 00-placement-api.conf
		echo "<IfVersion < 2.4>" >> 00-placement-api.conf
		echo "Order allow,deny" >> 00-placement-api.conf
		echo "Allow from all" >> 00-placement-api.conf
		echo "</IfVersion>" >> 00-placement-api.conf
		echo "</Directory>" >> 00-placement-api.conf
		cd
fi
systemctl restart httpd
placement-status upgrade check
mysql -p0 <<EOF
CREATE DATABASE nova_api;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
flush privileges;
exit
EOF
#创建nova用户
openstack user create --domain default --password NOVA_PASS nova
#把nova用户添加到service项目，拥有admin权限
openstack role add --project service --user nova admin
#创建nova服务
openstack service create --name nova --description "OpenStack Compute" compute
#给Nova服务关联endpoint（端点）
openstack endpoint create --region RegionOne compute public http://ct:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://ct:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://ct:8774/v2.1
if [ $? -ne 0 ];then
echo error
	else
		yum -y install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler
		cp -a /etc/nova/nova.conf{,.bak}
		grep -Ev '^$|#' /etc/nova/nova.conf.bak > /etc/nova/nova.conf
		openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
		openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.1.10
		openstack-config --set /etc/nova/nova.conf DEFAULT use_neutron true
		openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
		openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct
		openstack-config --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:NOVA_DBPASS@ct/nova_api
		openstack-config --set /etc/nova/nova.conf database connection mysql+pymysql://nova:NOVA_DBPASS@ct/nova
		openstack-config --set /etc/nova/nova.conf placement_database connection mysql+pymysql://placement:PLACEMENT_DBPASS@ct/placement
		openstack-config --set /etc/nova/nova.conf api auth_strategy keystone
		openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://ct:5000/v3
		openstack-config --set /etc/nova/nova.conf keystone_authtoken memcached_servers ct:11211
		openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_type password
		openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default
		openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default
		openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
		openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
		openstack-config --set /etc/nova/nova.conf keystone_authtoken password NOVA_PASS
		openstack-config --set /etc/nova/nova.conf vnc enabled true
		openstack-config --set /etc/nova/nova.conf vnc server_listen '$my_ip'
		openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'
		openstack-config --set /etc/nova/nova.conf glance api_servers http://ct:9292
		openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
		openstack-config --set /etc/nova/nova.conf placement region_name RegionOne
		openstack-config --set /etc/nova/nova.conf placement project_domain_name Default
		openstack-config --set /etc/nova/nova.conf placement project_name service
		openstack-config --set /etc/nova/nova.conf placement auth_type password
		openstack-config --set /etc/nova/nova.conf placement user_domain_name Default
		openstack-config --set /etc/nova/nova.conf placement auth_url http://ct:5000/v3
		openstack-config --set /etc/nova/nova.conf placement username placement
		openstack-config --set /etc/nova/nova.conf placement password PLACEMENT_PASS
		openstack-config --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300
fi
#初始化nova_api数据库
su -s /bin/sh -c "nova-manage api_db sync" nova
#注册cell0数据库；nova服务内部把资源划分到不同的cell中，把计算节点划分到不同的cell中；openstack内部基于cell把计算节点进行逻辑上的分组
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
#创建cell1单元格
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
#初始化nova数据库；可以通过 /var/log/nova/nova-manage.log 日志判断是否初始化成功
su -s /bin/sh -c "nova-manage db sync" nova
#验证cell0和cell1是否注册成功
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
if [ $? -ne 0 ];then
echo error
	else
		systemctl start openstack-nova-api openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
		systemctl enable openstack-nova-api openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
		systemctl status openstack-nova-api openstack-nova-scheduler openstack-nova-conductor openstack-nova-novncproxy
		netstat -tnlup|egrep '8774|8775'
		curl http://ct:8774
fi
if test -e 2.sh
	then
		echo error
	else
		echo "if test -e /etc/nova/nova.conf">> 2.sh
		echo "then echo nova.conf already exists">> 2.sh
		echo "else">> 2.sh
		echo "yum -y install openstack-nova-compute" >> 2.sh
		echo "cp -a /etc/nova/nova.conf{,.bak}" >> 2.sh
		echo "grep -Ev '^$|#' /etc/nova/nova.conf.bak > /etc/nova/nova.conf" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.1.20" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT use_neutron true" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_allocate_retries 300" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_allocate_retries_interval 10" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_creation_timeout 600" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf api auth_strategy keystone" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://ct:5000/v3" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken memcached_servers ct:11211" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_type password" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken password NOVA_PASS" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc enabled true" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc server_listen 0.0.0.0" >> 2.sh
		echo  openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address \''$my_ip'\' >> 2.sh
		#echo "openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address 192.168.1.20" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc novncproxy_base_url http://192.168.172.70:6080/vnc_auto.html" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf glance api_servers http://ct:9292" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement region_name RegionOne" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement project_domain_name Default" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement project_name service" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement auth_type password" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement user_domain_name Default" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement auth_url http://ct:5000/v3" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement username placement" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf placement password PLACEMENT_PASS" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300" >> 2.sh
		echo "systemctl start libvirtd.service openstack-nova-compute.service" >> 2.sh
		echo "systemctl enable libvirtd.service openstack-nova-compute.service" >> 2.sh
		echo "fi" >> 2.sh
fi
if test -e 3.sh
	then echo errot
	else
		echo "if test -e /etc/nova/nova.conf">> 3.sh
		echo "then echo nova.conf already exists">> 3.sh
		echo "else">> 3.sh
		echo "yum -y install openstack-nova-compute" >> 3.sh
		echo "cp -a /etc/nova/nova.conf{,.bak}" >> 3.sh
		echo "grep -Ev '^$|#' /etc/nova/nova.conf.bak > /etc/nova/nova.conf" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.1.30" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT use_neutron true" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_allocate_retries 300" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_allocate_retries_interval 10" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf DEFAULT block_device_creation_timeout 600" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf api auth_strategy keystone" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://ct:5000/v3" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken memcached_servers ct:11211" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_type password" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf keystone_authtoken password NOVA_PASS" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc enabled true" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc server_listen 0.0.0.0" >> 3.sh
		echo  openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address \''$my_ip'\' >> 3.sh
		#echo "openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address 192.168.1.30" >> 2.sh
		echo "openstack-config --set /etc/nova/nova.conf vnc novncproxy_base_url http://192.168.172.70:6080/vnc_auto.html" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf glance api_servers http://ct:9292" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement region_name RegionOne" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement project_domain_name Default" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement project_name service" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement auth_type password" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement user_domain_name Default" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement auth_url http://ct:5000/v3" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement username placement" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf placement password PLACEMENT_PASS" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu" >> 3.sh
		echo "openstack-config --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300" >> 3.sh
		echo "systemctl start libvirtd.service openstack-nova-compute.service" >> 3.sh
		echo "systemctl enable libvirtd.service openstack-nova-compute.service" >> 3.sh
		echo "fi" >> 3.sh
fi
#传送和执行脚本
scp 2.sh root@192.168.172.80:/root
scp 3.sh root@192.168.172.90:/root
expect << EOF
set timeout 300
spawn ssh -l root 192.168.172.80 "source 2.sh"
spawn ssh -l root 192.168.172.80 "cat 2.sh >> OpenStackshell.sh"
spawn ssh -l root 192.168.172.90 "source 3.sh"
spawn ssh -l root 192.168.172.90 "cat 3.sh >> OpenStackshell.sh"
expect eof
EOF
#验证api
sleep 5 && su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova &
if [ $? -ne 0 ];then
echo error
	else
		systemctl restart openstack-nova-api.service
fi
sleep 5 && openstack compute service list &
sleep 1 && openstack catalog list &
sleep 5 && nova-status upgrade check &
mysql -p0 <<EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';
flush privileges;
exit
EOF
#创建neutron用户，用于在keystone做认证
openstack user create --domain default --password NEUTRON_PASS neutron
#将neutron用户添加到service项目中拥有管理员权限
openstack role add --project service --user neutron admin
#创建network服务，服务类型为network
openstack service create --name neutron --description "OpenStack Networking" network
#注册API到neutron服务，给neutron服务关联端口，即添加endpoint
openstack endpoint create --region RegionOne network public http://ct:9696
openstack endpoint create --region RegionOne network internal http://ct:9696
openstack endpoint create --region RegionOne network admin http://ct:9696
#安装提供者网络
if [ $? -ne 0 ];then
echo error
	else
		yum -y install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables conntrack-tools
		cp -a /etc/neutron/neutron.conf{,.bak}
		grep -Ev '^$|#' /etc/neutron/neutron.conf.bak > /etc/neutron/neutron.conf
		openstack-config --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:NEUTRON_DBPASS@ct/neutron
		openstack-config --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
		openstack-config --set /etc/neutron/neutron.conf DEFAULT service_plugins router
		openstack-config --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips true
		openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct
		openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
		openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes true
		openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes true
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://ct:5000
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://ct:5000
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers ct:11211
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
		openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password NEUTRON_PASS
		openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
		openstack-config --set /etc/neutron/neutron.conf nova  auth_url http://ct:5000
		openstack-config --set /etc/neutron/neutron.conf nova  auth_type password
		openstack-config --set /etc/neutron/neutron.conf nova  project_domain_name default
		openstack-config --set /etc/neutron/neutron.conf nova  user_domain_name default
		openstack-config --set /etc/neutron/neutron.conf nova  region_name RegionOne
		openstack-config --set /etc/neutron/neutron.conf nova  project_name service
		openstack-config --set /etc/neutron/neutron.conf nova  username nova
		openstack-config --set /etc/neutron/neutron.conf nova  password NOVA_PASS
		cp -a /etc/neutron/plugins/ml2/ml2_conf.ini{,.bak}
		grep -Ev '^$|#' /etc/neutron/plugins/ml2/ml2_conf.ini.bak > /etc/neutron/plugins/ml2/ml2_conf.ini
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vlan,vxlan
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  linuxbridge,l2population
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  provider
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
		openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  true
		cp -a /etc/neutron/plugins/ml2/linuxbridge_agent.ini{,.bak}
		grep -Ev '^$|#' /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak > /etc/neutron/plugins/ml2/linuxbridge_agent.ini
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:ens33
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  true
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.10
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
		openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
fi
if cat /etc/sysctl.conf | grep net.bridge.bridge-nf-call-iptables=1
	then
		echo it already exists
	else
		echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
		echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf
		modprobe br_netfilter
		sysctl -p
fi
if [ $? -ne 0 ];then
echo error
	else
		cp -a /etc/neutron/l3_agent.ini{,.bak}
		grep -Ev '^$|#' /etc/neutron/l3_agent.ini.bak > /etc/neutron/l3_agent.ini
		openstack-config --set /etc/neutron/l3_agent.ini DEFAULT interface_driver linuxbridge
		cp -a /etc/neutron/dhcp_agent.ini{,.bak}
		grep -Ev '^$|#' /etc/neutron/dhcp_agent.ini.bak > /etc/neutron/dhcp_agent.ini
		openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver linuxbridge
		openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
		openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata true
		cp -a /etc/neutron/metadata_agent.ini{,.bak}
		grep -Ev '^$|#' /etc/neutron/metadata_agent.ini.bak > /etc/neutron/metadata_agent.ini
		openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host ct
		openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret METADATA_SECRET
		openstack-config --set /etc/nova/nova.conf neutron url http://ct:9696
		openstack-config --set /etc/nova/nova.conf neutron auth_url http://ct:5000
		openstack-config --set /etc/nova/nova.conf neutron auth_type password
		openstack-config --set /etc/nova/nova.conf neutron project_domain_name default
		openstack-config --set /etc/nova/nova.conf neutron user_domain_name default
		openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
		openstack-config --set /etc/nova/nova.conf neutron project_name service
		openstack-config --set /etc/nova/nova.conf neutron username neutron
		openstack-config --set /etc/nova/nova.conf neutron password NEUTRON_PASS
		openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy true
		openstack-config --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret METADATA_SECRET
		ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
		su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
		--config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
		systemctl restart openstack-nova-api.service
		systemctl enable neutron-server.service \
		neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
		neutron-metadata-agent.service
		systemctl start neutron-server.service \
		neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
		neutron-metadata-agent.service
		systemctl enable neutron-l3-agent.service
		systemctl restart neutron-l3-agent.service
fi
#对计算节点脚本操作
if [ $? -ne 0 ];then
echo error
	else
		echo "if test -e /etc/neutron/neutron.conf" >> 4.sh
		echo "then" >> 4.sh
		echo "echo neutron.conf already exists" >> 4.sh
		echo "else" >> 4.sh
		echo "yum -y install openstack-neutron-linuxbridge ebtables ipset conntrack-tools" >> 4.sh
		echo "cp -a /etc/neutron/neutron.conf{,.bak}" >> 4.sh
		echo "grep -Ev '^$|#' /etc/neutron/neutron.conf.bak > /etc/neutron/neutron.conf" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://ct:5000" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://ct:5000" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers ct:11211" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password NEUTRON_PASS" >> 4.sh
		echo "openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp" >> 4.sh
		echo "cp -a /etc/neutron/plugins/ml2/linuxbridge_agent.ini{,.bak}" >> 4.sh
		echo "grep -Ev '^$|#' /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak > /etc/neutron/plugins/ml2/linuxbridge_agent.ini" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:ens33" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan true" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.20" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true" >> 4.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" >> 4.sh
		echo "fi" >> 4.sh
		echo "if cat /etc/sysctl.conf | grep net.bridge.bridge-nf-call-iptables=1" >> 4.sh
		echo "then" >> 4.sh
		echo "echo sysctl.conf already change" >> 4.sh
		echo "else" >> 4.sh
		echo "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf" >> 4.sh
		echo "echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf" >> 4.sh
		echo "modprobe br_netfilter" >> 4.sh
		echo "sysctl -p" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron auth_url http://ct:5000" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron auth_type password" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron project_domain_name default" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron user_domain_name default" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron project_name service" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron username neutron" >> 4.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron password NEUTRON_PASS" >> 4.sh
		echo "systemctl restart openstack-nova-compute.service" >> 4.sh
		echo "systemctl enable neutron-linuxbridge-agent.service" >> 4.sh
		echo "systemctl start neutron-linuxbridge-agent.service" >> 4.sh
		echo "fi" >> 4.sh
fi
if [ $? -ne 0 ];then
echo error
	else
		echo "if test -e /etc/neutron/neutron.conf" >> 5.sh
		echo "then" >> 5.sh
		echo "echo neutron.conf already exists" >> 5.sh
		echo "else" >> 5.sh
		echo "yum -y install openstack-neutron-linuxbridge ebtables ipset conntrack-tools" >> 5.sh
		echo "cp -a /etc/neutron/neutron.conf{,.bak}" >> 5.sh
		echo "grep -Ev '^$|#' /etc/neutron/neutron.conf.bak > /etc/neutron/neutron.conf" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://ct:5000" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://ct:5000" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers ct:11211" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password NEUTRON_PASS" >> 5.sh
		echo "openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp" >> 5.sh
		echo "cp -a /etc/neutron/plugins/ml2/linuxbridge_agent.ini{,.bak}" >> 5.sh
		echo "grep -Ev '^$|#' /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak > /etc/neutron/plugins/ml2/linuxbridge_agent.ini" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:ens33" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan true" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.30" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true" >> 5.sh
		echo "openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" >> 5.sh
		echo "fi" >> 5.sh
		echo "if cat /etc/sysctl.conf | grep net.bridge.bridge-nf-call-iptables=1" >> 5.sh
		echo "then" >> 5.sh
		echo "echo sysctl.conf already change" >> 5.sh
		echo "else" >> 5.sh
		echo "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf" >> 5.sh
		echo "echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf" >> 5.sh
		echo "modprobe br_netfilter" >> 5.sh
		echo "sysctl -p" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron auth_url http://ct:5000" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron auth_type password" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron project_domain_name default" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron user_domain_name default" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron project_name service" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron username neutron" >> 5.sh
		echo "openstack-config --set /etc/nova/nova.conf neutron password NEUTRON_PASS" >> 5.sh
		echo "systemctl restart openstack-nova-compute.service" >> 5.sh
		echo "systemctl enable neutron-linuxbridge-agent.service" >> 5.sh
		echo "systemctl start neutron-linuxbridge-agent.service" >> 5.sh
		echo "fi" >> 5.sh
fi
#传送脚本
scp 4.sh root@192.168.172.80:/root
scp 5.sh root@192.168.172.90:/root
expect << EOF
set timeout 300
spawn ssh -l root 192.168.172.80 "source 4.sh"
spawn ssh -l root 192.168.172.80 "cat 4.sh >> OpenStackshell.sh"
spawn ssh -l root 192.168.172.80 "source 5.sh"
spawn ssh -l root 192.168.172.90 "cat 5.sh >> OpenStackshell.sh"
expect eof
EOF
#验证
sleep 1 && openstack extension list --network &
sleep 1 && openstack network agent list &
mysql -p0 <<EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'CINDER_DBPASS';
flush privileges;
exit
EOF
#创建cinder用户,密码设置为CINDER_PASS
openstack user create --domain default --password CINDER_PASS cinder
#把cinder用户添加到service服务中，并授予admin权限
openstack role add --project service --user cinder admin
#cinder有v2和v3两个并存版本的API，所以需要创建两个版本的service实例
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
#给v2和v3版本的api创建endpoint
openstack endpoint create --region RegionOne volumev2 public http://ct:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://ct:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://ct:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 public http://ct:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://ct:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://ct:8776/v3/%\(project_id\)s
if [ $? -ne 0 ];then
echo error
	else
		yum -y install openstack-cinder
		cp /etc/cinder/cinder.conf{,.bak}
		grep -Ev '#|^$' /etc/cinder/cinder.conf.bak>/etc/cinder/cinder.conf
		openstack-config --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:CINDER_DBPASS@ct/cinder
		openstack-config --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct
		openstack-config --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://ct:5000
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://ct:5000
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ct:11211
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name service
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder
		openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password CINDER_PASS
		openstack-config --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.10
		openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
fi
su -s /bin/sh -c "cinder-manage db sync" cinder
if [ $? -ne 0 ];then
echo error
	else
		openstack-config --set /etc/nova/nova.conf cinder os_region_name RegionOne
		systemctl restart openstack-nova-api.service
		systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
		systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
fi
#验证
sleep 5 && cinder service-list &
if test -e 6.sh
	then
		echo error
	else
		echo "if test -e /etc/cinder/cinder.conf" >> 6.sh
		echo "then" >> 6.sh
		echo "echo cinder.conf already exists" >> 6.sh
		echo "else" >> 6.sh
		echo "yum -y install openstack-cinder targetcli python-keystone" >> 6.sh
		echo "yum -y install lvm2 device-mapper-persistent-data " >> 6.sh
		echo "systemctl enable lvm2-lvmetad.service " >> 6.sh
		echo "systemctl start lvm2-lvmetad.service " >> 6.sh
		echo "pvcreate /dev/sdb " >> 6.sh
		echo "vgcreate cinder-volumes /dev/sdb " >> 6.sh
		echo "sed -i '142ifilter = [ \"a/sdb/\",\"r/.*/\" ]' /etc/lvm/lvm.conf " >> 6.sh
		echo "systemctl restart lvm2-lvmetad.service " >> 6.sh
		echo "cp /etc/cinder/cinder.conf{,.bak} " >> 6.sh
		echo "grep -Ev '#|^$' /etc/cinder/cinder.conf.bak>/etc/cinder/cinder.conf " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:CINDER_DBPASS@ct/cinder " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@ct " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.30 " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://ct:9292 " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://ct:5000 " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://ct:5000 " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ct:11211 " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_type password " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name service " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password CINDER_PASS " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver" >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf lvm target_protocol iscsi " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf lvm target_helper lioadm " >> 6.sh
		echo "openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp" >> 6.sh
		echo "systemctl enable openstack-cinder-volume.service target.service " >> 6.sh
		echo "systemctl start openstack-cinder-volume.service target.service" >> 6.sh
		echo "fi" >> 6.sh
fi
if [ $? -ne 0 ];then
echo error
	else
		scp 6.sh root@192.168.172.90:/root
fi
expect <<EOF
set timeout 300
spawn ssh -l root 192.168.172.90 "source 6.sh"
spawn ssh -l root 192.168.172.90 "cat 6.sh >> OpenStackshell.sh"
expect eof
EOF
#验证
sleep 3 && openstack volume service list &
if [ $? -ne 0 ];then
echo error
	else
		echo "if test -e /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "then" >> 7.sh
		echo "echo dashboard already exists" >> 7.sh
		echo "else" >> 7.sh
		echo "yum -y install openstack-dashboard httpd " >> 7.sh
		echo "sed -i \"s/horizon.example.com', 'localhost/*/g\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i "\'s/127.0.0.1/ct/g\'" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"100iCACHES = {\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"101i'default': {\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"102i'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"103i'LOCATION': 'ct:11211',\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"104i},\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"105i}\" /etc/openstack-dashboard/local_settings" >> 7.sh
		echo "sed -i \"124iOPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'Default'\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"125iOPENSTACK_KEYSTONE_DEFAULT_ROLE = 'user'\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"126iOPENSTACK_API_VERSIONS = {\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"s/check': True,/check': False,/g\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"127i'identity': 3,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"128i'image': 2,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"129i'volume': 3,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"130i}\" /etc/openstack-dashboard/local_settings ">> 7.sh
		echo "sed -i \"s/check': True,/check': False,/g\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"141i'enable_lb': False,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"142i'enable_firewall': False,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"143i'enable_vpn': False,\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "sed -i \"s#UTC#Asia/Shanghai#g\" /etc/openstack-dashboard/local_settings " >> 7.sh
		echo "cd /usr/share/openstack-dashboard" >> 7.sh
		echo "python manage.py make_web_conf --apache > /etc/httpd/conf.d/openstack-dashboard.conf" >> 7.sh
		echo "systemctl enable httpd.service" >> 7.sh
		echo "systemctl restart httpd.service" >> 7.sh
		echo "fi" >> 7.sh
fi
scp 7.sh root@192.168.172.80:/root
expect <<EOF
set timeout 300
spawn ssh -l root 192.168.172.80 "source 7.sh"
spawn ssh -l root 192.168.172.80 "cat 7.sh >> OpenStackshell.sh"
expect eof
EOF
expect <<EOF
set timeout 300
spawn ssh -l root 192.168.172.80 "source OpenStackshell.sh"
spawn ssh -l root 192.168.172.90 "source OpenStackshell.sh"
expect eof
EOF
expect << EOF
set timeout 5
spawn ssh -l root 192.168.172.80 "rm -rf 0.sh 1.sh 2.sh 4.sh 7.sh net.sh"
expect eof
EOF
expect << EOF
set timeout 5
spawn ssh -l root 192.168.172.90 "rm -rf 0.sh 1.sh 3.sh 5.sh 6.sh net.sh"
expect eof
EOF
rm -rf 0.sh  1.sh  2.sh  3.sh  4.sh  5.sh  6.sh  7.sh net.sh OpenStackshell.sh
sleep 10 && systemctl restart memcached.service &
echo "-—————————————————————————————————-"
echo "|                                 |"
echo "|    OpenStack setup completed!   |"
echo "|      http://192.168.172.80      |"
echo "|        用户名：admin            |"
echo "|        密  码：ADMIN_PASS       |"
echo "|                                 |"
echo "-—————————————————————————————————-"
