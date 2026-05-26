# KVM Windows XML Snippets

Use estes blocos no XML da VM pelo `virsh edit NOME_DA_VM` ou pelo editor XML do virt-manager.

## Intel CPU

```xml
<hyperv mode="custom">
  <relaxed state="on"/>
  <vapic state="on"/>
  <spinlocks state="on" retries="8191"/>
  <vpindex state="on"/>
  <runtime state="on"/>
  <synic state="on"/>
  <stimer state="on">
    <direct state="on"/>
  </stimer>
  <reset state="on"/>
  <vendor_id state="on" value="KVM Hv"/>
  <frequencies state="on"/>
  <reenlightenment state="on"/>
  <tlbflush state="on"/>
  <ipi state="on"/>
  <evmcs state="on"/>
</hyperv>

<cpu mode="host-passthrough" check="none" migratable="on">
  <topology sockets="1" cores="2" threads="2"/>
  <feature policy="require" name="vmx"/>
</cpu>

<clock offset="localtime">
  <timer name="rtc" tickpolicy="catchup"/>
  <timer name="pit" tickpolicy="delay"/>
  <timer name="hpet" present="no"/>
  <timer name="hypervclock" present="yes"/>
</clock>
```

## AMD CPU

```xml
<hyperv mode="custom">
  <relaxed state="on"/>
  <vapic state="on"/>
  <spinlocks state="on" retries="8191"/>
  <vpindex state="on"/>
  <runtime state="on"/>
  <synic state="on"/>
  <stimer state="on">
    <direct state="on"/>
  </stimer>
  <reset state="on"/>
  <vendor_id state="on" value="KVM Hv"/>
  <frequencies state="on"/>
  <reenlightenment state="on"/>
  <tlbflush state="on"/>
  <ipi state="on"/>
</hyperv>

<cpu mode="host-passthrough" check="none" migratable="on">
  <topology sockets="1" cores="2" threads="2"/>
  <feature policy="require" name="svm"/>
</cpu>

<clock offset="localtime">
  <timer name="rtc" tickpolicy="catchup"/>
  <timer name="pit" tickpolicy="delay"/>
  <timer name="hpet" present="no"/>
  <timer name="hypervclock" present="yes"/>
</clock>
```

## DHCP com UFW

```bash
sudo ufw allow in on virbr0
sudo ufw allow out on virbr0
sudo ufw reload
```
