#!/bin/bash

# Hostname
hostname_full=$(hostname 2>/dev/null || echo "N/A")

# IP Address
ip_address=$(hostname -I 2>/dev/null | awk '{print $1}')

# OS Version
if [[ -r /etc/os-release ]]; then
  os_version=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"' )
  # fallback if empty
  [[ -z "$os_version" ]] && os_version=$(uname -o 2>/dev/null || echo "Unknown OS")
else
  os_version=$(uname -o 2>/dev/null || echo "Unknown OS")
fi

# Kernel version
kernel_version=$(uname -r 2>/dev/null || echo "Unknown")

# CPU Cores (logical)
if command -v lscpu >/dev/null 2>&1; then
  cpu_cores=$(lscpu -p=CPU | grep -v '^#' | wc -l)
else
  # fallback: /proc/cpuinfo
  cpu_cores=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo "N/A")
fi

# Total RAM in GB (rounded)
if [[ -r /proc/meminfo ]]; then
  mem_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  if [[ "$mem_kb" =~ ^[0-9]+$ ]]; then
    # convert to GB with rounding
    ram_gb=$(awk "BEGIN {printf \"%d\", ($mem_kb/1024/1024) + 0.5}")
    total_ram="${ram_gb} GB"
  else
    total_ram="N/A"
  fi
else
  total_ram="N/A"
fi

# Disk usage on /
disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $5 " used on " $6}')
[[ -z "$disk_usage" ]] && disk_usage="N/A"

# PBS MOM Status detection (process-first, fallback to other hints)
get_pbs_mom_status() {
  # 1. If the pbs_mom process is running, consider it active
  if pgrep -f pbs_mom >/dev/null 2>&1; then
    echo "active (running)"
    return
  fi

  # 2. If there is a systemd unit for pbs.service and it's active, report its state as a hint
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet pbs.service 2>/dev/null; then
      active=$(systemctl is-active pbs.service 2>/dev/null)
      sub=$(systemctl show -p SubState --value pbs.service 2>/dev/null)
      echo "${active} (${sub})"
      return
    elif systemctl list-unit-files | grep -qi '^pbs\.service'; then
      echo "inactive (dead)"
      return
    fi
  fi

  # 3. Legacy service command (if applicable)
  if command -v service >/dev/null 2>&1; then
    svc_output=$(service pbs_mom status 2>&1)
    if echo "$svc_output" | grep -iq 'running'; then
      echo "active (running)"
      return
    elif echo "$svc_output" | grep -Ei 'stopped|inactive|not running' >/dev/null 2>&1; then
      echo "inactive (dead)"
      return
    fi
  fi

  echo "not installed"
}

pbs_status=$(get_pbs_mom_status)

# Print report in exact format

report_file="./${hostname_full}_status.log"

cat > "$report_file" <<EOF
Node Information Report
------------------------
Hostname        : ${hostname_full}
IP Address      : ${ip_address}
OS Version      : ${os_version}
Kernel Version  : ${kernel_version}
CPU Cores       : ${cpu_cores}
Total RAM       : ${total_ram}
Disk Usage      : ${disk_usage}
PBS MOM Status  : ${pbs_status}
EOF
