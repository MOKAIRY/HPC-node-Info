# HPC Node Information Report Script

This Bash script collects and reports essential system information about a node, including hostname, IP address, OS version, kernel version, CPU details, RAM, disk usage, and PBS MOM process status.  
The output is saved as a `.log` file named after the node's hostname.

---

## Features

- **Hostname** – Displays the system’s hostname.  
- **IP Address** – Shows the primary IP address of the machine.  
- **OS Version** – Reads the distribution and version from `/etc/os-release` (with fallback).  
- **Kernel Version** – Retrieves the Linux kernel version.  
- **CPU Cores** – Counts logical CPU cores using `lscpu` or `/proc/cpuinfo`.  
- **Total RAM** – Calculates total memory in GB (rounded).  
- **Disk Usage** – Shows usage percentage for the root (`/`) filesystem.  
- **PBS MOM Status** – Checks if the `pbs_mom` process is running.

---

## Usage

1. **Clone this repository:**
```bash
   git clone https://github.com/MOKAIRY/HPC-node-Info.git
   cd HPC-node-Info
```
2. **Make the script executable:**
```bash
chmod +x node_report.sh
```
3. **Run the script:**
```bash
./node_info.sh
```
4. **Check the output file:**
- A log file named ``<hostname>_status.log`` will be generated in the current directory.

---

## Example Output
```bash
Node Information Report
------------------------
Hostname        : compute-node-01
IP Address      : 192.168.1.10
OS Version      : CentOS Linux 7 (Core)
Kernel Version  : 3.10.0-1160.el7.x86_64
CPU Cores       : 16
Total RAM       : 64 GB
Disk Usage      : 45% used on /
PBS MOM Status  : active (running)
```

---

## Requirements

- Linux-based OS
- Bash shell
- Access to system information files (/proc, /etc/os-release)
- Optional: lscpu command for more accurate CPU core count
---

# Credits
- This work was developed with the support of the Center of Excellence in High Performance Computing ([CEHPC](https://hpc.kau.edu.sa/Default-611997-EN)) during my summer internship.
- Special thanks to the staff at CEHPC:
```bash
  - Dr. Hany Elyamany
  - Dr. Ahmed Mahany
  - Eng. Ayman Shaheen
  - Eng. Abdullah Barghash
  - Eng. Mouhamad Mashat
```
- for their guidance, technical insights, and assistance in creating and testing these scripts.
