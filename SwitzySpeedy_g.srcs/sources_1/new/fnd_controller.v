`timescale 1ns / 1ps

// ============================================================================
// Module: fnd_controller
// Description: 4자리 FND를 시분할(multiplexing) 방식으로 제어합니다.
//              입력받은 데이터를 각 자리에 맞게 표시합니다.
// ============================================================================
module fnd_controller(
    input wire clk,             // 기준 클럭 (clk_1khz)
    input wire reset,           // 리셋 신호
    input wire [19:0] data_in,  // 표시할 4자리 데이터 (각 4비트씩)
                                // 예: 1234 -> 16'h1234
    output reg [3:0] fnd_an,    // FND 자리 선택 출력 (Anode, Active-Low)
    output wire [6:0] fnd_seg   // FND 세그먼트 패턴 출력 (Cathode, Active-Low)
    );

    // FND 자리 스캔을 위한 카운터
    reg [1:0] scan_counter = 0;
    // 현재 스캔 중인 자리에 표시할 5비트 데이터
    reg [4:0] data_to_decode;

    // 위에서 만든 세그먼트 디코더 모듈을 여기에 생성(instantiate)합니다.
    segment_decoder decoder (
        .data_in(data_to_decode),
        .seg_out(fnd_seg)
    );

    // 1. FND 자리 선택 로직 (클럭에 따라 순차적으로 동작)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scan_counter <= 0;
        end
        else begin
            // 0 -> 1 -> 2 -> 3 -> 0 ... 계속 순환
            scan_counter <= scan_counter + 1;
        end
    end

    // 2. 현재 자리에 맞는 데이터 선택 및 Anode 제어 (조합 논리)
    always @(*) begin
        case (scan_counter)
            2'b00: begin // 첫째 자리 (가장 오른쪽)
                fnd_an = 4'b1110;
                data_to_decode = data_in[4:0];
            end
            2'b01: begin // 둘째 자리
                fnd_an = 4'b1101;
                data_to_decode = data_in[9:5];
            end
            2'b10: begin // 셋째 자리
                fnd_an = 4'b1011;
                data_to_decode = data_in[14:10];
            end
            2'b11: begin // 넷째 자리 (가장 왼쪽)
                fnd_an = 4'b0111;
                data_to_decode = data_in[19:15];
            end
            default: begin
                fnd_an = 4'b1111; // 모든 자리 OFF
                data_to_decode = 5'd10; // 빈 칸 코드
            end
        endcase
    end

endmodule