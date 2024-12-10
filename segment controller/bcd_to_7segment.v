module bcd_to_7segment(
    input [3:0] bcd,
    output reg [7:0] segment
);

always @(bcd)
begin
    case(bcd)
        4'b0000: segment = 8'b11111100; // 0
        4'b0001: segment = 8'b01100000; // 1
        4'b0010: segment = 8'b11011010; // 2
        4'b0011: segment = 8'b11110010; // 3
        4'b0100: segment = 8'b01100110; // 4
        4'b0101: segment = 8'b10110110; // 5
        4'b0110: segment = 8'b10111110; // 6
        4'b0111: segment = 8'b11100000; // 7
        4'b1000: segment = 8'b11111110; // 8
        4'b1001: segment = 8'b11110110; // 9
        default: segment = 8'b00000000; // All segments off
    endcase
end
endmodule