module ClockDivider (
    input wire clk_50M,      // 50MHz input clock
    input wire rst,          // Reset signal
    output reg clk_1M,       // 1MHz clock
    output reg clk_1k,       // 1kHz clock
    output reg clk_500Hz      // 50Hz clock
);

    // Counter registers
    // 50MHz -> 1MHz : divide by 50
    reg [5:0] counter_1M;    // 6 bits for counting to 50
    // 1MHz -> 1kHz : divide by 1000
    reg [9:0] counter_1k;    // 10 bits for counting to 1000
    // 1kHz -> 500Hz : divide by 2
    reg [0:0] counter_500Hz; // 1 bit for counting to 2 (changed from 5 bits)

    // Counter limits
    parameter COUNT_1M = 6'd49;     // 50MHz/1MHz = 50
    parameter COUNT_1K = 10'd999;   // 1MHz/1kHz = 1000
    parameter COUNT_500HZ = 1'd1;   // 1kHz/500Hz = 2 (changed from 19)

    // 1MHz clock generation
    always @(posedge clk_50M or posedge rst) begin
        if (rst) begin
            counter_1M <= 0;
            clk_1M <= 0;
        end
        else begin
            if (counter_1M == COUNT_1M) begin
                counter_1M <= 0;
                clk_1M <= ~clk_1M;
            end
            else begin
                counter_1M <= counter_1M + 1;
            end
        end
    end

    // 1kHz clock generation
    always @(posedge clk_1M or posedge rst) begin
        if (rst) begin
            counter_1k <= 0;
            clk_1k <= 0;
        end
        else begin
            if (counter_1k == COUNT_1K) begin
                counter_1k <= 0;
                clk_1k <= ~clk_1k;
            end
            else begin
                counter_1k <= counter_1k + 1;
            end
        end
    end

    // 500Hz clock generation (changed from 50Hz)
    always @(posedge clk_1k or posedge rst) begin
        if (rst) begin
            counter_500Hz <= 0;
            clk_500Hz <= 0;
        end
        else begin
            if (counter_500Hz == COUNT_500HZ) begin
                counter_500Hz <= 0;
                clk_500Hz <= ~clk_500Hz;
            end
            else begin
                counter_500Hz <= counter_500Hz + 1;
            end
        end
    end

endmodule