module seven_segment_controller(
    input clk,
    input reset,
    input [8-1:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
    output reg [8-1:0] seg_COM,
    output reg [8-1:0] seg_DATA
);

reg [3-1:0] counter = 3'd0;

always @ (posedge clk) begin
    if (reset) begin
        seg_COM <= 8'b0000_0000;
        seg_DATA <= 8'b0000_0000;
        counter <= 3'd0;
    end
    else begin
        if (counter >= 3'd7)
            counter <= 3'd0;
        else
            counter <= counter + 3'd1;

        case (counter)
            3'd0: begin
                seg_COM <= 8'b0111_1111;
                seg_DATA <= seg0;
            end
            3'd1: begin
                seg_COM <= 8'b1011_1111;
                seg_DATA <= seg1;
            end
            3'd2: begin
                seg_COM <= 8'b1101_1111;
                seg_DATA <= seg2;
            end
            3'd3: begin
                seg_COM <= 8'b1110_1111;
                seg_DATA <= seg3;
            end
            3'd4: begin
                seg_COM <= 8'b1111_0111;
                seg_DATA <= seg4;
            end
            3'd5: begin
                seg_COM <= 8'b1111_1011;
                seg_DATA <= seg5;
            end
            3'd6: begin
                seg_COM <= 8'b1111_1101;
                seg_DATA <= seg6;
            end
            3'd7: begin
                seg_COM <= 8'b1111_1110;
                seg_DATA <= seg7;
            end
            default: begin
                seg_COM <= 8'b1111_1111;
                seg_DATA <= seg7;
            end
        endcase
    end
end

endmodule