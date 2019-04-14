# early-iOS-BluetoothLowEnergy-tests
iOS + Bluetooth Low Energy Tests, 2019

## myFirstPeripheral

myFirstPeripheral advertises one custom GATT service with two characteristics. One readable characteristic returns the utf8 bytes for "*** Hello, would you like some coffee?" for every read.

* GATT service UUID: `0000cafe-0000-1000-8000-00805f9b34fb` (16bit version: `0xcafe`).
  * Readable characteristic. UUID: `0000c0fe-0000-1000-8000-00805f9b34fb` (16bit version: `0xc0fe`).
  * Readable characteristic. UUID: `0000c0ff-0000-1000-8000-00805f9b34fb` (16bit version: `0xc0ff`).

### Linux machine as BLE Central

1. Launch the BLE peripheral app on the iOS device.
2. Run `sudo bluetoothctl`. Within bluetoothctl:
3. type `list` to see Bluetooth controllers. If you want to use a different controller, type `select<tab>` and select a different Bluetooth Low Energy controller.
4. Type `paired-devices`, and use the `remove` command to remove the iOS device / "Health Thermometer" if already paired.
5. `power on`
6. `agent on`
7. `default-agent`
8. `scan on`
9. Wait for the iOS Device or "myFirstPeripheral" to show up in the scan. If it's not showing up, make sure the iOS device is unlocked and the BLE peripheral app is running in the foreground.

10. `connect<tab>` and connect to the device.
11. Accept the pairing request if there is one.
12. `menu gatt`
13. `select-attribute 0000c0ff-0000-1000-8000-00805f9b34fb`
14. `read`
15. `read`
16. `read`

Sample output

```
[bluetooth]# connect 43:06:32:87:63:44
Attempting to connect to 43:06:32:87:63:44
[CHG] Device 43:06:32:87:63:44 Connected: yes
Connection successful
...
[NEW] Primary Service
	/org/bluez/hci0/dev_43_06_32_87_63_44/service003e
	0000cafe-0000-1000-8000-00805f9b34fb
	Unknown
[NEW] Characteristic
	/org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char003f
	0000c0fe-0000-1000-8000-00805f9b34fb
	Unknown
[NEW] Characteristic
	/org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041
	0000c0ff-0000-1000-8000-00805f9b34fb
	Unknown
[myFirstPeripheral]# menu gatt
[myFirstPeripheral:/service003e/char0041]# read
Attempting to read /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041
[CHG] Attribute /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041 Value:
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 31     Read request #1
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 31     Read request #1

[myFirstPeripheral:/service003e/char0041]# read
Attempting to read /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041
[CHG] Attribute /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041 Value:
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 32     Read request #2
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 32     Read request #2

[myFirstPeripheral:/service003e/char0041]# read
Attempting to read /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041
[CHG] Device 8C:8E:F2:AB:73:76 RSSI: -60
[CHG] Attribute /org/bluez/hci0/dev_43_06_32_87_63_44/service003e/char0041 Value:
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 33     Read request #3
  52 65 61 64 20 72 65 71 75 65 73 74 20 23 33     Read request #3
```

Note: To make my test code a little simpler and easier to follow, I cheated and used 16bit UUIDs without registering them with the Bluetooth SIG. See https://stackoverflow.com/questions/10243769/what-range-of-bluetooth-uuids-can-be-used-for-vendor-defined-profiles.