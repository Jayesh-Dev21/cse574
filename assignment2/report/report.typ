#set page(
  paper: "a4",
  margin: (top: 1.6cm, bottom: 1.6cm, left: 2.2cm, right: 2.2cm),
  numbering: "1",
)

#set text(font: "Liberation Serif", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#set figure(gap: 4pt)
#show figure.caption: set text(size: 9pt)

// Title
#align(center)[
  #text(size: 13pt, weight: "bold")[CSE574: Cloud Computing] \
  #v(2pt)
  #text(size: 11pt)[Indian Institute of Technology (BHU) Varanasi] \
  #v(6pt)
  #text(size: 12pt, weight: "bold")[Assignment 2: Creating an Ubuntu Virtual Machine] \
  #v(4pt)
  #text(size: 11pt)[Instructor: Dr. Prasenjit Chanak] \
  #v(8pt)
  #table(
    columns: (auto, auto),
    stroke: none,
    inset: (x: 4pt, y: 3pt),
    align: left,
    [*Name:*], [Jayesh Krishan Puri],
    [*Branch:*], [Mining Engineering, 3rd Year B.Tech],
    [*Roll No:*], [24155058],
    [*Date:*], [18 August 2026],
    [*GitHub*], [https://github.com/Jayesh-Dev21],
  )
]

#line(length: 100%)
#v(4pt)

= Host Machine Specifications

The assignment was completed on a personal laptop running *CachyOS* (an Arch Linux-based rolling-release distribution) with *KDE Plasma* as the primary desktop. A secondary bare-metal Arch Linux installation with the *i3 tiling window manager* is also maintained for testing new kernel releases and patches.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: (x: 6pt, y: 5pt),
  [*OS*], [CachyOS (Arch Linux-based, rolling release)],
  [*CPU*], [x86\_64, hardware virtualisation enabled],
  [*RAM*], [16 GB],
  [*Storage*], [500 GB NVMe SSD],
  [*Hypervisor*], [QEMU/KVM + libvirt (virt-manager)],
)

Since QEMU/KVM is the native Linux hypervisor and does not require out-of-tree kernel modules (unlike VirtualBox on a rapidly-updating Arch system), it was chosen over Oracle VirtualBox. The core objective of the assignment -- creating a VM with specified resources and installing Ubuntu -- is fully met.

= VM Configuration

The virtual machine was created using *virt-manager* with the following configuration, satisfying the assignment requirements:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: (x: 6pt, y: 5pt),
  [*VM Name*], [ubuntu Server],
  [*RAM*], [2 GB (2048 MiB)],
  [*vCPUs*], [2 (host-passthrough mode)],
  [*Disk*], [20 GB, VirtIO controller],
  [*Network*], [VirtIO NIC, libvirt NAT (default network)],
  [*Display*], [SPICE + VirtIO GPU],
  [*Chipset*], [Q35, QEMU 10.2],
  [*Hypervisor*], [QEMU/KVM (hardware-assisted)],
  [*OS (Guest)*], [Ubuntu Server 26.04],
  [*Login User*], [notadmin / 123456],
)

#figure(
  image("../screenshots/01_config.png", width: 80%),
  caption: [virt-manager hardware summary -- 2 GB RAM, 20 GB disk, VirtIO devices],
)

= Installation Steps

=== Step 1: New VM and ISO Selection

In virt-manager, "New Virtual Machine" was clicked and "Local install media" selected. The Ubuntu Server 26.04 ISO was loaded from the local filesystem.

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/02_new_vm.png", width: 100%), caption: [New VM wizard]),
  figure(image("../screenshots/03_local_iso.png", width: 100%), caption: [Local ISO selection]),
  figure(image("../screenshots/04_server.png", width: 100%), caption: [OS type selection]),
  figure(image("../screenshots/05_cpu_ram.png", width: 100%), caption: [2 GB RAM, 2 vCPUs]),
)

=== Step 2: Disk and VM Name

A 20 GB virtual disk was created. The VM was named "ubuntu Server".

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/06_ssd.png", width: 100%), caption: [20 GB virtual disk]),
  figure(image("../screenshots/07_name.png", width: 100%), caption: [VM name and final summary]),
)

=== Step 3: Boot and Installer Launch

The VM booted from the ISO. GRUB appeared, then the Ubuntu Subiquity installer loaded.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/08_grub.png", width: 100%), caption: [GRUB boot menu]),
  figure(image("../screenshots/09_startup.png", width: 100%), caption: [VM startup from ISO]),
)

=== Step 4: Boot Log and Installer Welcome

The kernel enumerated virtual hardware (VirtIO disk, NIC, USB). The Subiquity installer loaded and showed the welcome/language screen.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/10_boot_log.png", width: 100%), caption: [Initial boot/hardware log]),
  figure(image("../screenshots/11_installer.png", width: 100%), caption: [Installer welcome screen]),
)

=== Step 5: Storage and Profile Configuration

The 20 GB VirtIO disk was detected. Default guided LVM partitioning was selected. A user profile was created: username *notadmin*, password *123456*, hostname configured.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/12_storage.png", width: 100%), caption: [Storage layout -- 20 GB LVM]),
  figure(image("../screenshots/13_profile.png", width: 100%), caption: [User profile setup]),
)

=== Step 6: Installation and Reboot

Packages were installed. On completion, the installer prompted to reboot. The virtual CDROM was ejected and the VM rebooted.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/14_install.png", width: 100%), caption: [Installation progress]),
  figure(image("../screenshots/15_reboot.png", width: 100%), caption: [Reboot prompt after install]),
)

=== Step 7: First Boot and Login

Ubuntu Server booted from the installed disk, ran systemd initialisation, and presented the login prompt. Login was successful with the configured credentials.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/16_first_boot.png", width: 100%), caption: [First boot -- systemd sequence]),
  figure(image("../screenshots/17_login.png", width: 100%), caption: [Ubuntu Server login prompt]),
)

=== Step 8: Verification and Shutdown

Post-login, the shell was accessible confirming a working install. The VM was then cleanly shut down using `sudo shutdown -h now`.

#grid(
  columns: (1fr, 1fr),
  gutter: 6pt,
  figure(image("../screenshots/18_complete.png", width: 100%), caption: [Shell prompt -- system operational]),
  figure(image("../screenshots/20_done.png", width: 100%), caption: [VM "Shut Off" in virt-manager]),
)

= Challenges Faced

No significant challenges were encountered during the installation. Since the virtualization stack was already well-configured with SPICE for display, VirtIO paravirtualised drivers for disk and network, and libvirt managing the KVM backend, the entire setup from VM creation to a working Ubuntu Server login went smoothly without any issues.

= Observations on Virtualization Performance

QEMU/KVM uses hardware virtualisation extensions so most guest code runs directly on the CPU with minimal overhead.

Boot time was roughly 12-15 seconds, close to a bare-metal Ubuntu Server install.

*Memory:* The 2 GB fixed allocation was sufficient for Ubuntu Server. The `virtio-balloon` device allows the hypervisor to reclaim unused guest memory when the VM is idle, which is more efficient than static allocation in VirtualBox.

*Disk:* The guest and host communicate via shared ring buffers, bypassing the overhead of emulating a physical SATA/IDE controller. With the VirtIO driver, disk performance inside the VM approached native NVMe speeds.


#v(20pt)
#line(length: 100%)
#align(center)[
  #text(size: 9pt, fill: luma(100))[CSE574: Cloud Computing | IIT (BHU) Varanasi | 18 August 2026]
]
