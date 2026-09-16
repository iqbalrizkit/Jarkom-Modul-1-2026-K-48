# JARKOM MODUL 1 - THE WIRED

## Member K-48

| Nama | NRP |
| ---- | --- |
| Nama Anggota 1 | NRP Anggota 1 |
| Iqbal Rizki Muhammad Fadhli | 5027251027 |

## Laporan

1. Untuk mempersiapkan pembangunan The Wired, Lain yang berperan sebagai Router membuat tiga Switch/Gateway: Switch 1 menuju dua Entitas yaitu Alice dan Mika, Switch 2 menuju Chisa, sedangkan Switch 3 menuju Knights dan Eiri. Kelima Entitas tersebut dikonfigurasi sebagai Client di GNS3.

![Topologi The Wired](assest/1-The-Wired.png)

Berikut adalah topologi jaringan yang dibangun sesuai dengan permintaan soal, dengan beberapa komponen berikut:
- **NAT**: digunakan agar router Lain dapat memperoleh IP secara dynamic (DHCP) dan terkoneksi ke internet publik.
- **Router Lain**: sebagai pusat routing yang terhubung ke NAT dan menghubungkan seluruh Switch/Gateway.
- **Switch 1, 2, dan 3**: sebagai gateway penghubung antar client yang terkoneksi ke router Lain.
- **Client (Alice, Mika, Chisa, Knights, Eiri)**: entitas yang mensimulasikan node nyata dalam topologi The Wired.

Prefix IP yang digunakan oleh kelompok kami adalah `192.235.x.x`, dengan pembagian sebagai berikut:
| Switch | Terhubung ke | Network |
| ------ | ------------ | ------- |
| Switch 1 | Alice, Mika | 192.235.1.0/24 |
| Switch 2 | Chisa | 192.235.2.0/24 |
| Switch 3 | Knights, Eiri | 192.235.3.0/24 |


<br>


2. Karena menurut Lain pada saat itu The Wired masih terisolasi dari dunia luar, konfigurasikan router Lain agar dapat tersambung langsung ke jaringan internet publik melalui NAT/DHCP pada interface eth0.

Agar router Lain dapat terkoneksi ke internet, interface `eth0` yang terhubung ke NAT dikonfigurasi untuk mendapatkan IP secara DHCP dengan mengedit Network Configuration:
```sh
auto eth0
iface eth0 inet dhcp
```
Tujuannya adalah agar interface **eth0** yang terhubung ke NAT bisa memperoleh alamat IP secara otomatis dari DHCP server.

![KOnfigurasi Router Lain](assest/2-Konfigurasi-Router-Lain.png)

Setelah konfigurasi diterapkan, dilakukan pengecekan menggunakan `ip a` untuk memastikan eth0 sudah mendapatkan IP dari DHCP dan bisa melakukan ping ke internet (misalnya `ping 8.8.8.8`).

![mengecek](assest/2-Cek-ip-ping.png)


<br>


3. Setelah router Lain terhubung ke internet, pastikan seluruh Entitas (Client) di bawah Switch 1, Switch 2, dan Switch 3 dapat saling terhubung dan berkomunikasi satu sama lain melalui konfigurasi routing.

Langkah pertama adalah mengonfigurasi IP pada interface router yang mengarah ke masing-masing switch, sehingga interface tersebut nantinya berperan sebagai gateway bagi client-client di bawahnya. Konfigurasi pada `/etc/network/interfaces` router Lain adalah sebagai berikut:

```sh
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
```

Interface **eth1** (Switch 1) diberi IP `192.235.1.1`, **eth2** (Switch 2) diberi IP `192.235.2.1`, dan **eth3** (Switch 3) diberi IP `192.235.3.1`.

![ip-switch](assets/ip-switch.png)

Selanjutnya dilakukan pengecekan menggunakan `ip -br a` untuk memastikan setiap interface router sudah memiliki alokasi IP yang benar.

![resolve-ip-switch](assets/resolve-ip-switch.png)

Setelah router selesai dikonfigurasi, setiap client diberi IP static beserta gateway sesuai switch tempat ia terhubung. Berikut konfigurasi masing-masing client:

**Alice**

