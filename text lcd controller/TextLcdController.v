module TextLcdController(
    input clk, rst,
    input [2:0] display_mode,
    input [7:0] num1,        // 첫 번째 숫자
    input [7:0] num2,        // 두 번째 숫자
    input [2:0] op,          // 연산자
    output lcd_enb,
    output reg lcd_rs, lcd_rw,
    output reg [7:0] lcd_data
);

// LCD Control Commands
parameter CMD_FUNCTION_SET  = 8'b0011_1100,
          CMD_DISPLAY_ON    = 8'b0000_1100,
          CMD_ENTRY_MODE    = 8'b0000_0110,
          CMD_CLEAR_DISPLAY = 8'b0000_0001,
          CMD_RETURN_HOME   = 8'b0000_0010,
          CMD_LINE1_ADDR    = 8'b1000_0000,
          CMD_LINE2_ADDR    = 8'b1100_0000;

// ASCII Characters (8-bit)
parameter 
    // Numbers (0-9)
    CHAR_0 = 8'b0011_0000,
    CHAR_1 = 8'b0011_0001,
    CHAR_2 = 8'b0011_0010,
    CHAR_3 = 8'b0011_0011,
    CHAR_4 = 8'b0011_0100,
    CHAR_5 = 8'b0011_0101,
    CHAR_6 = 8'b0011_0110,
    CHAR_7 = 8'b0011_0111,
    CHAR_8 = 8'b0011_1000,
    CHAR_9 = 8'b0011_1001,

    // Uppercase Letters (A-Z)
    CHAR_A = 8'b0100_0001,
    CHAR_B = 8'b0100_0010,
    CHAR_C = 8'b0100_0011,
    CHAR_D = 8'b0100_0100,
    CHAR_E = 8'b0100_0101,
    CHAR_F = 8'b0100_0110,
    CHAR_G = 8'b0100_0111,
    CHAR_H = 8'b0100_1000,
    CHAR_I = 8'b0100_1001,
    CHAR_J = 8'b0100_1010,
    CHAR_K = 8'b0100_1011,
    CHAR_L = 8'b0100_1100,
    CHAR_M = 8'b0100_1101,
    CHAR_N = 8'b0100_1110,
    CHAR_O = 8'b0100_1111,
    CHAR_P = 8'b0101_0000,
    CHAR_Q = 8'b0101_0001,
    CHAR_R = 8'b0101_0010,
    CHAR_S = 8'b0101_0011,
    CHAR_T = 8'b0101_0100,
    CHAR_U = 8'b0101_0101,
    CHAR_V = 8'b0101_0110,
    CHAR_W = 8'b0101_0111,
    CHAR_X = 8'b0101_1000,
    CHAR_Y = 8'b0101_1001,
    CHAR_Z = 8'b0101_1010,

    // Lowercase Letters (a-z)
    CHAR_a = 8'b0110_0001,
    CHAR_b = 8'b0110_0010,
    CHAR_c = 8'b0110_0011,
    CHAR_d = 8'b0110_0100,
    CHAR_e = 8'b0110_0101,
    CHAR_f = 8'b0110_0110,
    CHAR_g = 8'b0110_0111,
    CHAR_h = 8'b0110_1000,
    CHAR_i = 8'b0110_1001,
    CHAR_j = 8'b0110_1010,
    CHAR_k = 8'b0110_1011,
    CHAR_l = 8'b0110_1100,
    CHAR_m = 8'b0110_1101,
    CHAR_n = 8'b0110_1110,
    CHAR_o = 8'b0110_1111,
    CHAR_p = 8'b0111_0000,
    CHAR_q = 8'b0111_0001,
    CHAR_r = 8'b0111_0010,
    CHAR_s = 8'b0111_0011,
    CHAR_t = 8'b0111_0100,
    CHAR_u = 8'b0111_0101,
    CHAR_v = 8'b0111_0110,
    CHAR_w = 8'b0111_0111,
    CHAR_x = 8'b0111_1000,
    CHAR_y = 8'b0111_1001,
    CHAR_z = 8'b0111_1010,

    // Special Characters
    CHAR_SPACE = 8'b0010_0000,
    CHAR_EXCL  = 8'b0010_0001,  // !
    CHAR_PERC  = 8'b0010_0101,  // %
    CHAR_PLUS  = 8'b0010_1011,  // +
    CHAR_MINUS = 8'b0010_1101,  // -
    CHAR_MULT  = 8'b0010_1010,  // *
    CHAR_DIV   = 8'b1111_1101,  // ÷
    CHAR_EQUAL = 8'b0011_1101,  // =
    CHAR_QUEST = 8'b0011_1111;  // ?

