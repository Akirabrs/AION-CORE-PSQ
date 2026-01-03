/*
 * MODULE: AION-CORE REFLEX LAYER (Layer 1)
 * PLATFORM: FPGA (Zynq-7000 / Artix-7)
 * ARCHITECT: Guilherme Brasil de Souza
 * DESCRIPTION:
 * Deterministic PD controller with Guardian Mode interlock.
 * Operates in fixed-point arithmetic for sub-microsecond latency.
 * * Inputs: 16-bit signed integers (Sensors)
 * Output: 16-bit signed integer (DAC Voltage Demand)
 */

module reflex_core (
    input wire clk,                  // System Clock (e.g., 100 MHz)
    input wire rst_n,                // Active Low Reset
    
    // Fast Sensor Inputs (Mapped: 1 unit = 10 um)
    input wire signed [15:0] z_pos,  // Vertical Position
    input wire signed [15:0] z_vel,  // Vertical Velocity (dZ/dt)
    
    // Control Parameters (Writable from Layer 2 - AXI Lite in future)
    input wire signed [15:0] kp_gain,
    input wire signed [15:0] kd_gain,
    input wire signed [15:0] vel_threshold, // Guardian Trigger Level
    
    // Outputs
    output reg signed [15:0] u_out,  // Control Action
    output reg guardian_active       // Flag: High if safety mode triggered
);

    // Internal Signals (Expanded width for multiplication to avoid overflow)
    reg signed [31:0] p_term;
    reg signed [31:0] d_term;
    reg signed [31:0] raw_sum;
    
    // Parameters for Saturation (Hardcoded Limits)
    localparam signed [15:0] MAX_OUT = 16'd2000;  // +2000 units (e.g., 2000V)
    localparam signed [15:0] MIN_OUT = -16'd2000; // -2000 units

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            u_out <= 16'd0;
            guardian_active <= 1'b0;
            p_term <= 32'd0;
            d_term <= 32'd0;
        end else begin
            // ---------------------------------------------------------
            // STAGE 1: GUARDIAN CHECK & GAIN SCHEDULING
            // Latency: 1 Clock Cycle
            // ---------------------------------------------------------
            if (($signed(z_vel) > $signed(vel_threshold)) || 
                ($signed(z_vel) < -$signed(vel_threshold))) begin
                
                guardian_active <= 1'b1;
                // Boost D-Gain by 2x (Shift Left 1) in emergency
                d_term <= z_vel * (kd_gain <<< 1); 
            end else begin
                guardian_active <= 1'b0;
                d_term <= z_vel * kd_gain;
            end

            // P-Term is linear
            p_term <= z_pos * kp_gain; // Target is 0, so error = 0 - z_pos => -z_pos * Kp

            // ---------------------------------------------------------
            // STAGE 2: SUMMATION & CLAMPING
            // Latency: Included in pipeline
            // ---------------------------------------------------------
            // Control Law: u = - (Kp*z + Kd*v)
            raw_sum = -(p_term + d_term); 
            
            // Saturation Logic (Clamp)
            if (raw_sum > MAX_OUT) 
                u_out <= MAX_OUT;
            else if (raw_sum < MIN_OUT) 
                u_out <= MIN_OUT;
            else
                u_out <= raw_sum[15:0]; // Truncate back to 16-bit
        end
    end

endmodule
