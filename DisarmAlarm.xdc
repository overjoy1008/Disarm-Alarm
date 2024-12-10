## Clock signal
set_property PACKAGE_PIN B6 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Button signals
set_property PACKAGE_PIN Y6 [get_ports button_A]
set_property PACKAGE_PIN V7 [get_ports button_B]
set_property IOSTANDARD LVCMOS33 [get_ports button_A]
set_property IOSTANDARD LVCMOS33 [get_ports button_B]

## DIP Switch signals
set_property PACKAGE_PIN AB3 [get_ports {dip_switch[7]}]
set_property PACKAGE_PIN AB4 [get_ports {dip_switch[6]}]
set_property PACKAGE_PIN Y4 [get_ports {dip_switch[5]}]
set_property PACKAGE_PIN Y5 [get_ports {dip_switch[4]}]
set_property PACKAGE_PIN W5 [get_ports {dip_switch[3]}]
set_property PACKAGE_PIN V6 [get_ports {dip_switch[2]}]
set_property PACKAGE_PIN AB5 [get_ports {dip_switch[1]}]
set_property PACKAGE_PIN AA6 [get_ports {dip_switch[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip_switch[*]}]

## Piezo Output
set_property PACKAGE_PIN W4 [get_ports piezo_out]
set_property IOSTANDARD LVCMOS33 [get_ports piezo_out]

## Full Color LED signals
# Red LEDs
set_property PACKAGE_PIN D1 [get_ports CLED_R1]
set_property PACKAGE_PIN A3 [get_ports CLED_R2]
set_property PACKAGE_PIN B2 [get_ports CLED_R3]
set_property PACKAGE_PIN A4 [get_ports CLED_R4]

# Green LEDs
set_property PACKAGE_PIN C1 [get_ports CLED_G1]
set_property PACKAGE_PIN C4 [get_ports CLED_G2]
set_property PACKAGE_PIN B3 [get_ports CLED_G3]
set_property PACKAGE_PIN D5 [get_ports CLED_G4]

# Blue LEDs
set_property PACKAGE_PIN C2 [get_ports CLED_B1]
set_property PACKAGE_PIN D4 [get_ports CLED_B2]
set_property PACKAGE_PIN C3 [get_ports CLED_B3]
set_property PACKAGE_PIN E5 [get_ports CLED_B4]

# Set LED I/O standards
set_property IOSTANDARD LVCMOS33 [get_ports CLED_R*]
set_property IOSTANDARD LVCMOS33 [get_ports CLED_G*]
set_property IOSTANDARD LVCMOS33 [get_ports CLED_B*]

## 7-Segment Display signals
# COM outputs
set_property PACKAGE_PIN T2 [get_ports {seg_COM[7]}]
set_property PACKAGE_PIN T1 [get_ports {seg_COM[6]}]
set_property PACKAGE_PIN R5 [get_ports {seg_COM[5]}]
set_property PACKAGE_PIN R4 [get_ports {seg_COM[4]}]
set_property PACKAGE_PIN R3 [get_ports {seg_COM[3]}]
set_property PACKAGE_PIN R2 [get_ports {seg_COM[2]}]
set_property PACKAGE_PIN P3 [get_ports {seg_COM[1]}]
set_property PACKAGE_PIN P2 [get_ports {seg_COM[0]}]

# DATA outputs
set_property PACKAGE_PIN P1 [get_ports {seg_DATA[7]}]
set_property PACKAGE_PIN N5 [get_ports {seg_DATA[6]}]
set_property PACKAGE_PIN N4 [get_ports {seg_DATA[5]}]
set_property PACKAGE_PIN N3 [get_ports {seg_DATA[4]}]
set_property PACKAGE_PIN N1 [get_ports {seg_DATA[3]}]
set_property PACKAGE_PIN M5 [get_ports {seg_DATA[2]}]
set_property PACKAGE_PIN M4 [get_ports {seg_DATA[1]}]
set_property PACKAGE_PIN M3 [get_ports {seg_DATA[0]}]

# Set 7-segment I/O standards
set_property IOSTANDARD LVCMOS33 [get_ports {seg_COM[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_DATA[*]}]

## Text LCD signals
set_property PACKAGE_PIN L5 [get_ports lcd_enb]
set_property PACKAGE_PIN M2 [get_ports lcd_rs]
set_property PACKAGE_PIN M1 [get_ports lcd_rw]

# LCD data signals
set_property PACKAGE_PIN J3 [get_ports {lcd_data[7]}]
set_property PACKAGE_PIN K1 [get_ports {lcd_data[6]}]
set_property PACKAGE_PIN K2 [get_ports {lcd_data[5]}]
set_property PACKAGE_PIN K3 [get_ports {lcd_data[4]}]
set_property PACKAGE_PIN K4 [get_ports {lcd_data[3]}]
set_property PACKAGE_PIN K5 [get_ports {lcd_data[2]}]
set_property PACKAGE_PIN L1 [get_ports {lcd_data[1]}]
set_property PACKAGE_PIN L4 [get_ports {lcd_data[0]}]

# Set LCD I/O standards
set_property IOSTANDARD LVCMOS33 [get_ports lcd_*]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_data[*]}]

