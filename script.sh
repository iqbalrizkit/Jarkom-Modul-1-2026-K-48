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
