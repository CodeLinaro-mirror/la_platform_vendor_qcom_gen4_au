ifeq ($(TARGET_KERNEL_VERSION), 5.4)
EMAC_ROOT := $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos
$(shell mkdir -p $(PWD)/kernel/msm-5.4//drivers/net/ethernet/qualcomm/emac-dwc-eqos)
$(shell cp -f $(PWD)/vendor/qcom/opensource/data-kernel/drivers/emac-dwc-eqos/* \
$(EMAC_ROOT))
$(shell rm -f $(EMAC_ROOT)/Makefile)
$(shell rm -f $(EMAC_ROOT)/Makefile.am)
$(shell rm -f $(EMAC_ROOT)/Kbuild)
$(shell mv -f $(EMAC_ROOT)/Makefile.builtin $(EMAC_ROOT)/Makefile)
$(shell sed -i '/drivers\/net\/ethernet\/qualcomm\/emac-dwc-eqos\/Kconfig/d' \
$(PWD)/kernel/msm-5.4/drivers/net/ethernet/Kconfig)
$(shell echo "source \"drivers/net/ethernet/qualcomm/emac-dwc-eqos/Kconfig"\" >> $(PWD)/kernel/msm-5.4/drivers/net/ethernet/Kconfig)
$(shell sed -i '/obj-y += emac-dwc-eqos/d' \
$(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/Makefile)
$(shell echo "obj-y += emac-dwc-eqos/" >> $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/Makefile)

$(shell mkdir -p $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos-app)
$(shell mv $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos/DWC_ETH_QOS_app.c $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos-app/)
$(shell mv $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos/Makefile_app.builtin $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos-app/Makefile)
$(shell mv $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos/Kconfig_app $(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/emac-dwc-eqos-app/Kconfig)
$(shell sed -i '/drivers\/net\/ethernet\/qualcomm\/emac-dwc-eqos-app\/Kconfig/d' \
$(PWD)/kernel/msm-5.4/drivers/net/ethernet/Kconfig)
$(shell echo "source \"drivers/net/ethernet/qualcomm/emac-dwc-eqos-app/Kconfig"\" >> $(PWD)/kernel/msm-5.4/drivers/net/ethernet/Kconfig)
$(shell sed -i '/obj-y += emac-dwc-eqos-app/d' \
$(PWD)/kernel/msm-5.4/drivers/net/ethernet/qualcomm/Makefile)
$(shell echo "obj-y += emac-dwc-eqos-app/" >> $(PWD)/kernel/msm-5.4//drivers/net/ethernet/qualcomm/Makefile)
endif
