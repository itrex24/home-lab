#!/usr/bin/env bash
# =============================================================================
# Base VM Setup Script (Ubuntu LTS)
# Purpose: Establish a secure, consistent baseline across all VMs
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# 0. Configuration
# -----------------------------------------------------------------------------
TIMEZONE="Europe/London"
ADMIN_USER="antonio"

INSTALL_DOCKER=true
INSTALL_TERRAFORM=true
INSTALL_DEV_TOOLS=true

# -----------------------------------------------------------------------------
# 1. Preflight checks
# -----------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root"
  exit 1
fi

if ! grep -qi ubuntu /etc/os-release; then
  echo "ERROR: This script only supports Ubuntu"
  exit 1
fi

echo "Running on: $(lsb_release -ds)"
echo "Hostname: $(hostname)"

ping -c 1 8.8.8.8 >/dev/null 2>&1 || {
  echo "ERROR: No network connectivity"
  exit 1
}

# -----------------------------------------------------------------------------
# 2. System identity & basics
# -----------------------------------------------------------------------------
timedatectl set-timezone "$TIMEZONE"

apt-get update -y
apt-get install -y locales
locale-gen en_GB.UTF-8
update-locale LANG=en_GB.UTF-8

systemctl enable systemd-timesyncd --now

# -----------------------------------------------------------------------------
# 3. OS updates & kernel hygiene
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y

apt-get autoremove -y
apt-get autoclean -y

REBOOT_REQUIRED=false
[[ -f /var/run/reboot-required ]] && REBOOT_REQUIRED=true

# -----------------------------------------------------------------------------
# 4. Core package baseline
# -----------------------------------------------------------------------------
apt-get install -y \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  software-properties-common \
  unzip \
  zip \
  tree \
  rsync \
  jq \
  bash-completion \
  htop \
  ncdu \
  lsof \
  dnsutils \
  iputils-ping \
  traceroute \
  tcpdump \
  netcat-openbsd \
  sysstat \
  build-essential \
  python3 \
  python3-venv \
  python3-pip

# -----------------------------------------------------------------------------
# 5. User & sudo configuration
# -----------------------------------------------------------------------------
if ! id "$ADMIN_USER" &>/dev/null; then
  useradd -m -s /bin/bash "$ADMIN_USER"
  usermod -aG sudo "$ADMIN_USER"
fi

# -----------------------------------------------------------------------------
# 6. SSH server & hardening
# -----------------------------------------------------------------------------
apt-get install -y openssh-server

SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG"

systemctl enable ssh --now
systemctl reload ssh

# -----------------------------------------------------------------------------
# 7. Firewall baseline
# -----------------------------------------------------------------------------
apt-get install -y ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw --force enable

# -----------------------------------------------------------------------------
# 8. Security hygiene
# -----------------------------------------------------------------------------
apt-get install -y unattended-upgrades fail2ban

dpkg-reconfigure -f noninteractive unattended-upgrades
systemctl enable fail2ban --now

# -----------------------------------------------------------------------------
# 9. Optional platform tooling
# -----------------------------------------------------------------------------
if [[ "$INSTALL_DOCKER" == "true" ]]; then
  echo "Installing Docker..."

  curl -fsSL https://get.docker.com | sh
  usermod -aG docker "$ADMIN_USER"
  systemctl enable docker --now
fi

if [[ "$INSTALL_TERRAFORM" == "true" ]]; then
  echo "Installing Terraform..."

  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg

  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list

  apt-get update -y
  apt-get install -y terraform
fi

if [[ "$INSTALL_DEV_TOOLS" == "true" ]]; then
  apt-get install -y git
fi

# -----------------------------------------------------------------------------
# 10. Filesystem conventions
# -----------------------------------------------------------------------------
mkdir -p /opt /srv
chown root:root /opt /srv
chmod 755 /opt /srv

# -----------------------------------------------------------------------------
# 11. Service enablement
# -----------------------------------------------------------------------------
systemctl daemon-reexec

# -----------------------------------------------------------------------------
# 12. Verification & summary
# -----------------------------------------------------------------------------
echo "----------------------------------------"
echo "Baseline setup complete"
echo "Admin user: $ADMIN_USER"
echo "Docker installed: $INSTALL_DOCKER"
echo "Terraform installed: $INSTALL_TERRAFORM"
echo "Firewall: ENABLED"
echo "SSH: ENABLED"

if [[ "$REBOOT_REQUIRED" == "true" ]]; then
  echo "WARNING: Reboot required"
fi

echo "----------------------------------------"
