`timescale 1ns / 1ps

// ============================================================================
// Module: clock_divider
// Description: 100MHz 시스템 클럭을 입력받아 1kHz 클럭과 1Hz 펄스를 생성합니다.
// ============================================================================
module clock_divider(
    input wire clk_100mhz, // Basys3 보드의 100MHz 클럭 입력
    input wire reset,      // 리셋 신호

    output reg clk_1khz,   // FND 디스플레이 제어용 1kHz 클럭 출력
    output reg tick_1hz    // 게임 타이머용 1Hz 펄스 출력
    );

    // 1kHz 클럭 생성을 위한 카운터 (100MHz / 100,000 = 1kHz)
    // 50% 듀티 사이클을 위해 50,000마다 토글
    localparam COUNT_1KHZ = 50000; 
    reg [15:0] counter_1khz = 0;

    // 1Hz 펄스 생성을 위한 카운터 (100MHz / 100,000,000 = 1Hz)
    localparam COUNT_1HZ = 100000000;
    reg [26:0] counter_1hz = 0;


    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            // 리셋 시 모든 카운터와 출력 초기화
            counter_1khz <= 0;
            clk_1khz <= 0;
            counter_1hz <= 0;
            tick_1hz <= 0;
        end
        else begin
            // --- 1kHz 클럭 생성 로직 ---
            if (counter_1khz == COUNT_1KHZ - 1) begin
                counter_1khz <= 0;
                clk_1khz <= ~clk_1khz; // 카운터가 가득 차면 클럭 상태를 반전 (토글)
            end
            else begin
                counter_1khz <= counter_1khz + 1;
            end

            // --- 1Hz 펄스 생성 로직 ---
            tick_1hz <= 0; // 평소에는 0을 유지
            if (counter_1hz == COUNT_1HZ - 1) begin
                counter_1hz <= 0;
                tick_1hz <= 1; // 1초가 되는 정확한 한 클럭 사이클 동안만 1이 됨
            end
            else begin
                counter_1hz <= counter_1hz + 1;
            end
        end
    end

endmodule
