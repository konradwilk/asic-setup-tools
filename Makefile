
OPENLANE := $(HOME)/openlane
OPENLANE_TAG := v0.15
CARAVEL := $(HOME)/caravel_user_project
CARAVEL_ROOT := $(CARAVEL)/caravel
PDK_ROOT := $(HOME)/pdk
PDK_PATH := $(PDK_ROOT)/sky130A
CHECKER := $(HOME)/open_mpw_precheck
TAG := mpw-two-c
URL_FPGA := https://github.com/YosysHQ/fpga-toolchain/releases/download/nightly-20210623/fpga-toolchain-linux_x86_64-nightly-20210623.tar.xz
URL_RISC := https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14.tar.gz

all: start magic bashrc openlane cocotb fpga risc checker

.PHONY: start
start:
	sudo apt -y install git screen make vim  build-essential klayout docker.io verilator covered ngspice gtkwave iverilog curl wget gitk
	sudo usermod -aG docker $(USER)


magic-deps:
	sudo apt-get -y install tcl-dev tk-dev csh
	sudo apt-get -y install libglu1-mesa-dev freeglut3-dev mesa-common-dev

.PHONY: magic
magic: magic-deps
	if ! [ -e "magic" ]; then git clone https://github.com/RTimothyEdwards/magic.git;fi
	(cd magic;./configure && make && sudo make install)
	echo "export PATH=/usr/local/bin:$(PATH)" >> $(HOME)/.bashrc

.PHONY: bashrc
bashrc:
	echo "export PDK_ROOT=$(PDK_ROOT)" >> $(HOME)/.bashrc
	echo "export OPENLANE_ROOT=$(OPENLANE)" >> $(HOME)/.bashrc
	echo "export OPENLANE_ROOT=$(OPENLANE)" >> $(HOME)/.bashrc
	echo "export OPENLANE_TAG=$(OPENLANE_TAG)" >> $(HOME)/.bashrc
	echo "export CARAVEL_ROOT=$(CARAVEL_ROOT)" >> $(HOME)/.bashrc
	echo "export PDK_PATH=$(PDK_PATH)" >> $(HOME)/.bashrc

.PHONY: openlane
openlane: bashrc
	if ! [ -e "$(OPENLANE)" ]; then git clone https://github.com/efabless/openlane.git $(OPENLANE); fi
	newgrp docker
	$(MAKE) -C $(OPENLANE) openlane
	$(MAKE) -C $(OPENLANE) pdk
	$(MAKE) -C $(OPENLANE) tests

.PHONY: caravel
caravel:
	if ! [ -e "$(CARAVEL)" ]; then git clone https://github.com/efabless/caravel_user_project.git $(CARAVEL); (cd $(CARAVEL);git checkout $(TAG)); fi
	$(MAKE) -C $(CARAVEL) install
	$(MAKE) -C $(CARAVEL) pdk
	$(MAKE) -C $(CARAVEL) tests

cocotb:
	sudo apt install python3-pip
	sudo pip3 install  cocotb
	sudo pip3 install cocotbext-wishbone


fpga:
	(cd $(HOME);wget $(URL_FPGA))
	(cd /opt;xz -dc $(HOME)/fpga-toolchain*.tar.xz | sudo tar -xvf -)
	echo "export PATH=/opt/fpga-toolchain/bin:$(PATH)" >> $(HOME)/.bashrc

RISC_PATH=$(shell basename $(URL_RISC) .tar.gz)

risc:
	(cd $(HOME);wget $(URL_RISC))
	(cd /opt;gzip -dc $(HOME)/riscv64*.tar.gz | sudo tar -xvf -)
	echo "export PATH=/opt/$(RISC_PATH)/bin:$(PATH)" >> $(HOME)/.bashrc

checker:
	if ! [ -e "$(CHECKER)" ]; then git clone https://github.com/efabless/open_mpw_precheck $(CHECKER); fi
