# NFC to BLE Tag

## About


## BOM

* Raspberry Pi 3B+
* ESP32 devkit
* Sony PaSoRi RC-S380


## Install

### create Python3 venv
```bash
$ cd
$ python3 -m venv env1
($ . ~/env1/bin/activate)
```

### download
```bash
$ cd ~/env1
$ git clone https://www.github.com/ytani01/BleTag.git
```

### install Center

#### setup
```bash
$ cd ~/env1/Nfc2BleTag/center
$ ./setup.sh
```

#### (memo)
in setup.sh
``` bash
sudo setcap 'cap_net_raw,cap_net_admin+eip' $(readlink -f $(which python3))
```

### install Tag

#### Arduino IDE

sketch file
```
~/env1/Nfc2BleTag/tag/ble_observer/ble_observer.ino
```

## References

