/**
 * ECE 412-413 Capstone Winter/Spring 2018
 * Team 32 Drone2 SOC
 * Ethan Grinnell, Brett Creeley, Daniel Christiansen, Kirk Hooper, Zachary Clark-Williams
 */

module test_drone2;

	// Outputs to the motors and their corresponding ESCs
	wire motor_1_pwm;
	wire motor_2_pwm;
	wire motor_3_pwm;
	wire motor_4_pwm;

	// Inputs from the rc/receiver
	wire throttle_pwm;
	wire yaw_pwm;
	wire roll_pwm;
	wire pitch_pwm;

	// I2C lines for IMU communication
	wire sda;
	wire scl;

	drone2 DUT(.motor_1_pwm(motor_1_pwm),
			   .motor_2_pwm(motor_2_pwm),
			   .motor_3_pwm(motor_3_pwm),
			   .motor_4_pwm(motor_4_pwm),
			   .throttle_pwm(throttle_pwm),
			   .yaw_pwm(yaw_pwm),
			   .roll_pwm(roll_pwm),
			   .pitch_pwm(pitch_pwm),
			   .sda(sda),
			   .scl(scl));

	initial begin
		$display("%m successful");
	end

endmodule

