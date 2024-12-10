// LFSR 모듈 정의
module LFSR8(
    input wire clk,
    input wire rst,
    output reg [7:0] value
);
    // 8-bit LFSR with polynomial x^8 + x^6 + x^5 + x^4 + 1
    always @(posedge clk or posedge rst) begin
        if (rst)
            value <= 8'h1; // 초기값을 1로 설정
        else begin
            value <= {value[6:0], value[7] ^ value[5] ^ value[4] ^ value[3]};
        end
    end
endmodule