#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=ACME package - LuCI interface
LUCI_DEPENDS:=+luci-base +acme

PKG_MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
PKG_LICENSE:=GPL-3.0-or-later

# When this package lives in the LuCI feed itself, ../../luci.mk is used.
# Standalone feeds (like this fork) build against the luci.mk of the LuCI
# feed checked out by the OpenWrt SDK instead.
LUCI_MK:=$(firstword $(wildcard ../../luci.mk) $(wildcard $(TOPDIR)/feeds/luci/luci.mk))
ifeq ($(LUCI_MK),)
$(error luci.mk not found - add the LuCI feed to feeds.conf)
endif
include $(LUCI_MK)

# call BuildPackage - OpenWrt buildroot signature
