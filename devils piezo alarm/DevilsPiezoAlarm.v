module DevilsPiezoAlarm (
    input wire clk,                  // Clock input (50MHz)
    input wire reset,                // Reset input
    input wire [2:0] input_ringtone, // 3-bit ringtone selection
    output reg piezo_out            // Piezo buzzer output
);

    // 기본 클럭 주파수 정의 (50MHz)
    parameter CLOCK_FREQ = 50000000;
    
    // 음계 주파수 정의 (Hz)
    
    // 2옥타브
    parameter NOTE_A2 = 110;

    // 3옥타브
    parameter NOTE_C3 = 131;
    parameter NOTE_D3 = 147;
    parameter NOTE_E3 = 165;
    parameter NOTE_F3 = 175;
    parameter NOTE_G3 = 196;
    parameter NOTE_A3 = 220;
    parameter NOTE_BB3 = 233;
    parameter NOTE_B3 = 247;
    
    // 4옥타브
    parameter NOTE_C4 = 262;
    parameter NOTE_D4 = 294;
    parameter NOTE_E4 = 330;
    parameter NOTE_F4 = 349;
    parameter NOTE_G4 = 392;
    parameter NOTE_A4 = 440;
    parameter NOTE_BB4 = 466;
    parameter NOTE_B4 = 494;
    
    // 5옥타브
    parameter NOTE_C5 = 523;
    parameter NOTE_D5 = 587;
    parameter NOTE_E5 = 659;
    parameter NOTE_F5 = 698;
    parameter NOTE_G5 = 784;
    parameter NOTE_A5 = 880;
    parameter NOTE_B5 = 988;
    
    // 6옥타브
    parameter NOTE_C6 = 1047;
    parameter NOTE_D6 = 1175;
    parameter NOTE_E6 = 1319;
    parameter NOTE_F6 = 1397;
    parameter NOTE_G6 = 1568;
    parameter NOTE_A6 = 1760;
    parameter NOTE_B6 = 1976;

    // 불협화음을 위한 특수 주파수
    parameter NOTE_WRONG1 = 1200; // 듣기 불편한 주파수 1
    parameter NOTE_WRONG2 = 950;  // 듣기 불편한 주파수 2
    
    // 무음 상태를 위한 파라미터
    parameter NOTE_NONE = 0;
    
    // 내부 레지스터들
    reg [31:0] counter;
    reg [31:0] note_counter;
    reg [7:0] melody_index;  // 더 긴 멜로디를 위해 8비트로 확장
    reg [31:0] current_freq;
    reg pwm_out;
    
    // 멜로디 배열 (첫 번째 멜로디 - 001)
    parameter MELODY_1_LENGTH = 80;  // 64 + 16
    reg [31:0] melody_1 [0:79];
    
    // 멜로디 배열 (두 번째 멜로디 - 010)
    parameter MELODY_2_LENGTH = 208;
    reg [31:0] melody_2 [0:207];
    
    // 멜로디 배열 (세 번째 멜로디 - 011)
    parameter MELODY_3_LENGTH = 204;  // 17 * 12
    reg [31:0] melody_3 [0:203];

    // 오답 멜로디 (100)
    parameter WRONG_MELODY_LENGTH = 16;
    reg [31:0] wrong_melody [0:15];
    
    // 정답 멜로디 (101 or 110)
    parameter CORRECT_MELODY_LENGTH = 32;
    reg [31:0] correct_melody [0:31];
    
    // 초기화
    integer i;
    initial begin
        counter = 0;
        note_counter = 0;
        melody_index = 0;
        current_freq = 0;
        pwm_out = 0;
        
        // 첫 번째 멜로디 초기화 (00)
        melody_1[0] = NOTE_C4;
        melody_1[1] = NOTE_C4;
        melody_1[2] = NOTE_C5;
        melody_1[3] = NOTE_C5;
        melody_1[4] = NOTE_G5;
        melody_1[5] = NOTE_F5;
        melody_1[6] = NOTE_C5;
        melody_1[7] = NOTE_C5;
        
        melody_1[8] = NOTE_C4;
        melody_1[9] = NOTE_C4;
        melody_1[10] = NOTE_C5;
        melody_1[11] = NOTE_C5;
        melody_1[12] = NOTE_A5;
        melody_1[13] = NOTE_F5;
        melody_1[14] = NOTE_C5;
        melody_1[15] = NOTE_C5;
        
        melody_1[16] = NOTE_C4;
        melody_1[17] = NOTE_C4;
        melody_1[18] = NOTE_C5;
        melody_1[19] = NOTE_C5;
        melody_1[20] = NOTE_E5;
        melody_1[21] = NOTE_D5;
        melody_1[22] = NOTE_C5;
        melody_1[23] = NOTE_C5;
        
        melody_1[24] = NOTE_BB3;
        melody_1[25] = NOTE_BB3;
        melody_1[26] = NOTE_BB4;
        melody_1[27] = NOTE_BB4;
        melody_1[28] = NOTE_F5;
        melody_1[29] = NOTE_D5;
        melody_1[30] = NOTE_BB4;
        melody_1[31] = NOTE_BB4;
        
        melody_1[32] = NOTE_C4;
        melody_1[33] = NOTE_C4;
        melody_1[34] = NOTE_C5;
        melody_1[35] = NOTE_C5;
        melody_1[36] = NOTE_G5;
        melody_1[37] = NOTE_F5;
        melody_1[38] = NOTE_C5;
        melody_1[39] = NOTE_C5;
        
        melody_1[40] = NOTE_C4;
        melody_1[41] = NOTE_C4;
        melody_1[42] = NOTE_C5;
        melody_1[43] = NOTE_C5;
        melody_1[44] = NOTE_A5;
        melody_1[45] = NOTE_F5;
        melody_1[46] = NOTE_C5;
        melody_1[47] = NOTE_C5;
        
        melody_1[48] = NOTE_C4;
        melody_1[49] = NOTE_C4;
        melody_1[50] = NOTE_C5;
        melody_1[51] = NOTE_C5;
        melody_1[52] = NOTE_E5;
        melody_1[53] = NOTE_D5;
        melody_1[54] = NOTE_C5;
        melody_1[55] = NOTE_C5;
        
        melody_1[56] = NOTE_BB3;
        melody_1[57] = NOTE_BB3;
        melody_1[58] = NOTE_BB4;
        melody_1[59] = NOTE_BB4;
        melody_1[60] = NOTE_F5;
        melody_1[61] = NOTE_D5;
        melody_1[62] = NOTE_BB4;
        melody_1[63] = NOTE_BB4;
        
        // 마지막 16개 음표는 무음
        for (i = 64; i < 80; i = i + 1) begin
            melody_1[i] = NOTE_NONE;
        end

        
        // 세 번째 멜로디 초기화 (11)
        melody_2[0] = NOTE_C5;
        melody_2[1] = NOTE_C5;
        melody_2[2] = NOTE_C5;
        melody_2[3] = NOTE_C5;
        melody_2[4] = NOTE_A4;
        melody_2[5] = NOTE_A4;
        melody_2[6] = NOTE_A4;
        melody_2[7] = NOTE_A4;
        melody_2[8] = NOTE_G4;
        melody_2[9] = NOTE_G4;
        melody_2[10] = NOTE_G4;
        melody_2[11] = NOTE_G4;
        melody_2[12] = NOTE_G4;
        melody_2[13] = NOTE_G4;
        melody_2[14] = NOTE_G4;
        melody_2[15] = NOTE_G4;

        for (i = 16; i < 32; i = i + 1) begin
            melody_2[i] = NOTE_NONE;
        end

        melody_2[32] = NOTE_C5;
        melody_2[33] = NOTE_C5;
        melody_2[34] = NOTE_C5;
        melody_2[35] = NOTE_C5;
        melody_2[36] = NOTE_A4;
        melody_2[37] = NOTE_A4;
        melody_2[38] = NOTE_A4;
        melody_2[39] = NOTE_A4;
        melody_2[40] = NOTE_G4;
        melody_2[41] = NOTE_G4;
        melody_2[42] = NOTE_G4;
        melody_2[43] = NOTE_G4;
        melody_2[44] = NOTE_G4;
        melody_2[45] = NOTE_G4;
        
        for (i = 46; i < 48; i = i + 1) begin
            melody_2[i] = NOTE_NONE;
        end

        melody_2[48] = NOTE_C5;
        melody_2[49] = NOTE_C5;
        melody_2[50] = NOTE_C5;
        melody_2[51] = NOTE_C5;
        melody_2[52] = NOTE_A4;
        melody_2[53] = NOTE_A4;
        melody_2[54] = NOTE_A4;
        melody_2[55] = NOTE_A4;
        melody_2[56] = NOTE_G4;
        melody_2[57] = NOTE_G4;
        melody_2[58] = NOTE_G4;
        melody_2[59] = NOTE_G4;
        melody_2[60] = NOTE_G4;
        melody_2[61] = NOTE_G4;
        melody_2[62] = NOTE_G4;
        melody_2[63] = NOTE_G4;

        for (i = 64; i < 82; i = i + 1) begin
            melody_2[i] = NOTE_NONE;
        end

        melody_2[82] = NOTE_G5;
        melody_2[83] = NOTE_NONE;
        melody_2[84] = NOTE_A5;
        melody_2[85] = NOTE_NONE;
        melody_2[86] = NOTE_C6;
        melody_2[87] = NOTE_NONE;
        melody_2[88] = NOTE_E6;
        melody_2[89] = NOTE_E6;
        melody_2[90] = NOTE_E6;
        melody_2[91] = NOTE_NONE;
        melody_2[92] = NOTE_C6;
        melody_2[93] = NOTE_C6;
        melody_2[94] = NOTE_C6;
        melody_2[95] = NOTE_NONE;
        melody_2[96] = NOTE_A5;
        melody_2[97] = NOTE_NONE;
        melody_2[98] = NOTE_A5;
        melody_2[99] = NOTE_NONE;
        melody_2[100] = NOTE_C6;
        melody_2[101] = NOTE_NONE;
        melody_2[102] = NOTE_E6;
        melody_2[103] = NOTE_E6;
        melody_2[104] = NOTE_E6;
        melody_2[105] = NOTE_E6;
        melody_2[106] = NOTE_C5;
        melody_2[107] = NOTE_C5;
        melody_2[108] = NOTE_C5;
        melody_2[109] = NOTE_C5;
        melody_2[110] = NOTE_A4;
        melody_2[111] = NOTE_A4;
        melody_2[112] = NOTE_A4;
        melody_2[113] = NOTE_A4;

        melody_2[114] = NOTE_G5;
        melody_2[115] = NOTE_NONE;
        melody_2[116] = NOTE_A5;
        melody_2[117] = NOTE_NONE;
        melody_2[118] = NOTE_C6;
        melody_2[119] = NOTE_NONE;
        melody_2[120] = NOTE_E6;
        melody_2[121] = NOTE_E6;
        melody_2[122] = NOTE_E6;
        melody_2[123] = NOTE_NONE;
        melody_2[124] = NOTE_C6;
        melody_2[125] = NOTE_C6;
        melody_2[126] = NOTE_C6;
        melody_2[127] = NOTE_NONE;
        melody_2[128] = NOTE_A5;
        melody_2[129] = NOTE_NONE;
        melody_2[130] = NOTE_A5;
        melody_2[131] = NOTE_NONE;
        melody_2[132] = NOTE_C6;
        melody_2[133] = NOTE_NONE;
        melody_2[134] = NOTE_D6;
        melody_2[135] = NOTE_D6;
        melody_2[136] = NOTE_D6;
        melody_2[137] = NOTE_D6;
        melody_2[138] = NOTE_B4;
        melody_2[139] = NOTE_B4;
        melody_2[140] = NOTE_B4;
        melody_2[141] = NOTE_B4;
        melody_2[142] = NOTE_A4;
        melody_2[143] = NOTE_A4;
        melody_2[144] = NOTE_A4;
        melody_2[145] = NOTE_A4;

        melody_2[146] = NOTE_G5;
        melody_2[147] = NOTE_NONE;
        melody_2[148] = NOTE_A5;
        melody_2[149] = NOTE_NONE;
        melody_2[150] = NOTE_C6;
        melody_2[151] = NOTE_NONE;
        melody_2[152] = NOTE_E6;
        melody_2[153] = NOTE_E6;
        melody_2[154] = NOTE_E6;
        melody_2[155] = NOTE_NONE;
        melody_2[156] = NOTE_C6;
        melody_2[157] = NOTE_C6;
        melody_2[158] = NOTE_C6;
        melody_2[159] = NOTE_NONE;
        melody_2[160] = NOTE_A5;
        melody_2[161] = NOTE_NONE;
        melody_2[162] = NOTE_A5;
        melody_2[163] = NOTE_NONE;
        melody_2[164] = NOTE_C6;
        melody_2[165] = NOTE_NONE;
        melody_2[166] = NOTE_E6;
        melody_2[167] = NOTE_E6;
        melody_2[168] = NOTE_E6;
        melody_2[169] = NOTE_E6;
        melody_2[170] = NOTE_C5;
        melody_2[171] = NOTE_C5;
        melody_2[172] = NOTE_C5;
        melody_2[173] = NOTE_C5;
        melody_2[174] = NOTE_A4;
        melody_2[175] = NOTE_A4;
        melody_2[176] = NOTE_A4;
        melody_2[177] = NOTE_A4;

        melody_2[178] = NOTE_G5;
        melody_2[179] = NOTE_NONE;
        melody_2[180] = NOTE_A5;
        melody_2[181] = NOTE_NONE;
        melody_2[182] = NOTE_C6;
        melody_2[183] = NOTE_NONE;
        melody_2[184] = NOTE_E6;
        melody_2[185] = NOTE_E6;
        melody_2[186] = NOTE_E6;
        melody_2[187] = NOTE_NONE;
        melody_2[188] = NOTE_C6;
        melody_2[189] = NOTE_C6;
        melody_2[190] = NOTE_C6;
        melody_2[191] = NOTE_NONE;
        melody_2[192] = NOTE_A5;
        melody_2[193] = NOTE_NONE;
        melody_2[194] = NOTE_A5;
        melody_2[195] = NOTE_NONE;
        melody_2[196] = NOTE_C6;
        melody_2[197] = NOTE_NONE;
        melody_2[198] = NOTE_D6;
        melody_2[199] = NOTE_D6;
        melody_2[200] = NOTE_D6;
        melody_2[201] = NOTE_D6;
        melody_2[202] = NOTE_NONE;
        melody_2[203] = NOTE_NONE;
        melody_2[204] = NOTE_NONE;
        melody_2[205] = NOTE_NONE;
        melody_2[206] = NOTE_NONE;
        melody_2[207] = NOTE_NONE;

        // 세 번째 멜로디 초기화 (011) - 새로운 멜로디
        melody_3[0] = NOTE_F4; melody_3[1] = NOTE_F4; melody_3[2] = NOTE_C5; 
        melody_3[3] = NOTE_C5; melody_3[4] = NOTE_D5; melody_3[5] = NOTE_D5;
        melody_3[6] = NOTE_G5; melody_3[7] = NOTE_G5; melody_3[8] = NOTE_A5;
        melody_3[9] = NOTE_A5; melody_3[10] = NOTE_A5; melody_3[11] = NOTE_NONE;

        melody_3[12] = NOTE_G4; melody_3[13] = NOTE_G4; melody_3[14] = NOTE_C5;
        melody_3[15] = NOTE_C5; melody_3[16] = NOTE_D5; melody_3[17] = NOTE_D5;
        melody_3[18] = NOTE_B5; melody_3[19] = NOTE_B5; melody_3[20] = NOTE_C6;
        melody_3[21] = NOTE_C6; melody_3[22] = NOTE_C6; melody_3[23] = NOTE_NONE;

        melody_3[24] = NOTE_A4; melody_3[25] = NOTE_A4; melody_3[26] = NOTE_C5;
        melody_3[27] = NOTE_C5; melody_3[28] = NOTE_D5; melody_3[29] = NOTE_D5;
        melody_3[30] = NOTE_E5; melody_3[31] = NOTE_E5; melody_3[32] = NOTE_G5;
        melody_3[33] = NOTE_G5; melody_3[34] = NOTE_G5; melody_3[35] = NOTE_NONE;

        melody_3[36] = NOTE_A3; melody_3[37] = NOTE_A3; melody_3[38] = NOTE_E5;
        melody_3[39] = NOTE_E5; melody_3[40] = NOTE_D5; melody_3[41] = NOTE_D5;
        melody_3[42] = NOTE_C5; melody_3[43] = NOTE_C5; melody_3[44] = NOTE_B4;
        melody_3[45] = NOTE_B4; melody_3[46] = NOTE_A4; melody_3[47] = NOTE_A4;

        // ... 나머지 모든 음표들도 같은 방식으로 한 옥타브씩 올렸습니다
        melody_3[48] = NOTE_D3; melody_3[49] = NOTE_D3; melody_3[50] = NOTE_G4;
        melody_3[51] = NOTE_G4; melody_3[52] = NOTE_A4; melody_3[53] = NOTE_A4;
        melody_3[54] = NOTE_D4; melody_3[55] = NOTE_D4; melody_3[56] = NOTE_E4;
        melody_3[57] = NOTE_E4; melody_3[58] = NOTE_E4; melody_3[59] = NOTE_NONE;

        melody_3[60] = NOTE_C3; melody_3[61] = NOTE_C3; melody_3[62] = NOTE_D5;
        melody_3[63] = NOTE_D5; melody_3[64] = NOTE_E5; melody_3[65] = NOTE_E5;
        melody_3[66] = NOTE_G4; melody_3[67] = NOTE_G4; melody_3[68] = NOTE_A4;
        melody_3[69] = NOTE_A4; melody_3[70] = NOTE_A4; melody_3[71] = NOTE_NONE;

        melody_3[72] = NOTE_A2; melody_3[73] = NOTE_A2; melody_3[74] = NOTE_B4;
        melody_3[75] = NOTE_B4; melody_3[76] = NOTE_C5; melody_3[77] = NOTE_C5;
        melody_3[78] = NOTE_G4; melody_3[79] = NOTE_G4; melody_3[80] = NOTE_A4;
        melody_3[81] = NOTE_A4; melody_3[82] = NOTE_E4; melody_3[83] = NOTE_E4;

        melody_3[84] = NOTE_A2; melody_3[85] = NOTE_A2; melody_3[86] = NOTE_G4;
        melody_3[87] = NOTE_G4; melody_3[88] = NOTE_A4; melody_3[89] = NOTE_A4;
        melody_3[90] = NOTE_B4; melody_3[91] = NOTE_B4; melody_3[92] = NOTE_C5;
        melody_3[93] = NOTE_C5; melody_3[94] = NOTE_G5; melody_3[95] = NOTE_G5;

        melody_3[96] = NOTE_F3; melody_3[97] = NOTE_F3; melody_3[98] = NOTE_C6;
        melody_3[99] = NOTE_F5; melody_3[100] = NOTE_D6; melody_3[101] = NOTE_F5;
        melody_3[102] = NOTE_G6; melody_3[103] = NOTE_F5; melody_3[104] = NOTE_A6;
        melody_3[105] = NOTE_A6; melody_3[106] = NOTE_F4; melody_3[107] = NOTE_F4;

        melody_3[108] = NOTE_G3; melody_3[109] = NOTE_G3; melody_3[110] = NOTE_C6;
        melody_3[111] = NOTE_G5; melody_3[112] = NOTE_D6; melody_3[113] = NOTE_G5;
        melody_3[114] = NOTE_B6; melody_3[115] = NOTE_G5; melody_3[116] = NOTE_A6;
        melody_3[117] = NOTE_A6; melody_3[118] = NOTE_G4; melody_3[119] = NOTE_G4;

        melody_3[120] = NOTE_A3; melody_3[121] = NOTE_A3; melody_3[122] = NOTE_C6;
        melody_3[123] = NOTE_A5; melody_3[124] = NOTE_D6; melody_3[125] = NOTE_A5;
        melody_3[126] = NOTE_E6; melody_3[127] = NOTE_A5; melody_3[128] = NOTE_A6;
        melody_3[129] = NOTE_A6; melody_3[130] = NOTE_A4; melody_3[131] = NOTE_A4;

        melody_3[132] = NOTE_A3; melody_3[133] = NOTE_A3; melody_3[134] = NOTE_C6;
        melody_3[135] = NOTE_A5; melody_3[136] = NOTE_G6; melody_3[137] = NOTE_A5;
        melody_3[138] = NOTE_D6; melody_3[139] = NOTE_A5; melody_3[140] = NOTE_E6;
        melody_3[141] = NOTE_A5; melody_3[142] = NOTE_C6; melody_3[143] = NOTE_A5;

        melody_3[144] = NOTE_D4; melody_3[145] = NOTE_D4; melody_3[146] = NOTE_A5;
        melody_3[147] = NOTE_D5; melody_3[148] = NOTE_C6; melody_3[149] = NOTE_D5;
        melody_3[150] = NOTE_D6; melody_3[151] = NOTE_D5; melody_3[152] = NOTE_G6;
        melody_3[153] = NOTE_G6; melody_3[154] = NOTE_D4; melody_3[155] = NOTE_D4;

        melody_3[156] = NOTE_C4; melody_3[157] = NOTE_C4; melody_3[158] = NOTE_G5;
        melody_3[159] = NOTE_C5; melody_3[160] = NOTE_C6; melody_3[161] = NOTE_C5;
        melody_3[162] = NOTE_B5; melody_3[163] = NOTE_C5; melody_3[164] = NOTE_G5;
        melody_3[165] = NOTE_G5; melody_3[166] = NOTE_C4; melody_3[167] = NOTE_C4;

        melody_3[168] = NOTE_A3; melody_3[169] = NOTE_A3; melody_3[170] = NOTE_C5;
        melody_3[171] = NOTE_A4; melody_3[172] = NOTE_D5; melody_3[173] = NOTE_A4;
        melody_3[174] = NOTE_E5; melody_3[175] = NOTE_A4; melody_3[176] = NOTE_C5;
        melody_3[177] = NOTE_C5; melody_3[178] = NOTE_A4; melody_3[179] = NOTE_A4;

        melody_3[180] = NOTE_A3; melody_3[181] = NOTE_A3; melody_3[182] = NOTE_C5;
        melody_3[183] = NOTE_A4; melody_3[184] = NOTE_D5; melody_3[185] = NOTE_A4;
        melody_3[186] = NOTE_E5; melody_3[187] = NOTE_A4; melody_3[188] = NOTE_G5;
        melody_3[189] = NOTE_A4; melody_3[190] = NOTE_C6; melody_3[191] = NOTE_A4;

        // 마지막 12개 음표는 무음
        for (i = 192; i < 204; i = i + 1) begin
            melody_3[i] = NOTE_NONE;
        end

        // 오답 멜로디 초기화 - 짧고 거북한 소리
        wrong_melody[0] = NOTE_WRONG1;
        wrong_melody[1] = NOTE_WRONG2;
        wrong_melody[2] = NOTE_WRONG1;
        wrong_melody[3] = NOTE_WRONG2;
        wrong_melody[4] = NOTE_WRONG1;
        wrong_melody[5] = NOTE_WRONG2;
        wrong_melody[6] = NOTE_WRONG1;
        wrong_melody[7] = NOTE_WRONG2;
        wrong_melody[8] = NOTE_WRONG1;
        wrong_melody[9] = NOTE_WRONG2;
        wrong_melody[10] = NOTE_WRONG1;
        wrong_melody[11] = NOTE_WRONG2;
        for (i = 12; i < WRONG_MELODY_LENGTH; i = i + 1) begin
            wrong_melody[i] = NOTE_NONE;
        end
        
        // 정답 멜로디 초기화
        correct_melody[0] = NOTE_G5;
        correct_melody[1] = NOTE_G4;
        correct_melody[2] = NOTE_C5;
        correct_melody[3] = NOTE_G5;
        correct_melody[4] = NOTE_G4;
        correct_melody[5] = NOTE_C5;
        correct_melody[6] = NOTE_C6;
        correct_melody[7] = NOTE_C6;
        correct_melody[8] = NOTE_C6;
        correct_melody[9] = NOTE_C6;
        // 나머지는 무음 처리
        for (i = 10; i < CORRECT_MELODY_LENGTH; i = i + 1) begin
            correct_melody[i] = NOTE_NONE;
        end
    end
    
    // 메인 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            note_counter <= 0;
            melody_index <= 0;
            pwm_out <= 0;
            current_freq <= 0;
        end
        else begin
            case (input_ringtone)
                3'b001: begin  // 첫 번째 멜로디
                    if (note_counter >= CLOCK_FREQ/8) begin  // 0.125초마다 음 변경
                        note_counter <= 0;
                        melody_index <= (melody_index == MELODY_1_LENGTH-1) ? 0 : melody_index + 1;
                    end
                    else begin
                        note_counter <= note_counter + 1;
                    end
                    
                    current_freq <= melody_1[melody_index];
                end
                
                3'b010: begin  // 두 번째 멜로디
                    if (note_counter >= CLOCK_FREQ/8) begin
                        note_counter <= 0;
                        melody_index <= (melody_index == MELODY_2_LENGTH-1) ? 0 : melody_index + 1;
                    end
                    else begin
                        note_counter <= note_counter + 1;
                    end
                    
                    current_freq <= melody_2[melody_index];
                end

                3'b011: begin  // 세 번째 멜로디
                    if (note_counter >= CLOCK_FREQ/8) begin
                        note_counter <= 0;
                        melody_index <= (melody_index == MELODY_3_LENGTH-1) ? 0 : melody_index + 1;
                    end
                    else begin
                        note_counter <= note_counter + 1;
                    end
                    
                    current_freq <= melody_3[melody_index];
                end

                3'b100: begin  // 오답 멜로디
                    if (note_counter >= CLOCK_FREQ/8) begin
                        note_counter <= 0;
                        if (melody_index == WRONG_MELODY_LENGTH-1) begin
                            melody_index <= WRONG_MELODY_LENGTH-1;  // 마지막에서 멈춤
                        end else begin
                            melody_index <= melody_index + 1;
                        end
                    end
                    else begin
                        note_counter <= note_counter + 1;
                    end
                    current_freq <= wrong_melody[melody_index];
                end
                
                3'b101, 3'b110: begin  // 정답 멜로디
                    if (note_counter >= CLOCK_FREQ/4) begin  // 0.25초마다 음 변경
                        note_counter <= 0;
                        if (melody_index == CORRECT_MELODY_LENGTH-1) begin
                            melody_index <= CORRECT_MELODY_LENGTH-1;  // 마지막에서 멈춤
                        end else begin
                            melody_index <= melody_index + 1;
                        end
                    end
                    else begin
                        note_counter <= note_counter + 1;
                    end
                    current_freq <= correct_melody[melody_index];
                end
                
                default: begin  // 나머지는 무음 처리
                    current_freq <= 0;
                end
            endcase
            
            // PWM 생성
            if (current_freq != 0) begin  // 무음이 아닐 때만 PWM 생성
                if (counter >= (CLOCK_FREQ/(2*current_freq))-1) begin
                    counter <= 0;
                    pwm_out <= ~pwm_out;
                end
                else begin
                    counter <= counter + 1;
                end
            end
            else begin
                pwm_out <= 0;
                counter <= 0;
            end
        end
    end
    
    // 출력 할당
    always @(*) begin
        piezo_out = pwm_out;
    end

endmodule