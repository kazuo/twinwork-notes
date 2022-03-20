# Time Machine

Quick guide in setting up FreeBSD as a Time Machine target. 

## `samba`

If not using Active Directory, be sure deselect anything AD related in the config

```
sudo make -C /usr/ports/net/samba413/ -DOPTIONS_UNSET=X11 install clean
sudo sysrc samba_server_enable=YES
```

You'll need to create local users in FreeBSD prior to setting up Samba users. 

```
sudo smbpasswd -a myusername
```

An example of `/usr/local/etc/smb4.conf` that has two TM targets for different Macs. (Prior to this, ensure the path for the TM targets exist)


```
[global]
    workgroup = MYWORKGROUP
    security = user
    netbios name = myserver
    realm = myworkgroup.local
    server string = myserver.tld
    hostname lookups = yes

    load printers = no
    show add printer wizard = no
    time server = yes
    map to guest = Bad User
    use mmap = yes

    dos charset = 850
    unix charset = UTF-8
    mangled names = no

    log level = 0
    vfs objects = fruit streams_xattr zfsacl
    smb encrypt = mandatory

    min protocol = SMB2
    ea support = yes
    socket options = IPTOS_LOWDELAY TCP_NODELAY SO_RCVBUF=65536 SO_SNDBUF=65536
    use sendfile = yes
    min receivefile size = 16384
    getwd cache = true

    fruit:model = MacSamba
    fruit:resource = file
    fruit:metadata = netatalk
    fruit:veto_appledouble = no
    fruit:poxi_rename = yes
    fruit:zero_file_id = yes
    fruit:wipe_intentionally_left_blank_rfork = yes
    fruit:delete_empty_adfiles = yes
; time machines
[mbp13-2019]
    path = /timemachine/mbp13-2019
    read only = no
    browseable = no
    hosts allow = 192.168.1.
    fruit:time machine = yes
    fruit:time machine max size = 1T
    valid users = myusername
[mbp15-2014]
    path = /timemachine/mbp15-2014
    read only = no
    browseable = no
    hosts allow = 192.168.1.
    fruit:time machine = yes
    fruit:time machine max size = 2T
    valid users = myotheruser                              
```

You can use this command on the Mac itself
```
sudo tmutil setdestination smb://myusername:mySuperSECRETSMBpassword@myserver/mbp15-2014
```

One thing I haven't tested is what happens when you're connected on a different WiFi network... will it still attempt to connnect to the SMB server with both my username/password? Supposedly
encryption is enabled (via `smb encrypt = mandatory`), but haven't tested what really happens
on a different network
