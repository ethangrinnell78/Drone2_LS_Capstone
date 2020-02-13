/**
 * ECE 412-413 Capstone Winter/Spring 2018
 * Team 32 Drone2 SOC
 * Ethan Grinnell, Brett Creeley, Daniel Christiansen, Kirk Hooper, Zachary Clark-Williams
 */

`timescale 1ps / 1ps
`default_nettype none
`include "common_defines.v"

module test_z_linear_velocity_comp;

    reg  signed [`RATE_BIT_WIDTH-1:0] VL53L1X_range_mm = 0;
    wire signed [`RATE_BIT_WIDTH-1:0] z_linear_velocity;

    reg  resetn;
    wire sys_clk;
    reg  start_signal;


    defparam OSCH_inst.NOM_FREQ = "38.00";
    OSCH OSCH_inst (.STDBY(1'b0),
                    .OSC(sys_clk),
                    .SEDSTDBY()
    );

    // line up the parameters here to the ones internal to the receiver module
    z_linear_velocity_comp DUT (
        .z_linear_velocity(z_linear_velocity),
        .z_altitude_mm(VL53L1X_range_mm),
        .resetn(resetn),
        .start_signal(start_signal),
        .us_clk(sys_clk)
    );
        
        
    always@(z_linear_velocity)
        $strobe("z_linear_velocity=%d", z_linear_velocity);


    initial begin
        //$display("%t: %m Reset throttle rate limiter", $time);
        resetn = 1;
        #10 resetn = 0;
        VL53L1X_range_mm = 0;
        start_signal = 1'b1;
        #10 resetn = 1;
        
        $display("%t: %m Start tests", $time);
        @(posedge sys_clk) VL53L1X_range_mm = 16'sd 1000;
        repeat (100) @(posedge sys_clk); VL53L1X_range_mm = 16'sd 1000;
        repeat (100) @(posedge sys_clk); VL53L1X_range_mm = 16'sd 500;
        repeat (100) @(posedge sys_clk); VL53L1X_range_mm = 16'sd 0;
        repeat (100) @(posedge sys_clk); VL53L1X_range_mm = 16'sd 0;

        $display("%t: %m Test complete", $time);
        $stop;
    end

endmodule

