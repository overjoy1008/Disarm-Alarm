module RgbController(
    input clk,              // 50MHz clock
    input rst,              // Reset signal
    input [2:0] input_color,// 3-bit input control
    output reg CLED_R1,     // Red LED outputs
    output reg CLED_R2,
    output reg CLED_R3,
    output reg CLED_R4,
    output reg CLED_G1,     // Green LED outputs
    output reg CLED_G2,
    output reg CLED_G3,
    output reg CLED_G4,
    output reg CLED_B1,     // Blue LED outputs
    output reg CLED_B2,
    output reg CLED_B3,
    output reg CLED_B4
);

// Counter for blinking effect (24-bit for visible blinking)
reg [23:0] blink_counter;
wire blink_state;

// Generate blinking state (approximately 3Hz at 50MHz clock)
always @(posedge clk or posedge rst) begin
    if (rst)
        blink_counter <= 24'd0;
    else
        blink_counter <= blink_counter + 1;
end

// Use MSB of counter for blinking (roughly 3Hz)
assign blink_state = blink_counter[23];

// Control LED states
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Turn off all LEDs on reset
        CLED_R1 <= 1'b0;
        CLED_R2 <= 1'b0;
        CLED_R3 <= 1'b0;
        CLED_R4 <= 1'b0;
        CLED_G1 <= 1'b0;
        CLED_G2 <= 1'b0;
        CLED_G3 <= 1'b0;
        CLED_G4 <= 1'b0;
        CLED_B1 <= 1'b0;
        CLED_B2 <= 1'b0;
        CLED_B3 <= 1'b0;
        CLED_B4 <= 1'b0;
    end
    else begin
        // First, turn off all LEDs
        CLED_R1 <= 1'b0;
        CLED_R2 <= 1'b0;
        CLED_R3 <= 1'b0;
        CLED_R4 <= 1'b0;
        CLED_G1 <= 1'b0;
        CLED_G2 <= 1'b0;
        CLED_G3 <= 1'b0;
        CLED_G4 <= 1'b0;
        CLED_B1 <= 1'b0;
        CLED_B2 <= 1'b0;
        CLED_B3 <= 1'b0;
        CLED_B4 <= 1'b0;

        // Then set appropriate LEDs based on input
        case (input_color)
            3'b000: begin  // All LEDs off
                // Do nothing as all LEDs are already off
            end
            
            3'b001: begin  // White LEDs constantly on
                CLED_R1 <= 1'b1;
                CLED_R2 <= 1'b1;
                CLED_R3 <= 1'b1;
                CLED_R4 <= 1'b1;
                CLED_G1 <= 1'b1;
                CLED_G2 <= 1'b1;
                CLED_G3 <= 1'b1;
                CLED_G4 <= 1'b1;
                CLED_B1 <= 1'b1;
                CLED_B2 <= 1'b1;
                CLED_B3 <= 1'b1;
                CLED_B4 <= 1'b1;
            end

            3'b010: begin  // Yellow LEDs constantly on
                CLED_R1 <= 1'b1;
                CLED_R2 <= 1'b1;
                CLED_R3 <= 1'b1;
                CLED_R4 <= 1'b1;
                CLED_G1 <= 1'b1;
                CLED_G2 <= 1'b1;
                CLED_G3 <= 1'b1;
                CLED_G4 <= 1'b1;
            end

            3'b011: begin  // Cyan LEDs constantly on
                CLED_G1 <= 1'b1;
                CLED_G2 <= 1'b1;
                CLED_G3 <= 1'b1;
                CLED_G4 <= 1'b1;
                CLED_B1 <= 1'b1;
                CLED_B2 <= 1'b1;
                CLED_B3 <= 1'b1;
                CLED_B4 <= 1'b1;
            end
            
            3'b100: begin  // Red LEDs blinking
                CLED_R1 <= blink_state;
                CLED_R2 <= blink_state;
                CLED_R3 <= blink_state;
                CLED_R4 <= blink_state;
            end

            3'b101: begin  // Yellow LEDs on
                CLED_R1 <= 1'b1;
                CLED_R2 <= 1'b1;
                CLED_R3 <= 1'b1;
                CLED_R4 <= 1'b1;
                CLED_G1 <= 1'b1;
                CLED_G2 <= 1'b1;
                CLED_G3 <= 1'b1;
                CLED_G4 <= 1'b1;
            end
            
            3'b110: begin  // Green LEDs on
                CLED_G1 <= 1'b1;
                CLED_G2 <= 1'b1;
                CLED_G3 <= 1'b1;
                CLED_G4 <= 1'b1;
            end
        endcase
    end
end

endmodule