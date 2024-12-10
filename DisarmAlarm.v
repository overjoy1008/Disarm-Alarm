module DisarmAlarm(
    input wire clk,                  // Clock input (50MHz)
    input wire button_A,             // Reset button (active low)
    input wire button_B,             // Submit button
    input wire [7:0] dip_switch,     // 8-bit DIP switch input
    
    // Piezo output
    output wire piezo_out,
    
    // RGB LED outputs
    output wire CLED_R1, CLED_R2, CLED_R3, CLED_R4,
    output wire CLED_G1, CLED_G2, CLED_G3, CLED_G4,
    output wire CLED_B1, CLED_B2, CLED_B3, CLED_B4,
    
    // 7-segment display outputs
    output wire [7:0] seg_COM,
    output wire [7:0] seg_DATA,
    
    // Text LCD outputs
    output wire lcd_enb,
    output wire lcd_rs, lcd_rw,
    output wire [7:0] lcd_data,
    
    // TFT LCD outputs
    output wire [7:0] R, G, B,
    output wire den, hsync, vsync,
    output wire dclk, disp_en
);

    // Internal signals
    reg [2:0] piezo_ctrl;      // Control signal for DevilsPiezoAlarm
    reg [2:0] rgb_ctrl;        // Control signal for RgbController
    reg [2:0] lcd_ctrl;        // Control signal for TextLcdController
    reg [8:0] seg_binary;      // Value for SegmentController

    // Problem Generator signals
    wire prob_ready;
    wire [7:0] correct_answer;
    wire [7:0] num1, num2;
    wire [2:0] op;
    wire is_answer_correct;
    
    // Current problem storage
    reg [7:0] current_num1;
    reg [7:0] current_num2;
    reg [2:0] current_op;
    reg [7:0] current_answer;
    
    // State definitions
    localparam INIT          = 3'b000;
    localparam STAGE1        = 3'b001;
    localparam STAGE2        = 3'b010;
    localparam STAGE3        = 3'b011;
    localparam PENALTY       = 3'b100;
    localparam SUCCESS_WAIT  = 3'b101;
    localparam FINAL_WIN    = 3'b110;

    // Internal registers
    reg [2:0] current_state;
    reg [2:0] previous_stage;
    reg [31:0] timer_counter;
    reg [1:0] stage_progress;

    // Problem Generator instantiation
    ProblemGenerator problem_gen (
        .clk(clk),
        .rst(button_A),
        .ready(prob_ready),
        .answer(correct_answer),
        .num1(num1),
        .num2(num2),
        .op(op)
    );
    
    // Divided clock signals
    wire clk_1M;    // 1MHz for TFT LCD
    wire clk_1k;    // 1kHz for Segment
    wire clk_500Hz;  // 500Hz for Text LCD
    
    // Constants for timing (based on 50MHz clock)
    localparam ONE_SEC = 50_000_000;
    localparam INIT_TIME = ONE_SEC;
    localparam STAGE_TIME = 60 * ONE_SEC;
    localparam PENALTY_TIME = 3 * ONE_SEC;
    
    // Button B edge detection
    reg button_B_prev;
    wire button_B_posedge;
    
    // Clock Divider instantiation
    ClockDivider clock_divider (
        .clk_50M(clk),
        .rst(button_A),
        .clk_1M(clk_1M),
        .clk_1k(clk_1k),
        .clk_500Hz(clk_500Hz)
    );
    
    // Module instantiations
    DevilsPiezoAlarm piezo_inst (
        .clk(clk),
        .reset(button_A),
        .input_ringtone(piezo_ctrl),
        .piezo_out(piezo_out)
    );
    
    RgbController rgb_inst (
        .clk(clk),
        .rst(button_A),
        .input_color(rgb_ctrl),
        .CLED_R1(CLED_R1), .CLED_R2(CLED_R2), .CLED_R3(CLED_R3), .CLED_R4(CLED_R4),
        .CLED_G1(CLED_G1), .CLED_G2(CLED_G2), .CLED_G3(CLED_G3), .CLED_G4(CLED_G4),
        .CLED_B1(CLED_B1), .CLED_B2(CLED_B2), .CLED_B3(CLED_B3), .CLED_B4(CLED_B4)
    );
    
    SegmentController segment_inst (
        .clk(clk_1k),
        .reset(button_A),
        .binary(seg_binary),
        .seg_COM(seg_COM),
        .seg_DATA(seg_DATA)
    );
    
    TextLcdController lcd_inst (
        .clk(clk_1k),
        .rst(button_A),
        .display_mode(lcd_ctrl),
        .num1(current_num1),
        .num2(current_num2),
        .op(current_opop),
        .lcd_enb(lcd_enb),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_data(lcd_data)
    );
    
    TftLcdDisplayController tft_inst (
        .clk(clk_1M),
        .rst(button_A),
        .R(R),
        .G(G),
        .B(B),
        .den(den),
        .hsync(hsync),
        .vsync(vsync),
        .dclk(dclk),
        .disp_en(disp_en)
    );
    
    // Button B edge detection
    always @(posedge clk) begin
        button_B_prev <= button_B;
    end
    assign button_B_posedge = button_B & ~button_B_prev;

    // Answer checking logic using stored problem
    assign is_answer_correct = (dip_switch == current_answer);
    
    // Main state machine and timer logic
    always @(posedge clk or posedge button_A) begin
        if (button_A) begin
            current_state <= INIT;
            previous_stage <= INIT;
            timer_counter <= INIT_TIME;
            stage_progress <= 0;
            piezo_ctrl <= 3'b000;
            rgb_ctrl <= 3'b000;
            lcd_ctrl <= 3'b000;
            seg_binary <= 0;
            current_num1 <= 0;
            current_num2 <= 0;
            current_op <= 0;
            current_answer <= 0;
        end
        else begin
            case (current_state)
                INIT: begin
                    if (timer_counter == 0 && prob_ready) begin
                        // Store new problem
                        current_num1 <= num1;
                        current_num2 <= num2;
                        current_op <= op;
                        current_answer <= correct_answer;
                        
                        // Transition to first stage
                        current_state <= STAGE1;
                        timer_counter <= STAGE_TIME;
                        seg_binary <= 60;
                        piezo_ctrl <= 3'b001;
                        rgb_ctrl <= 3'b001;
                        lcd_ctrl <= 3'b001;
                    end
                    else if (timer_counter == 0) begin
                        timer_counter <= 1;
                    end
                    else begin
                        timer_counter <= timer_counter - 1;
                    end
                end
                
                STAGE1, STAGE2, STAGE3: begin
                    seg_binary <= timer_counter / ONE_SEC;
                    
                    if (button_B_posedge) begin
                        if (is_answer_correct) begin
                            if (current_state == STAGE3) begin
                                current_state <= FINAL_WIN;
                                piezo_ctrl <= 3'b110;
                                rgb_ctrl <= 3'b110;
                                lcd_ctrl <= 3'b110;
                                seg_binary <= 0;
                            end
                            else begin
                                // Store new problem for next stage
                                current_num1 <= num1;
                                current_num2 <= num2;
                                current_op <= op;
                                current_answer <= correct_answer;
                                
                                current_state <= current_state + 1;
                                timer_counter <= STAGE_TIME;
                                seg_binary <= 60;
                                stage_progress <= stage_progress + 1;
                                piezo_ctrl <= current_state + 1;
                                rgb_ctrl <= current_state + 1;
                                lcd_ctrl <= current_state + 1;
                            end
                        end
                        else begin
                            previous_stage <= current_state;
                            current_state <= PENALTY;
                            timer_counter <= PENALTY_TIME;
                            piezo_ctrl <= 3'b100;
                            rgb_ctrl <= 3'b100;
                            lcd_ctrl <= 3'b100;
                        end
                    end
                    else if (timer_counter == 0) begin
                        previous_stage <= current_state;
                        current_state <= PENALTY;
                        timer_counter <= PENALTY_TIME;
                        piezo_ctrl <= 3'b100;
                        rgb_ctrl <= 3'b100;
                        lcd_ctrl <= 3'b100;
                    end
                    else begin
                        timer_counter <= timer_counter - 1;
                    end
                end
                
                PENALTY: begin
                    seg_binary <= 0;
                    if (timer_counter == 0) begin
                        // Get new problem when returning from penalty
                        current_num1 <= num1;
                        current_num2 <= num2;
                        current_op <= op;
                        current_answer <= correct_answer;
                        
                        current_state <= previous_stage;
                        timer_counter <= STAGE_TIME;
                        seg_binary <= 60;
                        piezo_ctrl <= previous_stage;
                        rgb_ctrl <= previous_stage;
                        lcd_ctrl <= previous_stage;
                    end
                    else begin
                        timer_counter <= timer_counter - 1;
                    end
                end
                
                FINAL_WIN: begin
                    seg_binary <= 0;
                end
                
                default: begin
                    current_state <= INIT;
                    previous_stage <= INIT;
                    timer_counter <= INIT_TIME;
                    seg_binary <= 0;
                    piezo_ctrl <= 3'b000;
                    rgb_ctrl <= 3'b000;
                    lcd_ctrl <= 3'b000;
                    current_num1 <= 0;
                    current_num2 <= 0;
                    current_op <= 0;
                    current_answer <= 0;
                end
            endcase
        end
    end

endmodule