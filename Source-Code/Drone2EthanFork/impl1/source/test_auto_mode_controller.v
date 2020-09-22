/**
 * ECE 412-413 Capstone Winter/Spring 2018
 * Team 32 Drone2 SOC
 * Ethan Grinnell,
 * Brett Creeley,
 * Daniel Christiansen,
 * Kirk Hooper,
 * Zachary Clark-Williams
 */

/**

 */
`timescale 1ns / 1ns
`default_nettype none
`include "common_defines.v"

module test_auto_mode_controller;

    reg  resetn;
    wire sys_clk;
    wire us_clk;
    wire amc_complete_signal;
    wire amc_active_signal;
    reg  start_signal;
    wire [15:0] amc_debug;
    wire [7:0] amc_throttle_val;
    reg  [15:0] z_linear_velocity;
    reg  imu_good;
    reg  imu_data_valid;
    reg  [7:0] throttle_val;
    reg  [2:0] switch_a;
    reg  [1:0] switch_b;

    defparam OSCH_inst.NOM_FREQ = "38.00";
    OSCH OSCH_inst (.STDBY(1'b0),
                    .OSC(sys_clk),
                    .SEDSTDBY());

    us_clk us_clk_divider (
        .us_clk(us_clk),
        .sys_clk(sys_clk),
        .resetn(resetn));

    auto_mode_controller AMC (
        .debug(amc_debug),
        .throttle_pwm_val_out(amc_throttle_val),
        .active_signal(amc_active_signal),
        .complete_signal(amc_complete_signal),
        .z_linear_velocity(z_linear_velocity),
        .imu_good(imu_good),
        .throttle_pwm_val_in(throttle_val),
        .switch_a(switch_a),
        .switch_b(switch_b),
        .start_signal(imu_data_valid),
        .resetn(resetn),
        .us_clk(us_clk)
    );

    initial begin
        resetn            = 1;
        start_signal      = 0;
        z_linear_velocity = 0;
        imu_good          = 1;
        imu_data_valid    = 1;
        throttle_val      = 0;
        switch_a          = `SWITCH_A_AUTO;
        switch_b          = `SWITCH_B_UP;
        
        #10 resetn        = 0;
        #10 resetn        = 1;
        $display("%t: %m Test complete", $time);
        $stop;
    end


endmodule