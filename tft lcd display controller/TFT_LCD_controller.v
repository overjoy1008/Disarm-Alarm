parameter HSIZE = 11;
parameter VSIZE = 10;

module TFT_LCD_controller(
    input clk, rst,
    output reg [HSIZE-1:0] counter_h,
    output reg [VSIZE-1:0] counter_v,
    output reg disp_den, disp_hsync, disp_vsync,
    output disp_clk, disp_enb
);

    reg video_on_h, video_on_v;
    
    assign disp_clk = clk;
    assign disp_enb = 1'b1;
    
    // Horizontal & Vertical Counter
    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            counter_h <= 'd0;
            counter_v <= 'd0;
        end 
        else begin
            if (counter_h >= 'd1055) begin
                counter_h <= 'd0;
                if (counter_v >= 'd524)
                    counter_v <= 'd0;
                else
                    counter_v <= counter_v + 'd1;
            end
            else
                counter_h <= counter_h + 'd1;
        end
    end
    
    // Sync Signal Generation
    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            disp_hsync <= 'd0;
            disp_vsync <= 'd0;
        end
        else begin
            if ( counter_h == 'd1055 )
                disp_hsync <= 'd0;
            else
                disp_hsync <= 'd1;
                
            if ( counter_v == 'd525 )
                disp_vsync <= 'd0;
            else
                disp_vsync <= 'd1;
        end
    end
    
    // Display Enable Signal Generation
    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            video_on_h <= 'd0;
            video_on_v <= 'd0;
            disp_den <= 'd0;
        end
        else begin
            if ((counter_h <= 'd1010) && (counter_h > 'd210))
                video_on_h <= 'd1;
            else
                video_on_h <= 'd0;
                
            if ((counter_v <= 'd502) && (counter_v > 'd22))
                video_on_v <= 'd1;
            else
                video_on_v <= 'd0;
                
            disp_den <= video_on_h & video_on_v;
        end
    end

endmodule