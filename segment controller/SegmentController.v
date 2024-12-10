module SegmentController(
    input clk,
    input reset,
    input [8:0] binary,
    output [7:0] seg_COM,
    output [7:0] seg_DATA
);

wire [11:0] bcd;
wire [7:0] segment_data_array [7:0];

// Binary to BCD conversion
binary_to_bcd binary_to_bcd_inst (
    .binary(binary),
    .bcd(bcd)
);

// BCD to 7-segment conversion for ones digit
bcd_to_7segment bcd_to_7segment_ones (
    .bcd(bcd[3:0]),
    .segment(segment_data_array[7])
);

// BCD to 7-segment conversion for tens digit
bcd_to_7segment bcd_to_7segment_tens (
    .bcd(bcd[7:4]),
    .segment(segment_data_array[6])
);

// BCD to 7-segment conversion for hundreds digit
bcd_to_7segment bcd_to_7segment_hundreds (
    .bcd(bcd[11:8]),
    .segment(segment_data_array[5])  // 백의 자리용 디스플레이 추가
);

// Assign unused segments to off state
genvar i;
generate
    for (i = 0; i < 5; i = i + 1) begin : unused_segments
        assign segment_data_array[i] = 8'b00000000;
    end
endgenerate

// 7-segment display controller
seven_segment_controller seven_segment_ctrl (
    .clk(clk),
    .reset(reset),
    .seg0(segment_data_array[0]),
    .seg1(segment_data_array[1]),
    .seg2(segment_data_array[2]),
    .seg3(segment_data_array[3]),
    .seg4(segment_data_array[4]),
    .seg5(segment_data_array[5]),
    .seg6(segment_data_array[6]),
    .seg7(segment_data_array[7]),
    .seg_COM(seg_COM),
    .seg_DATA(seg_DATA)
);

endmodule