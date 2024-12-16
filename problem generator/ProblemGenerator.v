module ProblemGenerator(
    input wire clk,
    input wire rst,
    output reg ready,
    output reg [7:0] answer,
    output reg [7:0] num1,
    output reg [7:0] num2,
    output reg [2:0] op
);
    // 상태 정의
    localparam IDLE = 3'b000;
    localparam GEN_NUMS = 3'b001;
    localparam CALCULATE = 3'b010;
    localparam CHECK = 3'b011;
    localparam DONE = 3'b100;
    
    reg [2:0] state, next_state;
    reg [3:0] retry_count;
    reg [3:0] wait_count;
    wire [7:0] lfsr1_out, lfsr2_out, lfsr3_out;
    wire [7:0] alu_result;
    reg [7:0] processed_num1, processed_num2;
    reg [2:0] processed_op;
    reg [7:0] temp_num2;
    reg is_valid_result;
    
    // LFSR 인스턴스들
    LFSR8 lfsr1(
        .clk(clk),
        .rst(rst),
        .value(lfsr1_out)
    );
    
    LFSR8 lfsr2(
        .clk(clk),
        .rst(rst),
        .value(lfsr2_out)
    );
    
    LFSR8 lfsr3(
        .clk(clk),
        .rst(rst),
        .value(lfsr3_out)
    );
    
    // ALU 인스턴스
    ALU alu(
        .operand1(processed_num1),
        .operand2(processed_num2),
        .operation(processed_op),
        .result(alu_result)
    );
    
    // 숫자 처리 함수들
    function [7:0] process_num1;
        input [7:0] raw;
        input [2:0] current_op;
        begin
            case(current_op)
                3'b010: begin  // 곱셈
                    process_num1 = (raw % 98) + 2;  // 2-99 범위
                end
                default: begin  // 덧셈, 뺄셈, 나눗셈, 나머지
                    if(raw[7])
                        process_num1 = (raw % 101) + 100;  // 100-200 범위
                    else
                        process_num1 = (raw % 98) + 2;  // 2-99 범위
                end
            endcase
        end
    endfunction

    function [7:0] process_num2;
        input [7:0] raw;
        input [2:0] current_op;
        begin
            case(current_op)
                3'b010: begin  // 곱셈
                    process_num2 = (raw % 8) + 2;  // 2-9 범위
                end
                3'b011, 3'b100: begin  // 나눗셈, 나머지
                    process_num2 = (raw % 98) + 2;  // 2-99 범위 (0 방지)
                end
                default: begin  // 덧셈, 뺄셈
                    process_num2 = (raw % 88) + 12;  // 12-99 범위
                end
            endcase
        end
    endfunction

    // 결과값 유효성 검사
    always @(*) begin
        is_valid_result = 0;  // 기본값은 invalid
        
        case(processed_op)
            3'b000: begin // 덧셈
                if(processed_num1 + processed_num2 <= 8'hFF)
                    is_valid_result = 1;
            end
            
            3'b001: begin // 뺄셈
                if(processed_num1 >= processed_num2)
                    is_valid_result = 1;
            end
            
            3'b010: begin // 곱셈
                if(processed_num1 * processed_num2 <= 8'hFF)
                    is_valid_result = 1;
            end
            
            3'b011: begin // 나눗셈
                if(processed_num2 != 0 && processed_num1 >= processed_num2 && 
                   processed_num1 % processed_num2 == 0)
                    is_valid_result = 1;
            end
            
            3'b100: begin // 나머지
                if(processed_num2 != 0 && processed_num1 >= processed_num2)
                    is_valid_result = 1;
            end
            
            default: is_valid_result = 0;
        endcase
    end
    
    // 상태 레지스터
    always @(posedge clk or posedge rst) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // 다음 상태 로직
    always @(*) begin
        case(state)
            IDLE: 
                next_state = GEN_NUMS;
            
            GEN_NUMS: 
                if(wait_count == 4'h3)
                    next_state = CALCULATE;
                else
                    next_state = GEN_NUMS;
            
            CALCULATE:
                if(wait_count == 4'h3)
                    next_state = CHECK;
                else
                    next_state = CALCULATE;
            
            CHECK: begin
                if(is_valid_result)
                    next_state = DONE;
                else if(retry_count == 4'hA)
                    next_state = DONE;
                else
                    next_state = GEN_NUMS;
            end
            
            DONE:
                if(!ready)
                    next_state = IDLE;
                else
                    next_state = DONE;
            
            default:
                next_state = IDLE;
        endcase
    end
    
    // 데이터패스 및 출력 로직
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ready <= 0;
            retry_count <= 0;
            wait_count <= 0;
            answer <= 8'h0;
            num1 <= 8'h0;
            num2 <= 8'h0;
            op <= 3'h0;
        end
        else begin
            case(state)
                IDLE: begin
                    ready <= 0;
                    retry_count <= 0;
                    wait_count <= 0;
                end
                
                GEN_NUMS: begin
                    wait_count <= wait_count + 1;
                    if(wait_count == 4'h3) begin
                        processed_op <= lfsr2_out[2:0] % 5;
                        processed_num1 <= process_num1(lfsr1_out, processed_op);
                        processed_num2 <= process_num2(lfsr3_out, processed_op);
                        wait_count <= 0;
                    end
                end
                
                CALCULATE: begin
                    wait_count <= wait_count + 1;
                end
                
                CHECK: begin
                    if(is_valid_result) begin
                        answer <= alu_result;
                        num1 <= processed_num1;
                        num2 <= processed_num2;
                        op <= processed_op;
                    end
                    else if(retry_count == 4'hA) begin
                        answer <= 8'h6;  // 6
                        num1 <= 8'h17;   // 23
                        num2 <= 8'h11;   // 17
                        op <= 3'b001;    // 뺄셈
                    end
                    else begin
                        retry_count <= retry_count + 1;
                    end
                end
                
                DONE: begin
                    ready <= 1;
                end
            endcase
        end
    end

endmodule