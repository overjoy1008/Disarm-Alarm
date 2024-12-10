module binary_to_bcd(
    input [8:0] binary,  // 9비트로 변경 (0-511 표현 가능)
    output reg [11:0] bcd // 3자리 BCD (12비트)
);

integer i;
always @(*) begin
    bcd = 12'b0000_0000_0000;
    
    for (i = 8; i >= 0; i = i - 1) begin
        // 각 자릿수가 5 이상이면 3을 더함
        if (bcd[3:0] >= 5) 
            bcd[3:0] = bcd[3:0] + 3;
        if (bcd[7:4] >= 5) 
            bcd[7:4] = bcd[7:4] + 3;
        if (bcd[11:8] >= 5) 
            bcd[11:8] = bcd[11:8] + 3;
            
        // 왼쪽으로 시프트
        bcd = {bcd[10:0], binary[i]};
    end
end
endmodule