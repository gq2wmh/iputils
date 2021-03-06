#
# Configuration
#

#指定gcc程序
CC=gcc
#包含内核文件路径的目录
LIBC_INCLUDE=/usr/include
# 加载库
ADDLIB=
# Linker flags
#Wl选项告诉编译器将后面的参数传递给链接器
#-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接,编译时把链接库里的内容加载到C文件中。
LDFLAG_STATIC=-Wl,-Bstatic
#-Wl,-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接，运行的时候把链接库里的内容加载到C文件中。
LDFLAG_DYNAMIC=-Wl,-Bdynamic
#指定加载库cap函数库
LDFLAG_CAP=-lcap
#指定加载库TLS加密函数库
LDFLAG_GNUTLS=-lgnutls-openssl
#指定加载库crypto加密解密函数库
LDFLAG_CRYPTO=-lcrypto
#指定加载库idn恒等函数库
LDFLAG_IDN=-lidn
#指定加载库resolv函数库
LDFLAG_RESOLV=-lresolv
#指定加载库sysfs接口函数库
LDFLAG_SYSFS=-lsysfs

#
# Options
#
#变量定义，设置开关
# Cap函数库的支持(用libcap表示),状态分别为：是，静态，没有
# Capability support (with libcap) [yes|static|no]
USE_CAP=yes
#sysfs函数库的支持(用 libsysfs和deprecated表示)状态分别为：没有，是，静态
# sysfs support (with libsysfs - deprecated) [no|yes|static]
USE_SYSFS=no
# idn函数库的支持(用experimental表示),状态分别为：没有，是，静态
# IDN support (experimental) [no|yes|static]
USE_IDN=no

#默认不使用gentifaddrs函数,状态有：没有，是，静态
# Do not use getifaddrs [no|yes|static]
WITHOUT_IFADDRS=no
#主要介绍了arping默认设备
# arping default device (e.g. eth0) []
ARPING_DEFAULT_DEVICE=

#为ping6这个协议加载TLS加密函数库。状态有：是，否，静态
# GNU TLS library for ping6 [yes|no|static]
#设置默认状态为：是
USE_GNUTLS=yes

#为ping6这个协议加载CRYPTO加密解密函数库。状态有：分享，静态
# Crypto library for ping6 [shared|static]

#设置默认状态为：分享
USE_CRYPTO=shared

#为ping6这个协议加载resolv函数库。选项有：是，静态
# Resolv library for ping6 [yes|static]
#设置默认状态为：是
USE_RESOLV=yes
#ping6的源路由（反对使用RFC5095标准）选项有：否，是，RFC3542标准
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
#设置默认为：否
ENABLE_PING6_RTHDR=no

#是否用RDISC开启服务器功能,选项有:否，是
# rdisc server (-r option) support [no|yes]
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
#如果函数的声明或定义没有指出参数类型，编译器就发出警告
#代表强制转换，代表函数一定要有参数，代表显示所有警告
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
#使用三级优化
CCOPTOPT=-O3
#-D是GCC的参数，后面是一个宏，遵守GNU标准
GLIBCFIX=-D_GNU_SOURCE
DEFINES=
LDLIB=
#符号“$”表示变量或者函数的引用
#函数库支持动态静态链接

FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
#判断要加密解密函数库的函数是否重复
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
#判断CAP函数库中的函数是否重复
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
#判断sysfs接口函数库中的函数是否重复
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
#判断idn恒等函数库中的函数是否重复
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
#判断是否使用了ifaddrs函数接口
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
#判断是否使用了RDISC工具
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
#判断是否使用了PING6
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
#判断是否使用了RFC3542标准
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
#产生伪目标，用来清除临时文件。
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot
#第一个目标all由应用程序$(TARGET)
all: $(TARGETS)


#应用程序的生成方法
$(TARGET_ARCH)
%.s: %.c
#  $< 依赖目标中的第一个目标名字 ，$@ 表示目标
# 在(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
#将.o文件的后缀名去掉
$(TARGETS): %: %.o
# $^ 所有的依赖目标的集合 
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) 
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
# -------------------------------------
# arping
#向相邻主机发送ARP请求
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

#条件语句的开始
ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif
#继续追加
#测算目的主机和本地主机的系统时间差，
# clockdiff
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
#测试计算机名和计算机的ip地址，验证远程登录。
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

#逆地址解析协议的服务端程序。定义了两个预留变量
# rarpd
DEF_rarpd =
LIB_rarpd =
#路由表更新程序。定义了一个预留变量
# rdisc
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =
#路由追踪程序。
# tracepath
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
#tracepath6 - 跟踪路径，网络主机沿着这条路径MTU发现
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
#实用程序使用的IPv6协议Hop Limit字段引出从路径上每个网关的ICMPv6 TIME_EXCEEDED回应一些主机。
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
#简单文本传输协议
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

#tftpd依赖tftpsus.o文件
tftpd: tftpsubs.o
#tftpd.o和tftpsubs.o文件依赖tftp.h头文件
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
#生成可执行文件
ninfod:
	@set -e; \
		if [ ! -f ninfod/Makefile ]; then \
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#检查内核
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules

# -------------------------------------
man:
       #生成man的帮助文档
	$(MAKE) -C doc man    

html:
	#生成html的帮助文档
	$(MAKE) -C doc html

clean:
	#删除所有的.o文件
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

#清除ninfod目录下所有生成的文件。
distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2

