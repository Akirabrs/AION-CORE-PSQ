`timescale 1ns / 1ps

module tb_reflex_core;

    // Inputs
    reg clk;
    reg rst_n;
    reg signed [15:0] z_pos;
    reg signed [15:0] z_vel;
    reg signed [15:0] kp_gain;
    reg signed [15:0] kd_gain;
    reg signed [15:0] vel_threshold;

    // Outputs
    wire signed [15:0] u_out;
    wire guardian_active;

    // Instantiate the Unit Under Test (UUT)
    reflex_core uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .z_pos(z_pos), 
        .z_vel(z_vel), 
        .kp_gain(kp_gain), 
        .kd_gain(kd_gain), 
        .vel_threshold(vel_threshold), 
        .u_out(u_out), 
        .guardian_active(guardian_active)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        z_pos = 0;
        z_vel = 0;
        kp_gain = 10;      // Gain Kp
        kd_gain = 5;       // Gain Kd
        vel_threshold = 50; // Threshold for Guardian Mode

        // Wait 100 ns for global reset to finish
        #100;
        rst_n = 1;
        
        // ------------------------------------------------
        // CASE 1: Normal Operation (Small Drift)
        // ------------------------------------------------
        #20;
        z_pos = 10;   // Small error
        z_vel = 5;    // Small velocity
        // Expected: u = -(10*10 + 5*5) = -125
        
        // ------------------------------------------------
        // CASE 2: GUARDIAN MODE TRIGGER (VDE Simulation)
        // ------------------------------------------------
        #50;
        z_pos = 100;  // Large position error
        z_vel = 200;  // FAST Velocity (> Threshold 50)
        // Expected: Guardian Flag = 1
        // Kd is doubled -> Kd_eff = 10
        // u = -(100*10 + 200*10) = -(1000 + 2000) = -3000
        // Result should saturate at -2000
        
        #100;
        $display("Simulation Finished");
        $finish;
    end
      
endmodule
