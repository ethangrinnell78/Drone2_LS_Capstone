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

`include "common_defines.v"

module z_linear_velocity_comp (
    output wire signed [`RATE_BIT_WIDTH-1:0] z_linear_velocity,
    input  wire signed [`RATE_BIT_WIDTH-1:0] z_altitude_mm,
    input  wire start_signal,
    input  wire resetn,
    input  wire us_clk
);

    // number of total FSM states, determines the number of required bits for states
    `define ZLV_NUM_STATES 5
    // state names
    localparam
        STATE_INIT  = `ZLV_NUM_STATES'b1<<0,
        STATE_WAIT  = `ZLV_NUM_STATES'b1<<1,
        STATE_LATCH = `ZLV_NUM_STATES'b1<<2,
        STATE_CALC  = `ZLV_NUM_STATES'b1<<3,
        STATE_PREV  = `ZLV_NUM_STATES'b1<<4;




    reg signed[`RATE_BIT_WIDTH-1:0] z_linear_velocity_calc;
    reg signed[`RATE_BIT_WIDTH-1:0] next_z_linear_velocity_calc;
    reg signed[`RATE_BIT_WIDTH-1:0] z_altitude_mm_latched;
    reg signed[`RATE_BIT_WIDTH-1:0] next_z_altitude_mm_latched;
    reg signed[`RATE_BIT_WIDTH-1:0] z_altitude_mm_previous;
    reg signed[`RATE_BIT_WIDTH-1:0] next_z_altitude_mm_previous;


    // state variables
    reg [`ZLV_NUM_STATES-1:0] state, next_state;
    
    // update state
    always @(posedge us_clk or negedge resetn) begin
        if(!resetn) begin
            state                  <= STATE_INIT;
            z_linear_velocity_calc <= 16'd0;
            z_altitude_mm_latched  <= 16'd0;
            z_altitude_mm_previous <= 16'd0;
        end
        else begin
            state                  <= next_state;
            z_linear_velocity_calc <= next_z_linear_velocity_calc;
            z_altitude_mm_latched  <= next_z_altitude_mm_latched;
            z_altitude_mm_previous <= next_z_altitude_mm_previous;
        end
    end

    // Determine next state
    always@* begin
        if(!resetn) begin
            next_state = STATE_INIT;
        end
        else begin
            // FSM next state
            case(state)
                STATE_INIT  : next_state = STATE_WAIT;
                STATE_WAIT  : next_state = start_signal ? STATE_LATCH : STATE_WAIT;
                STATE_LATCH : next_state = STATE_CALC;
                STATE_CALC  : next_state = STATE_PREV;
                STATE_PREV  : next_state = STATE_WAIT;
            endcase
        end
            
    end


    // FSM values and output
    always@* begin
        if(!resetn) begin
            next_z_linear_velocity_calc = 16'sd0;
            next_z_altitude_mm_latched  = 16'sd0;
            next_z_altitude_mm_previous = 16'sd0;
        end
        else begin
            next_z_linear_velocity_calc = z_linear_velocity_calc;
            next_z_altitude_mm_latched  = z_altitude_mm_latched;
            next_z_altitude_mm_previous = z_altitude_mm_previous;
            case(state)
                STATE_INIT : begin
                    next_z_linear_velocity_calc = 16'sd0;
                    next_z_altitude_mm_latched  = 16'sd0;
                    next_z_altitude_mm_previous = 16'sd0;
                end
                STATE_WAIT  : begin
                end
                STATE_LATCH : begin
                    next_z_altitude_mm_latched  = z_altitude_mm;
                end 
                STATE_CALC  : begin
                    next_z_linear_velocity_calc = (z_altitude_mm_previous - z_altitude_mm_latched)*16'sd50;
                end 
                STATE_PREV  : begin
                    next_z_altitude_mm_previous = z_altitude_mm_latched;
                end                
            endcase
        end
    end
    
    // Drive outputs
    assign z_linear_velocity = z_linear_velocity_calc;

endmodule