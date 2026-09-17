echo "=== ROUTER LAIN ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 192.235.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 192.235.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 192.235.3.1
  netmask 255.255.255.0
EOF

/etc/init.d/networking restart
ip -br a
ping -c 4 8.8.8.8

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

cat /etc/resolv.conf

apt update
apt install iptables -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.235.0.0/24
iptables -t nat -L -v -n

cat <<'EOF' >> /etc/rc.local
sysctl -p
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.235.0.0/24
exit 0
EOF
chmod +x /etc/rc.local

cat <<'EOF' > /root/cek_status.sh
echo "======================================="
echo " STATUS VERIFIKASI ROUTER"
echo "======================================="

echo ""
echo "--- IP Address tiap interface ---"
ip -br a

echo ""
echo "--- IP Forwarding ---"
cat /proc/sys/net/ipv4/ip_forward

echo ""
echo "--- Rule NAT (iptables) ---"
iptables -t nat -L -v -n

echo ""
echo "--- Routing Table ---"
ip route

echo ""
echo "--- Test Ping ke tiap Gateway LAN ---"
ping -c 2 192.235.1.1
ping -c 2 192.235.2.1
ping -c 2 192.235.3.1
EOF
chmod +x /root/cek_status.sh

/root/cek_status.sh


echo "=== ALICE ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 192.235.1.2
  netmask 255.255.255.0
  gateway 192.235.1.1
EOF

/etc/init.d/networking restart
ip a

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
apt update
apt install dnsutils -y

ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 4 192.235.1.3
ping -c 4 192.235.2.2
ping -c 4 192.235.3.2
ping -c 4 192.235.3.3


echo "=== MIKA ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 192.235.1.3
  netmask 255.255.255.0
  gateway 192.235.1.1
EOF

/etc/init.d/networking restart
ip a

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
apt update
apt install dnsutils -y

ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 4 192.235.1.2
ping -c 4 192.235.2.2
ping -c 4 192.235.3.2
ping -c 4 192.235.3.3


echo "=== CHISA ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 192.235.2.2
  netmask 255.255.255.0
  gateway 192.235.2.1
EOF

/etc/init.d/networking restart
ip a

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
apt update
apt install dnsutils -y

ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 4 192.235.1.2
ping -c 4 192.235.1.3
ping -c 4 192.235.3.2
ping -c 4 192.235.3.3


echo "=== KNIGHTS ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 192.235.3.2
  netmask 255.255.255.0
  gateway 192.235.3.1
EOF

/etc/init.d/networking restart
ip a

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
apt update
apt install dnsutils -y

ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 4 192.235.1.2
ping -c 4 192.235.1.3
ping -c 4 192.235.2.2
ping -c 4 192.235.3.3


echo "=== EIRI ==="
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 192.235.3.3
  netmask 255.255.255.0
  gateway 192.235.3.1
EOF

/etc/init.d/networking restart
ip a

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
apt update
apt install dnsutils -y

ping -c 4 8.8.8.8
ping -c 4 google.com
ping -c 4 192.235.1.2
ping -c 4 192.235.1.3
ping -c 4 192.235.2.2
ping -c 4 192.235.3.2


echo "=== CHISA (FTP Server, target ping, telnet server) ==="
mkdir -p /var/wired/data
apt update
apt install vsftpd -y
apt install acl -y
apt install telnetd -y

useradd -m alice
useradd -m mika
useradd -m eiri
passwd alice
passwd mika
passwd eiri

chown alice:alice /var/wired/data
chmod 750 /var/wired/data
setfacl -m u:alice:rwx /var/wired/data
setfacl -m u:mika:r-x /var/wired/data
setfacl -m u:eiri:--- /var/wired/data

nano /etc/vsftpd.conf
service vsftpd restart

useradd -m phantom_user
echo "phantom_user:wired_ghost" | chpasswd
service inetutils-inetd restart
service openbsd-inetd restart

tshark -i eth0 -w /root/capture_ping.pcap &
tshark -i eth0 -w /root/capture_telnet.pcap &
tshark -i eth0 -w /root/capture_ftp_upload.pcap &
tshark -i eth0 -w /root/capture_ftp_mika.pcap &


echo "=== KNIGHTS (uji ping ke Chisa, FTP upload ke Chisa, target port scan, ssh server) ==="
ping -c 77 -s 128 -i 0.3 192.235.2.2

apt update
apt install openssh-server -y
service ssh start

apt install apache2 -y
service apache2 start

apt install ftp -y
wget <link_file_soal8> -O laporan_intelijen.txt
ftp 192.235.2.2

tshark -i eth0 -w /root/capture_scan.pcap &
tshark -i eth0 -w /root/capture_ssh.pcap &

nano /etc/ssh/sshd_config
service ssh restart


echo "=== EIRI (client telnet) ==="
apt update
apt install telnet -y

tshark -i eth0 -w /root/capture_telnet_eiri.pcap &

telnet 192.235.2.2


echo "=== ALICE (port scan dengan netcat) ==="
apt update
apt install netcat -y

nc -zv 192.235.3.2 22
nc -zv 192.235.3.2 80
nc -zv 192.235.3.2 7777


echo "=== MIKA (ssh key + client, FTP download read-only) ==="
apt update
apt install openssh-client -y
apt install ftp -y

useradd -m mika_admin
passwd mika_admin

su - mika_admin
ssh-keygen -t rsa -b 4096
ssh-copy-id mika_admin@192.235.3.2
exit

tshark -i eth0 -w /root/capture_sshkey.pcap &

ssh mika_admin@192.235.3.2

wget <link_file_soal9> -O protokol_tujuh.pdf
ftp 192.235.2.2
