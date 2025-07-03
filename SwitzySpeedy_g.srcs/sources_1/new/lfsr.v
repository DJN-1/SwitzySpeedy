`timescale 1ns / 1ps

// ============================================================================
// Module: lfsr
// Description: LFSR을 이용한 의사 난수 생성기입니다.
//              parameter를 통해 비트 수를 조절할 수 있습니다.
// ============================================================================
module lfsr #(
    parameter WIDTH = 8 // 기본 비트 수를 8로 설정
)(
    input wire clk,       // 기준 클럭
    input wire reset,     // 리셋 신호
    input wire enable,    // `1`일 때만 새로운 난수 생성

    output wire [WIDTH-1:0] rand_out // 생성된 난수 출력
    );

    reg [WIDTH-1:0] lfsr_reg;
    wire feedback;

    // LFSR은 반드시 0이 아닌 값으로 시작해야 합니다.
    // 리셋 시 모든 비트를 1로 설정하여 0에 갇히는 것을 방지합니다.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr_reg <= {WIDTH{1'b1}}; // 모든 비트를 1로 초기화
        end
        else if (enable) begin
            lfsr_reg <= {lfsr_reg[WIDTH-2:0], feedback}; // 왼쪽으로 시프트하며 새 비트 삽입
        end
    end

    // WIDTH 값에 따라 다른 피드백 로직(XOR 탭)을 사용합니다.
    // 이는 생성되는 수열의 품질을 결정하는 중요한 부분입니다.
    generate
        if (WIDTH == 8) begin
            // 8-bit LFSR 표준 탭: [8,6,5,4]
            assign feedback = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3];
        end
        else if (WIDTH == 14) begin
            // 14-bit LFSR 표준 탭: [14,13,11,9]
            assign feedback = lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10] ^ lfsr_reg[8];
        end
        else begin // 기본 피드백 로직 (다른 WIDTH 값에 대해)
            assign feedback = lfsr_reg[WIDTH-1] ^ lfsr_reg[WIDTH-2];
        end
    endgenerate
    
    assign rand_out = lfsr_reg;

endmodule
