#!/bin/sh

# Needed to support writes to otherwise read only memory
. /etc/profile.d/fw_unlock_mmc.sh 

function current() {
  echo ""
  echo "Current setup:"
  fw_printenv image
  fw_printenv fdt_file
  if [ "/usr/sbin/wpa_supplicant" -ef "/usr/sbin/wpa_supplicant.cyw" ]; then
    echo "Link is to Cypress binary"
  fi
  if [ "/usr/sbin/wpa_supplicant" -ef "/usr/sbin/wpa_supplicant.nxp" ]; then
    echo "Link is to NXP binary"
  fi
  if [ -e /etc/depmod.d/nxp_depmod.conf ]; then
    echo "Found depmod helper file for NXP"
  fi
  if [ -e /etc/modprobe.d/nxp_modules.conf ]; then
    echo "Found modprobe helper file for NXP"
  fi
  echo ""
}

function prepare_for_nxp_sdio() {
  if [ -e /usr/sbin/wpa_supplicant ]; then
    rm /usr/sbin/wpa_supplicant
  fi
  ln -s /usr/sbin/wpa_supplicant.nxp /usr/sbin/wpa_supplicant

  cat <<EOT > /etc/depmod.d/nxp_depmod.conf
# Force modprobe to search kernel/net/wireless (where the NXP
# version of cfg80211.ko is placed) before looking in updates/net/wireless/
# (where the Cypress version is)
override cfg80211 * kernel/net/wireless
EOT

  cat <<EOT > /etc/modprobe.d/nxp_modules.conf
# Prevent the Cypress version of cfg80211.ko from being loaded.
blacklist cfg80211

# Alias for the NXP modules
alias sdio:c*v02DFd9149 moal

# Specify arguments to pass when loading the moal module
options moal mod_para=nxp/wifi_mod_para_sd8987.conf
EOT

  depmod -a
}


function prepare_for_nxp_pcie() {
  if [ -e /usr/sbin/wpa_supplicant ]; then
    rm /usr/sbin/wpa_supplicant
  fi
  ln -s /usr/sbin/wpa_supplicant.nxp /usr/sbin/wpa_supplicant

  # Remove nxp_depmod.conf and nxp_modules.conf as we
  # are creating it for PCIe version.

  if [ -e /etc/depmod.d/nxp_depmod.conf ]; then
    rm /etc/depmod.d/nxp_depmod.conf
  fi
  if [ -e /etc/modprobe.d/nxp_modules.conf ]; then
    rm /etc/modprobe.d/nxp_modules.conf
  fi

  cat <<EOT > /etc/depmod.d/nxp_depmod.conf
# Force modprobe to search kernel/net/wireless (where the NXP
# version of cfg80211.ko is placed) before looking in updates/net/wireless/
# (where the Cypress version is)
override cfg80211 * kernel/net/wireless
EOT

  cat <<EOT > /etc/modprobe.d/nxp_modules.conf
# Prevent the Cypress version of cfg80211.ko from being loaded.
blacklist cfg80211
EOT

  depmod -a
}


function prepare_for_cypress() {
  if [ -e /usr/sbin/wpa_supplicant ]; then
    rm /usr/sbin/wpa_supplicant
  fi
  ln -s /usr/sbin/wpa_supplicant.cyw /usr/sbin/wpa_supplicant

  if [ -e /etc/depmod.d/nxp_depmod.conf ]; then
    rm /etc/depmod.d/nxp_depmod.conf
  fi
  if [ -e /etc/modprobe.d/nxp_modules.conf ]; then
    rm /etc/modprobe.d/nxp_modules.conf
  fi

  depmod -a
}

function switch_to_brcm_sdio() {
  echo ""
  echo "Setting up for 1DX, 1LV, 1MW, 1WZ (Broadcom - SDIO)"
  fw_setenv fdt_file fsl-imx8mm-ea-ucom-kit_v2.dtb
  #fw_setenv image Image
  prepare_for_cypress
  echo ""
}

function switch_to_brcm_pcie() {
  echo ""
  echo "Setting up for 1CX, 1VA (Broadcom - PCIe)"
  fw_setenv fdt_file fsl-imx8mm-ea-ucom-kit_v2-pcie.dtb
  #fw_setenv image Image
  prepare_for_cypress
  echo ""
}

function switch_to_nxp_sdio() {
  echo ""
  echo "Setting up for 1ZM (NXP - SDIO)"
  fw_setenv fdt_file fsl-imx8mm-ea-ucom-kit_v2.dtb
  #fw_setenv image Image.1ZM.bin
  prepare_for_nxp_sdio
  echo ""
}

function switch_to_nxp_pcie() {
  echo ""
  echo "Setting up for 1YM (NXP - PCIe)"
  fw_setenv fdt_file fsl-imx8mm-ea-ucom-kit_v2-pcie.dtb
  #fw_setenv image Image.1YM.bin
  prepare_for_nxp_pcie
  echo ""
}


function usage() {
  echo ""
  echo "Usage:"
  echo "  $0  <module>"
  echo ""
  echo "Where:"
  echo "  <module> is one of 1CX, 1DX, 1LV, 1MW, 1VA, 1WZ, 1ZM or current"
  echo ""
}

if [[ $# -eq 0 ]]; then
  current
  usage
  exit 1
fi

case $1 in
  cx|1cx|1CX|va|1va|1VA)
    switch_to_brcm_pcie
    ;;
  dx|1dx|1DX|lv|1lv|1LV|mw|1mw|1MW|wz|1wz|1WZ)
    switch_to_brcm_sdio
    ;;
  zm|1zm|1ZM)
    switch_to_nxp_sdio
    ;;
  ym|1ym|1YM)
    switch_to_nxp_pcie
    ;;
  current|CURRENT)
    current
    ;;
  *)
    current
    usage
    ;;
esac