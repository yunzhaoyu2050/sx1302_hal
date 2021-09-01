### Environment constants

ARCH ?=
CROSS_COMPILE ?=
export

include ./target.cfg

LOCAL_HOST=localhost
### general build targets

.PHONY: all clean install install_conf libtools libloragw packet_forwarder util_net_downlink util_chip_id util_boot util_spectral_scan

all: libtools libloragw packet_forwarder util_net_downlink util_chip_id util_boot util_spectral_scan

libtools:
	$(MAKE) all -e -C $@

libloragw: libtools
	$(MAKE) all -e -C $@

packet_forwarder: libloragw
	$(MAKE) all -e -C $@

util_net_downlink: libtools
	$(MAKE) all -e -C $@

util_chip_id: libloragw
	$(MAKE) all -e -C $@

util_boot: libloragw
	$(MAKE) all -e -C $@

util_spectral_scan: libloragw
	$(MAKE) all -e -C $@

clean:
	$(MAKE) clean -e -C libtools
	$(MAKE) clean -e -C libloragw
	$(MAKE) clean -e -C packet_forwarder
	$(MAKE) clean -e -C util_net_downlink
	$(MAKE) clean -e -C util_chip_id
	$(MAKE) clean -e -C util_boot
	$(MAKE) clean -e -C util_spectral_scan

install:
ifneq ($(TARGET_IP), localhost)
	$(MAKE) install -e -C libloragw
	$(MAKE) install -e -C packet_forwarder
	$(MAKE) install -e -C util_net_downlink
	$(MAKE) install -e -C util_chip_id
	$(MAKE) install -e -C util_boot
	$(MAKE) install -e -C util_spectral_scan
	ifneq ($(strip $(TARGET_IP)),)
	ifneq ($(strip $(TARGET_DIR)),)
		ifneq ($(strip $(TARGET_USR)),)
		@echo "---- Copying script files to $(TARGET_IP):$(TARGET_DIR)"
		@ssh $(TARGET_USR)@$(TARGET_IP) "mkdir -p $(TARGET_DIR)"
		@scp ./platform/board_install/* $(TARGET_USR)@$(TARGET_IP):$(TARGET_DIR)
		else
		@echo "ERROR: TARGET_USR is not configured in target.cfg"
		endif
	else
		@echo "ERROR: TARGET_DIR is not configured in target.cfg"
	endif
	else
		@echo "ERROR: TARGET_IP is not configured in target.cfg"
	endif
else
	@echo install app to $(TARGET_DIR)
	@mkdir -p "$(TARGET_DIR)/usr/bin"
	@cp ./libloragw/test_loragw_* "$(TARGET_DIR)/usr/bin"
	@cp ./packet_forwarder/lora_pkt_fwd "$(TARGET_DIR)/usr/bin"
	@cp -arf ./platform/board_install/* "$(TARGET_DIR)/"
	@cp ./tools/reset_lgw.sh "$(TARGET_DIR)/usr/bin"
	@cp ./util_boot/boot "$(TARGET_DIR)/usr/bin"
	@cp ./util_chip_id/chip_id "$(TARGET_DIR)/usr/bin"
	@cp ./util_net_downlink/net_downlink "$(TARGET_DIR)/usr/bin"
	@cp ./util_spectral_scan/spectral_scan "$(TARGET_DIR)/usr/bin"
endif

install_conf:
ifneq ($(TARGET_IP), localhost)
	$(MAKE) install_conf -e -C packet_forwarder
else
	@echo install config files to $(TARGET_DIR)
	@mkdir -p "$(TARGET_DIR)/etc/lorawan_gw_config/"
	@cp ./packet_forwarder/global_conf* "$(TARGET_DIR)/etc/lorawan_gw_config/"
endif

### EOF
