// ALU 모듈 정의
module ALU(
    input [7:0] operand1,
    input [7:0] operand2,
    input [2:0] operation, // 000: +, 001: -, 010: *, 011: /, 100: %
    output reg [7:0] result
);
    always @(*) begin
        case(operation)
            3'b000: result = operand1 + operand2;
            3'b001: result = operand1 - operand2;
            3'b010: result = operand1 * operand2;
            3'b011: result = (operand2 == 0) ? 8'h0 : operand1 / operand2;
            3'b100: result = (operand2 == 0) ? 8'h0 : operand1 % operand2;
            default: result = 8'h0;
        endcase
    end
endmodule