\`\`\`
auto eth0
iface eth0 inet static
  address 10.55.1.2
  netmask 255.255.255.0
  gateway 10.55.1.1
\`\`\`

**Mika**

\`\`\`
auto eth0
iface eth0 inet static
  address 10.55.1.3
  netmask 255.255.255.0
  gateway 10.55.1.1
\`\`\`

**Chisa**

\`\`\`
auto eth0
iface eth0 inet static
  address 10.55.2.2
  netmask 255.255.255.0
  gateway 10.55.2.1
\`\`\`

**Knights**

\`\`\`
auto eth0
iface eth0 inet static
  address 10.55.3.2
  netmask 255.255.255.0
  gateway 10.55.3.1
\`\`\`

**Eiri**

\`\`\`
auto eth0
iface eth0 inet static
  address 10.55.3.3
  netmask 255.255.255.0
  gateway 10.55.3.1
\`\`\`

Hasil akhir konfigurasi interface pada masing-masing client dapat dilihat pada screenshot berikut:

![iface-alice](assets/iface-alice.png) ![iface-mika](assets/iface-mika.png) ![iface-chisa](assets/iface-chisa.png) ![iface-knights](assets/iface-knights.png) ![iface-eiri](assets/iface-eiri.png)

Setelah semua interface dikonfigurasi, dilakukan pengujian ping dari masing-masing client ke seluruh client lainnya untuk membuktikan bahwa seluruh entitas sudah saling terhubung melalui routing pada router Lain.

**Alice to Others**
![alice-ping-others](assets/alice-ping-others.png)

**Mika to Others**
![mika-ping-others](assets/mika-ping-others.png)

**Chisa to Others**
![chisa-ping-others](assets/chisa-ping-others.png)

**Knights to Others**
![knights-ping-others](assets/knights-ping-others.png)

**Eiri to Others**
![eiri-ping-others](assets/eiri-ping-others.png)

4. Lain ingin agar setiap Entitas (Client) memiliki kemandirian di The Wired. Konfigurasikan firewall/iptables (NAT Masquerade) dan DNS resolver agar setiap Client dapat terhubung ke internet secara mandiri (dapat melakukan ping ke 8.8.8.8 dan membuka domain web google.com).

Langkah pertama adalah mengecek nameserver resolving pada router Lain yang sudah terkoneksi ke NAT, melalui file `/etc/resolv.conf`:

![lain-resolve-dns](assets/lain-resolve-dns.png)

Nameserver yang didapat (misalnya `192.168.122.1`) kemudian ditambahkan ke file `/etc/resolv.conf` pada masing-masing client:

\`\`\`
nameserver 192.168.122.1
\`\`\`

![client-resolve-config](assets/client-resolve-config.png)

Selanjutnya, agar trafik dari client dapat diteruskan router menuju internet, dilakukan instalasi `iptables` pada router Lain:

\`\`\`
apt update && apt install iptables -y
\`\`\`

Setelah terinstal, jalankan rule NAT Masquerade berikut:

\`\`\`
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.55.0.0/16
\`\`\`

- `iptables`: tools untuk konfigurasi inbound-outbound sebuah jaringan.
- `-t nat`: menspesifikasikan tabel NAT untuk translasi alamat.
- `-A POSTROUTING`: menambahkan rule pada chain POSTROUTING, yaitu untuk paket yang akan keluar dari sistem.
- `-o eth0`: menspesifikasikan interface keluar, yaitu eth0 yang terhubung ke NAT.
- `-j MASQUERADE`: mengganti source IP paket (dari client) menjadi IP interface eth0 router.
- `-s 10.55.0.0/16`: sumber paket yang di-masquerade, yaitu seluruh subnet The Wired.

![lain-forwarding-ip-firewall](assets/lain-forwarding-ip-firewall.png)

Setelah semua konfigurasi diterapkan, dilakukan pengujian pada masing-masing client dengan melakukan ping ke `8.8.8.8` dan `google.com` untuk membuktikan bahwa setiap client sudah dapat terhubung ke internet secara mandiri.

![client-inet-ok](assets/client-inet-ok.png)

5. Eiri tetap berupaya menanamkan kekacauan ke dalam jaringan. Untuk mengantisipasi restart tiba-tiba, pastikan seluruh konfigurasi jaringan tidak hilang saat semua node di-restart. Buat script verifikasi di `/root/cek_status.sh` pada router Lain yang menampilkan ringkasan interface (`ip -br a`) dan status tabel NAT (`iptables -t nat -L -v -n`) setelah reboot.

Agar konfigurasi tidak hilang saat node di-restart, seluruh konfigurasi interface dan iptables diletakkan pada file `/etc/rc.local` (atau `.bashrc`, tergantung image yang digunakan) sehingga otomatis diterapkan kembali setiap kali node menyala.

**Router Lain**

\`\`\`
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 10.55.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 10.55.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 10.55.3.1
  netmask 255.255.255.0
EOF

apt update
which iptables &>/dev/null || apt install iptables -y

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.55.0.0/16
\`\`\`

**Alice / Mika / Chisa / Knights / Eiri** (contoh untuk Alice)

\`\`\`
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.55.1.2
  netmask 255.255.255.0
  gateway 10.55.1.1
EOF

grep -q "nameserver 192.168.122.1" /etc/resolv.conf || echo "nameserver 192.168.122.1" >> /etc/resolv.conf
\`\`\`

Selanjutnya, dibuat script verifikasi pada router Lain di `/root/cek_status.sh` untuk memastikan konfigurasi jaringan tetap ada setelah reboot:

\`\`\`
cat <<'EOF' > /root/cek_status.sh
#!/bin/bash
echo "=== Ringkasan Interface ==="
ip -br a

echo ""
echo "=== Status Tabel NAT ==="
iptables -t nat -L -v -n
EOF

chmod +x /root/cek_status.sh
\`\`\`

![cek-status-script](assets/cek-status-script.png)

Setelah router Lain di-reboot, script dijalankan untuk membuktikan bahwa seluruh konfigurasi interface dan NAT masih tetap ada:

\`\`\`
/root/cek_status.sh
\`\`\`

![cek-status-result](assets/cek-status-result.png)

Hasil di atas membuktikan bahwa meskipun router direstart, seluruh konfigurasi interface dan rule NAT Masquerade tetap tersimpan dan berjalan dengan baik, sehingga rencana Eiri untuk menanamkan kekacauan melalui restart tidak berhasil.
