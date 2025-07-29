# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz65.xdc
    
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/timing/vga_pkg.sv
    ../rtl/timing//vga_timing.sv
    ../rtl/start_screen/draw_start_screen.sv
    ../rtl/start_screen/start_screen_rom.sv
    ../rtl/game_screen/draw_game_screen.sv
    ../rtl/game_screen/game_screen_rom.sv
    ../rtl/game_controller.sv
    ../rtl/vga_if.sv
    ../rtl/top_vga.sv
    ../rtl/font_rom.sv
    ../rtl/blocks/block_generator.sv
    ../rtl/blocks/block_randomizer.sv
    ../rtl/blocks/block_draw.sv
    ../rtl/blocks/board_renderer.sv
    ../rtl/game_logic.sv
    ../rtl/top_uart.sv 
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
 set verilog_files {
     rtl/clk_wiz65_clk_wiz.v
     rtl/clk_wiz65.v
     ../rtl/uart/fifo.v 
     ../rtl/uart/mod_m_counter.v 
     ../rtl/uart/uart_rx.v 
     ../rtl/uart/uart_tx.v 
     ../rtl/uart/uart.v 
     
 }

# Specify VHDL design files location            -- EDIT
 set vhdl_files {
    rtl/Keyboard/debounce.vhd
    rtl/Keyboard/ps2_keyboard.vhd
 }

# Specify files for a memory initialization     -- EDIT
 set mem_files {
    ../rtl/start_screen/start_screen.dat
    ../rtl/game_screen/game_screen.dat
 }