reg [3:0] state;
parameter delay        = 3'b000,
          function_set = 3'b001,
          entry_mode   = 3'b010,
          display_onoff = 3'b011,
          line1        = 3'b100,
          line2        = 3'b101,
          delay_t      = 3'b110,
          clear_display = 3'b111;

integer counter;

// 블록 외부에서 wire 선언
wire [23:0] num1_ascii;
wire [23:0] num2_ascii;
wire [7:0] op_ascii;

// wire에 값 할당
assign num1_ascii = num_to_ascii(num1);
assign num2_ascii = num_to_ascii(num2);
assign op_ascii = op_to_ascii(op);

// State and counter control
always @ (posedge clk or posedge rst) begin
    if (rst) counter = 0;
    else
        case (state)
            delay: begin
                if (counter == 70) counter = 0;
                else counter = counter + 1;
            end
            function_set: begin
                if (counter == 30) counter = 0;
                else counter = counter + 1;
            end
            display_onoff: begin
                if (counter == 30) counter = 0;
                else counter = counter + 1;
            end
            entry_mode: begin
                if (counter == 30) counter = 0;
                else counter = counter + 1;
            end
            line1: begin
                if (counter == 20) counter = 0;
                else counter = counter + 1;
            end
            line2: begin
                if (counter == 20) counter = 0;
                else counter = counter + 1;
            end
            delay_t: begin
                if (counter == 400) counter = 0;
                else counter = counter + 1;
            end
            clear_display: begin
                if (counter == 200) counter = 0;
                else counter = counter + 1;
            end
        endcase
end

