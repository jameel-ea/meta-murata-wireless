do_install_append () {
    	install -d ${D}${sbindir}
	install -m 755 ${D}${sbindir}/wpa_supplicant ${D}${sbindir}/wpa_supplicant.nxp
}

FILES_${PN} += "/usr/bin/wpa_supplicant"