## TFT LCD signals
# Display control
set_property PACKAGE_PIN J22 [get_ports dclk]
set_property PACKAGE_PIN L18 [get_ports den]
set_property PACKAGE_PIN K18 [get_ports disp_en]
set_property PACKAGE_PIN K19 [get_ports hsync]
set_property PACKAGE_PIN K22 [get_ports vsync]

# RGB signals
# Red
set_property PACKAGE_PIN D22 [get_ports {R[7]}]
set_property PACKAGE_PIN D21 [get_ports {R[6]}]
set_property PACKAGE_PIN D20 [get_ports {R[5]}]
set_property PACKAGE_PIN C22 [get_ports {R[4]}]
set_property PACKAGE_PIN C20 [get_ports {R[3]}]
set_property PACKAGE_PIN B22 [get_ports {R[2]}]
set_property PACKAGE_PIN B21 [get_ports {R[1]}]
set_property PACKAGE_PIN B20 [get_ports {R[0]}]

# Green
set_property PACKAGE_PIN G21 [get_ports {G[7]}]
set_property PACKAGE_PIN G20 [get_ports {G[6]}]
set_property PACKAGE_PIN F22 [get_ports {G[5]}]
set_property PACKAGE_PIN F21 [get_ports {G[4]}]
set_property PACKAGE_PIN F20 [get_ports {G[3]}]
set_property PACKAGE_PIN F19 [get_ports {G[2]}]
set_property PACKAGE_PIN F18 [get_ports {G[1]}]
set_property PACKAGE_PIN E22 [get_ports {G[0]}]

# Blue
set_property PACKAGE_PIN J21 [get_ports {B[7]}]
set_property PACKAGE_PIN J20 [get_ports {B[6]}]
set_property PACKAGE_PIN J19 [get_ports {B[5]}]
set_property PACKAGE_PIN H21 [get_ports {B[4]}]
set_property PACKAGE_PIN H20 [get_ports {B[3]}]
set_property PACKAGE_PIN H19 [get_ports {B[2]}]
set_property PACKAGE_PIN H18 [get_ports {B[1]}]
set_property PACKAGE_PIN G22 [get_ports {B[0]}]

# Set TFT LCD I/O standards and drive properties
set_property IOSTANDARD LVCMOS33 [get_ports {R[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {G[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports dclk]
set_property IOSTANDARD LVCMOS33 [get_ports den]
set_property IOSTANDARD LVCMOS33 [get_ports disp_en]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

set_property DRIVE 4 [get_ports {R[*]}]
set_property DRIVE 4 [get_ports {G[*]}]
set_property DRIVE 4 [get_ports {B[*]}]
set_property SLEW SLOW [get_ports {R[*]}]
set_property SLEW SLOW [get_ports {G[*]}]
set_property SLEW SLOW [get_ports {B[*]}]

## Clock timing constraints
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]