// 숫자를 ASCII로 변환하는 함수
function [23:0] num_to_ascii;  // 최대 3자리 숫자를 위해 24비트
    input [7:0] number;
    reg [3:0] hundreds, tens, ones;
    begin
        hundreds = number / 100;
        tens = (number % 100) / 10;
        ones = number % 10;
        
        // ASCII 변환
        if (hundreds > 0)
            num_to_ascii = {8'h30 + hundreds, 8'h30 + tens, 8'h30 + ones};
        else if (tens > 0)
            num_to_ascii = {8'h20, 8'h30 + tens, 8'h30 + ones};
        else
            num_to_ascii = {8'h20, 8'h20, 8'h30 + ones};
    end
endfunction

// 연산자를 ASCII로 변환하는 함수
function [7:0] op_to_ascii;
    input [2:0] operation;
    begin
        case(operation)
            3'b000: op_to_ascii = CHAR_PLUS;   // +
            3'b001: op_to_ascii = CHAR_MINUS;  // -
            3'b010: op_to_ascii = CHAR_MULT;   // *
            3'b011: op_to_ascii = CHAR_DIV;    // /
            3'b100: op_to_ascii = CHAR_PERC;   // %
            default: op_to_ascii = CHAR_PLUS;
        endcase
    end
endfunction

// State machine
always @ (posedge clk or posedge rst) begin
    if (rst) begin 
        state = delay;
        counter = 0;
    end
    else begin
        case (state)
            delay: begin
                if (counter == 70) begin 
                    state = function_set;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            function_set: begin
                if (counter == 30) begin
                    state = display_onoff;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            display_onoff: begin
                if (counter == 30) begin
                    state = entry_mode;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            entry_mode: begin
                if (counter == 30) begin
                    state = line1;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            line1: begin
                if (counter == 20) begin
                    state = (display_mode == 3'b100) ? delay_t : line2;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            line2: begin
                if (counter == 20) begin
                    state = delay_t;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            delay_t: begin
                if (counter == 400) begin
                    state = clear_display;
                    counter = 0;
                end
                else counter = counter + 1;
            end
            clear_display: begin
                if (counter == 200) begin
                    state = (display_mode == 3'b000) ? clear_display : line1;
                    counter = 0;
                end
                else counter = counter + 1;
            end
        endcase
    end
end

// Output control
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        lcd_rs = 1'b1;
        lcd_rw = 1'b1;
        lcd_data = 8'b0000_0000;
    end
    else begin
        case (state)
            function_set: begin
                lcd_rs = 1'b0;
                lcd_rw = 1'b0;
                lcd_data = CMD_FUNCTION_SET;
            end
            display_onoff: begin
                lcd_rs = 1'b0;
                lcd_rw = 1'b0;
                lcd_data = CMD_DISPLAY_ON;
            end
            entry_mode: begin
                lcd_rs = 1'b0;
                lcd_rw = 1'b0;
                lcd_data = CMD_ENTRY_MODE;
            end
            line1: begin
                lcd_rw = 1'b0;
                case (display_mode)
                    3'b001, 3'b010, 3'b011: begin  // Problem display                        
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE1_ADDR; end
                            // First number (up to 3 digits)
                            1: begin lcd_rs = 1'b1; lcd_data = num1_ascii[23:16]; end
                            2: begin lcd_rs = 1'b1; lcd_data = num1_ascii[15:8]; end
                            3: begin lcd_rs = 1'b1; lcd_data = num1_ascii[7:0]; end
                            // Operator
                            4: begin lcd_rs = 1'b1; lcd_data = op_ascii; end
                            // Second number (up to 2 digits)
                            5: begin lcd_rs = 1'b1; lcd_data = num2_ascii[15:8]; end
                            6: begin lcd_rs = 1'b1; lcd_data = num2_ascii[7:0]; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_EQUAL; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_QUEST; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    3'b100: begin  // Wrong answer
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE1_ADDR; end
                            1: begin lcd_rs = 1'b1; lcd_data = CHAR_W; end
                            2: begin lcd_rs = 1'b1; lcd_data = CHAR_R; end
                            3: begin lcd_rs = 1'b1; lcd_data = CHAR_O; end
                            4: begin lcd_rs = 1'b1; lcd_data = CHAR_N; end
                            5: begin lcd_rs = 1'b1; lcd_data = CHAR_G; end
                            6: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_A; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_N; end
                            9: begin lcd_rs = 1'b1; lcd_data = CHAR_S; end
                            10: begin lcd_rs = 1'b1; lcd_data = CHAR_W; end
                            11: begin lcd_rs = 1'b1; lcd_data = CHAR_E; end
                            12: begin lcd_rs = 1'b1; lcd_data = CHAR_R; end
                            13: begin lcd_rs = 1'b1; lcd_data = CHAR_EXCL; end
                            14: begin lcd_rs = 1'b1; lcd_data = CHAR_EXCL; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    3'b101, 3'b110: begin  // Correct answer (first line)
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE1_ADDR; end
                            1: begin lcd_rs = 1'b1; lcd_data = CHAR_C; end
                            2: begin lcd_rs = 1'b1; lcd_data = CHAR_O; end
                            3: begin lcd_rs = 1'b1; lcd_data = CHAR_R; end
                            4: begin lcd_rs = 1'b1; lcd_data = CHAR_R; end
                            5: begin lcd_rs = 1'b1; lcd_data = CHAR_E; end
                            6: begin lcd_rs = 1'b1; lcd_data = CHAR_C; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_T; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            9: begin lcd_rs = 1'b1; lcd_data = CHAR_A; end
                            10: begin lcd_rs = 1'b1; lcd_data = CHAR_N; end
                            11: begin lcd_rs = 1'b1; lcd_data = CHAR_S; end
                            12: begin lcd_rs = 1'b1; lcd_data = CHAR_W; end
                            13: begin lcd_rs = 1'b1; lcd_data = CHAR_E; end
                            14: begin lcd_rs = 1'b1; lcd_data = CHAR_R; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                endcase
            end
            line2: begin
                lcd_rw = 1'b0;
                case (display_mode)
                    3'b001, 3'b010, 3'b011: begin  // Original puzzle second line
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE2_ADDR; end
                            1: begin lcd_rs = 1'b1; lcd_data = CHAR_I; end
                            2: begin lcd_rs = 1'b1; lcd_data = CHAR_n; end
                            3: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            4: begin lcd_rs = 1'b1; lcd_data = CHAR_B; end
                            5: begin lcd_rs = 1'b1; lcd_data = CHAR_i; end
                            6: begin lcd_rs = 1'b1; lcd_data = CHAR_n; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_a; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_r; end
                            9: begin lcd_rs = 1'b1; lcd_data = CHAR_y; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    3'b101: begin  // Wait 5 Minutes
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE2_ADDR; end
                            1: begin lcd_rs = 1'b1; lcd_data = CHAR_W; end
                            2: begin lcd_rs = 1'b1; lcd_data = CHAR_a; end
                            3: begin lcd_rs = 1'b1; lcd_data = CHAR_i; end
                            4: begin lcd_rs = 1'b1; lcd_data = CHAR_t; end
                            5: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            6: begin lcd_rs = 1'b1; lcd_data = CHAR_5; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_M; end
                            9: begin lcd_rs = 1'b1; lcd_data = CHAR_i; end
                            10: begin lcd_rs = 1'b1; lcd_data = CHAR_n; end
                            11: begin lcd_rs = 1'b1; lcd_data = CHAR_u; end
                            12: begin lcd_rs = 1'b1; lcd_data = CHAR_t; end
                            13: begin lcd_rs = 1'b1; lcd_data = CHAR_e; end
                            14: begin lcd_rs = 1'b1; lcd_data = CHAR_s; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    3'b110: begin  // Alarm Disarmed
                        case (counter)
                            0: begin lcd_rs = 1'b0; lcd_data = CMD_LINE2_ADDR; end
                            1: begin lcd_rs = 1'b1; lcd_data = CHAR_A; end
                            2: begin lcd_rs = 1'b1; lcd_data = CHAR_l; end
                            3: begin lcd_rs = 1'b1; lcd_data = CHAR_a; end
                            4: begin lcd_rs = 1'b1; lcd_data = CHAR_r; end
                            5: begin lcd_rs = 1'b1; lcd_data = CHAR_m; end
                            6: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                            7: begin lcd_rs = 1'b1; lcd_data = CHAR_D; end
                            8: begin lcd_rs = 1'b1; lcd_data = CHAR_i; end
                            9: begin lcd_rs = 1'b1; lcd_data = CHAR_s; end
                            10: begin lcd_rs = 1'b1; lcd_data = CHAR_a; end
                            11: begin lcd_rs = 1'b1; lcd_data = CHAR_r; end
                            12: begin lcd_rs = 1'b1; lcd_data = CHAR_m; end
                            13: begin lcd_rs = 1'b1; lcd_data = CHAR_e; end
                            14: begin lcd_rs = 1'b1; lcd_data = CHAR_d; end
                            default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                        endcase
                    end
                    default: begin lcd_rs = 1'b1; lcd_data = CHAR_SPACE; end
                endcase
            end
            delay_t: begin
                lcd_rs = 1'b0;
                lcd_rw = 1'b0;
                lcd_data = CMD_RETURN_HOME;
            end
            clear_display: begin
                lcd_rs = 1'b0;
                lcd_rw = 1'b0;
                lcd_data = CMD_CLEAR_DISPLAY;
            end
            default: begin
                lcd_rs = 1'b1;
                lcd_rw = 1'b1;
                lcd_data = 8'b0000_0000;
            end
        endcase
    end
end

assign lcd_enb = clk;

endmodule