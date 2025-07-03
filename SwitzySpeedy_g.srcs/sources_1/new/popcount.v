`timescale 1ns / 1ps

// ============================================================================
// Module: popcount
// Description: 입력된 N비트 벡터에서 '1'의 개수를 셉니다. (Population Count)
//              조합 논리로만 구성됩니다.
// ============================================================================
module popcount #(
    parameter WIDTH = 7 // 입력 데이터의 비트 수 (라운드 3의 한 그룹은 7개)
)(
    input wire [WIDTH-1:0] data_in,  // 개수를 셀 입력 데이터
    output wire [3:0] count_out      // '1'의 개수 결과 (최대 7까지 표현 가능)
    );

    // Verilog에서 각 비트를 더하면 합성 툴이 알아서 효율적인 덧셈 회로로 만들어줍니다.
    assign count_out = data_in[0] + data_in[1] + data_in[2] + data_in[3] + 
                       data_in[4] + data_in[5] + data_in[6];

endmodule
