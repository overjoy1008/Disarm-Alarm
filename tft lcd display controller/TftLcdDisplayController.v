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

    // RGB color control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= 8'd0;
            G <= 8'd0;
            B <= 8'd0;
        end
        else begin
            if (den) begin
                if (counter_v >= 'd22 && counter_v < 'd240) begin
                    if (counter_h >= 'd210 && counter_h < 'd310) begin
                        // Black
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                    else if (counter_h >= 'd310 && counter_h < 'd410) begin
                        // Blue
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd255;
                    end
                    else if (counter_h >= 'd410 && counter_h < 'd510) begin
                        // Green
                        R <= 8'd0;
                        G <= 8'd255;
                        B <= 8'd0;
                    end
                    else if (counter_h >= 'd510 && counter_h < 'd610) begin
                        // Sky Blue (Light Blue)
                        R <= 8'd0;
                        G <= 8'd238;
                        B <= 8'd255;
                    end
                    else if (counter_h >= 'd610 && counter_h < 'd710) begin
                        // Red
                        R <= 8'd255;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                    else if (counter_h >= 'd710 && counter_h < 'd810) begin
                        // Purple
                        R <= 8'd138;
                        G <= 8'd69;
                        B <= 8'd238;
                    end
                    else if (counter_h >= 'd810 && counter_h < 'd910) begin
                        // Yellow
                        R <= 8'd255;
                        G <= 8'd212;
                        B <= 8'd0;
                    end
                    else if (counter_h >= 'd910 && counter_h < 'd1010) begin
                        // White
                        R <= 8'd255;
                        G <= 8'd255;
                        B <= 8'd255;
                    end
                    else begin
                        // Black for other regions
                        R <= 8'd0;
                        G <= 8'd0;
                        B <= 8'd0;
                    end
                end
                else if (counter_v >= 'd240 && counter_v < 'd480) begin
                    // Your code for the next vertical section will go here
                    // Default to black for now
                    R <= 8'd0;
                    G <= 8'd0;
                    B <= 8'd0;
                end
                else begin
                    // Black outside vertical range
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