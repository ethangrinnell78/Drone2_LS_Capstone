`timescale 1ns / 1ns
`default_nettype none

/**
 * ECE 412-413 Capstone Winter/Spring 2018
 * Team 32 Drone2 SOC
 * Ethan Grinnell, Brett Creeley, Daniel Christiansen, Kirk Hooper, Zachary Clark-Williams
 */

/**
 * module pid - sub-module implementing a pid controller for  rotation rate
 * around a single axis.
 *
 * Outputs:
 *
 */
 module pid #(parameter signed RATE_MIN = 16'h8000,
			  parameter signed RATE_MAX = 16'h7FFF)
 			 (output reg [`PID_RATE_BIT_WIDTH-1:0] rate_out,
 			  output reg pid_complete,
			  output reg pid_active,
			  output wire [15:0] DEBUG_WIRE, /*DEBUG LEDs*/
			  input wire signed [`RATE_BIT_WIDTH-1:0] target_rotation,
 			  input wire signed [`IMU_VAL_BIT_WIDTH-1:0] actual_rotation,
			  input wire signed [`RATE_BIT_WIDTH-1:0] angle_error,
			  input wire start_flag,
			  input wire wait_flag,
			  input wire resetn,
			  input wire us_clk);

	// working registers
	reg signed [`RATE_BIT_WIDTH-1:0]
		scaled_rotation, rotation_error, prev_rotation_error,
		rotation_proportional, rotation_integral, rotation_derivative,
		error_change, rotation_total;

	reg signed [`RATE_BIT_WIDTH-1:0]
		latched_target_rotation, latched_actual_rotation, latched_angle_error;

	// proportionality constants
	localparam signed
		K_p = 16'h0001,
		K_i = 16'h0001,
		K_d = 16'h0001;

	// state names
	localparam
		STATE_WAIT     = 6'b000001,
		STATE_CALC1    = 6'b000010,
		STATE_CALC2    = 6'b000100,
		STATE_CALC3    = 6'b001000,
		STATE_CALC4    = 6'b010000,
		STATE_COMPLETE = 6'b100000;

	// state variables
	reg [5:0] state, next_state;

	//Debug wire assign to monitor values on 16 led daughter board
	assign DEBUG_WIRE = rotation_total;

	// update state
	always @(posedge us_clk or negedge resetn) begin
		if(!resetn) begin
			state <= STATE_WAIT;
      latched_target_rotation <= 16'h0000;
      latched_actual_rotation <= 16'h0000;
      latched_angle_error     <= 16'h0000;
    end
    else begin
			state <= next_state;
      latched_target_rotation <= target_rotation;
      latched_actual_rotation <= actual_rotation;
      latched_angle_error     <= angle_error;
    end
  end

  // calculation / output logic
	always @(posedge us_clk or negedge resetn) begin
		if(!resetn) begin
			pid_active <= 1'b0;
			pid_complete <= 1'b0;
			rate_out <= 16'h0000;
		end
		else begin
			case(state)
				STATE_WAIT: begin
					pid_active <= 1'b0;
					pid_complete <= 1'b1;
				end
				STATE_CALC1: begin
					pid_active <= 1'b1;
					pid_complete <= 1'b0;
					prev_rotation_error <= rotation_error;
					rotation_error <= ($signed(target_rotation) - $signed(actual_rotation));
					rotation_integral <= ($signed(K_i) * $signed(angle_error));
				end
				STATE_CALC2: begin
					pid_active <= 1'b1;
					pid_complete <= 1'b0;
					rotation_proportional <= ($signed(K_p) * $signed(rotation_error));
					error_change <= ($signed(prev_rotation_error) - $signed(rotation_error));
				end
				STATE_CALC3: begin
					pid_active <= 1'b1;
					pid_complete <= 1'b0;
					rotation_derivative <= ($signed(K_d) * $signed(error_change));
				end
				STATE_CALC4: begin
					pid_active <= 1'b1;
					pid_complete <= 1'b0;
					rotation_total <= ($signed(rotation_proportional) + $signed(rotation_integral) + $signed(rotation_derivative));
				end
				STATE_COMPLETE: begin
					pid_active <= 1'b1;
					pid_complete <= 1'b1;
					if($signed(rotation_total) < $signed(RATE_MIN))
						rate_out <= RATE_MIN;
					else if($signed(rotation_total) > $signed(RATE_MAX))
						rate_out <= RATE_MAX;
					else
						rate_out <= rotation_total;
				end
				default: begin
					pid_active <= 1'b0;
					pid_complete <= 1'b0;
					rate_out <= 16'h0000;
				end
			endcase
		end
	end

	// next state logic
	always @(*) begin
		if(!resetn) begin
		  next_state = STATE_WAIT;
		end
		else begin
			case(state)
				STATE_WAIT: begin
					if(start_flag)
						next_state = STATE_CALC1;
					else
						next_state = STATE_WAIT;
				end
				STATE_CALC1: begin
				   next_state = STATE_CALC2;
				end
				STATE_CALC2: begin
					next_state = STATE_CALC3;
				end
				STATE_CALC3: begin
						next_state = STATE_CALC4;
				end
				STATE_CALC4: begin
					next_state = STATE_COMPLETE;
				end
				STATE_COMPLETE: begin
					if(wait_flag)
						next_state = STATE_WAIT;
					else
						next_state = STATE_COMPLETE;
				end
			default: begin
			  next_state = STATE_WAIT;
			end
			endcase
		end
	end

endmodule
