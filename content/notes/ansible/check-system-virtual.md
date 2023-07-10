---
title: "Check if system is virtual"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
- snippet
---

This is useful for running tasks that are specific to physical or virtual hosts
(e.g. bluetooth and power management on a laptop host).

```yml
- name: Check if system is virtual
  lineinfile:
    line: QEMU
    dest: /sys/devices/virtual/dmi/id/sys_vendor
    state: present
  check_mode: true
  register: virtual
  failed_when: virtual is failed
  ignore_errors: true

- name: System is physical
  set_fact:
    physical: true
    virtual: false
  when: virtual is changed

- name: System is virtual
  set_fact:
    physical: false
    virtual: true
  when: virtual

- name: Run when physical
  debug:
    msg: System is physical!
  when: physical

- name: Run when virtual
  debug:
    msg: System is virtual!
  when: virtual
```

- Replace `QEMU` with the virtualization tool used (`KVM`, `VirtualBox`, `VMware. Inc.` etc.)

## References
- [How to check if a system is virtual](https://iranzo.io/blog/2021/05/10/how-to-check-if-a-system-is-virtual/)
- [Check if server is physical or virtual](https://www.golinuxcloud.com/check-if-server-is-physical-or-virtual/)
