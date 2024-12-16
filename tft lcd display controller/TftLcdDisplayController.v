module TftLcdDisplayController(
    input wire clk,
    input wire rst,
    output reg [7:0] R, G, B,
    output wire den,
    output wire hsync,
    output wire vsync,
    output wire dclk,
    output wire disp_en
);
    wire [10:0] counter_h;
    wire [9:0] counter_v;
    
    // Instantiate the TFT LCD controller
    TFT_LCD_controller ctl(
        .clk(clk),
        .rst(rst),
        .counter_h(counter_h),
        .counter_v(counter_v),
        .disp_den(den),
        .disp_hsync(hsync),
        .disp_vsync(vsync),
        .disp_clk(dclk),
        .disp_enb(disp_en)
    );

    // Define the display area boundaries
    parameter DISPLAY_START_H = 'd210;
    parameter DISPLAY_END_H = 'd1010;
    parameter DISPLAY_START_V = 'd22;
    parameter DISPLAY_END_V = 'd480;
    
    // Define the border thickness
    parameter BORDER_THICKNESS = 'd3;
    
    // Define the trident dimensions
    parameter TRIDENT_CENTER_H = (DISPLAY_END_H + DISPLAY_START_H) / 2;
    parameter TRIDENT_CENTER_V = (DISPLAY_END_V + DISPLAY_START_V) / 2;
    
    // RGB color control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= 8'd0;
            G <= 8'd0;
            B <= 8'd0;
        end
        else begin
            if (den) begin
                if (counter_v >= DISPLAY_START_V && counter_v < DISPLAY_END_V &&
                    counter_h >= DISPLAY_START_H && counter_h < DISPLAY_END_H) begin
                    
                    // Border logic
                    if (counter_h < DISPLAY_START_H + BORDER_THICKNESS ||       // Left border
                        counter_h >= DISPLAY_END_H - BORDER_THICKNESS ||        // Right border
                        counter_v < DISPLAY_START_V + BORDER_THICKNESS ||       // Top border
                        counter_v >= DISPLAY_END_V - BORDER_THICKNESS) begin    // Bottom border
                        // Black border
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                    // Edge lines logic
                    else if (
                        // Top edge line
                        (counter_v >= DISPLAY_START_V + 100 && 
                         counter_v < DISPLAY_START_V + 100 + BORDER_THICKNESS) ||
                        // Bottom edge line
                        (counter_v >= DISPLAY_END_V - 100 - BORDER_THICKNESS &&
                         counter_v < DISPLAY_END_V - 100) ||
                        // Left edge line
                        (counter_h >= DISPLAY_START_H + 100 &&
                         counter_h < DISPLAY_START_H + 100 + BORDER_THICKNESS) ||
                        // Right edge line
                        (counter_h >= DISPLAY_END_H - 100 - BORDER_THICKNESS &&
                         counter_h < DISPLAY_END_H - 100)
                    ) begin
                        // Black edge lines
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                    // Center pattern logic
                    else if (
                        // Vertical line
                        (counter_h >= TRIDENT_CENTER_H - BORDER_THICKNESS && 
                         counter_h < TRIDENT_CENTER_H + BORDER_THICKNESS &&
                         counter_v >= TRIDENT_CENTER_V - 80 &&
                         counter_v < TRIDENT_CENTER_V + 50) ||
                        // Left line
                        (counter_h >= TRIDENT_CENTER_H - 30 - BORDER_THICKNESS &&
                         counter_h < TRIDENT_CENTER_H - 30 + BORDER_THICKNESS &&
                         counter_v >= TRIDENT_CENTER_V - 50 &&
                         counter_v < TRIDENT_CENTER_V) ||
                        // Right line
                        (counter_h >= TRIDENT_CENTER_H + 30 - BORDER_THICKNESS &&
                         counter_h < TRIDENT_CENTER_H + 30 + BORDER_THICKNESS &&
                         counter_v >= TRIDENT_CENTER_V - 50 &&
                         counter_v < TRIDENT_CENTER_V)
                    ) begin
                        // Black center pattern
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                    else begin
                        // Red background
                        R <= 8'd255;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                end
                else begin
                    // Black outside display area
                    R <= 8'd0;
                    G <= 8'd0;
                    B <= 8'd0;
                end
            end
            else begin
                // Black when display is not enabled
                R <= 8'd0;
                G <= 8'd0;
                B <= 8'd0;
            end
        end
    end
endmodule