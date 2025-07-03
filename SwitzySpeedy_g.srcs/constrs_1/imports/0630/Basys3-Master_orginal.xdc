## SwitzySpeedy 게임을 위한 Basys3 rev B 보드용 XDC 파일
## Verilog 최상위 모듈의 포트 이름과 아래 get_ports의 이름을 일치시켜야 합니다.

# =============================================================
# ## 시스템 클럭 및 리셋
# =============================================================
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# CPU_RESET 버튼을 메인 리셋으로 사용합니다.
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports reset]


# =============================================================
# ## 스위치 (SW0 ~ SW15)
# =============================================================
# 라운드 1, 2에서 모두 사용
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN V16  IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN W16  IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN W17  IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN W15  IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN V15  IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN W14  IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN W13  IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
set_property -dict { PACKAGE_PIN V2   IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]
set_property -dict { PACKAGE_PIN T3   IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]
set_property -dict { PACKAGE_PIN T2   IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
set_property -dict { PACKAGE_PIN R3   IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
set_property -dict { PACKAGE_PIN W2   IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
set_property -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
set_property -dict { PACKAGE_PIN T1   IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
# 라운드 1, 2의 정답 제출(확정) 신호로 사용
set_property -dict { PACKAGE_PIN R2   IOSTANDARD LVCMOS33 } [get_ports {sw[15]}]


# =============================================================
# ## LED (LED0 ~ LED15)
# =============================================================
set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN E19  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN V19  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN W18  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN V13  IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN V3   IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN W3   IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN U3   IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN P3   IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN N3   IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN P1   IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN L1   IOSTANDARD LVCMOS33 } [get_ports {led[15]}]


# =============================================================
# ## 7세그먼트 디스플레이 (FND)
# =============================================================
# Cathode (세그먼트 a~g)
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[0]}] ;# a
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[1]}] ;# b
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[2]}] ;# c
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[3]}] ;# d
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[4]}] ;# e
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[5]}] ;# f
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {fnd_seg[6]}] ;# g
# set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {seg[7]}] ;# dp (소수점, 사용 안함)

# Anode (자리 선택)
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {fnd_an[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {fnd_an[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {fnd_an[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {fnd_an[3]}]


# =============================================================
# ## 버튼 (Buttons)
# =============================================================
# 게임 시작 버튼 (U18, BTNC)
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports btn_start]

# 라운드 3: 왼쪽 (W19, BTNL)
set_property -dict { PACKAGE_PIN W19  IOSTANDARD LVCMOS33 } [get_ports btn_left]

# 라운드 3: 오른쪽 (T17, BTNR)
set_property -dict { PACKAGE_PIN T17  IOSTANDARD LVCMOS33 } [get_ports btn_right]

# 라운드 3: 같음 (U17, BTND)
set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVCMOS33 } [get_ports btn_equal]


# =============================================================
# ## 기타 설정
# =============================================================
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]