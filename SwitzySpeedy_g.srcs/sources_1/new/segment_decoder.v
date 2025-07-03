`timescale 1ns / 1ps

// ============================================================================
// Module: segment_decoder
// Description: 4비트 코드 값을 입력받아 7세그먼트 디스플레이용 패턴으로 변환합니다.
//              (Active-Low 방식: 0일 때 해당 세그먼트가 켜짐)
//
//              7-segment map:
//                  --a--
//                 |     |
//                 f     b
//                 |     |
//                  --g--
//                 |     |
//                 e     c
//                 |     |
//                  --d--
// ============================================================================
module segment_decoder(
    input wire [4:0] data_in,   // 5비트 데이터 코드 입력
    output reg [6:0] seg_out    // 7세그먼트 출력 패턴 (g,f,e,d,c,b,a 순서)
    );

    // 특수 문자 코드 정의
    localparam C_BLANK = 5'd10, C_O = 5'd11, C_X = 5'd12, C_DASH = 5'd13,
               C_G = 5'd14, C_L = 5'd15, C_E = 5'd16;
               
    // 애니메이션용 코드
    localparam C_ANIM_A = 5'd17, C_ANIM_B = 5'd18, C_ANIM_C = 5'd19,
               C_ANIM_D = 5'd20, C_ANIM_E = 5'd21, C_ANIM_F = 5'd22, C_d = 5'd23;

    always @(*) begin
        case (data_in)
            // [수정] 숫자 표현을 5비트로 통일
            5'd0: seg_out = 7'b1000000; // 0
            5'd1: seg_out = 7'b1111001; // 1
            5'd2: seg_out = 7'b0100100; // 2
            5'd3: seg_out = 7'b0110000; // 3
            5'd4: seg_out = 7'b0011001; // 4
            5'd5: seg_out = 7'b0010010; // 5 (S)
            5'd6: seg_out = 7'b0000010; // 6
            5'd7: seg_out = 7'b1111000; // 7
            5'd8: seg_out = 7'b0000000; // 8
            5'd9: seg_out = 7'b0010000; // 9
            // 특수 문자
            C_BLANK: seg_out = 7'b1111111;
            C_O:     seg_out = 7'b0100011;
            C_X:     seg_out = 7'b0001001;
            C_DASH:  seg_out = 7'b0111111;
            C_G:     seg_out = 7'b1001110;
            C_L:     seg_out = 7'b1000111;
            C_E:     seg_out = 7'b0000110;
            C_d:     seg_out = 7'b0100001;
            // [수정] 누락된 애니메이션 코드 패턴 모두 추가
            // Active-Low 이므로 해당 비트만 0으로 만들어 켭니다. (g,f,e,d,c,b,a)
            C_ANIM_A: seg_out = 7'b1111110; // a
            C_ANIM_B: seg_out = 7'b1111101; // b
            C_ANIM_C: seg_out = 7'b1111011; // c
            C_ANIM_D: seg_out = 7'b1110111; // d
            C_ANIM_E: seg_out = 7'b1101111; // e
            C_ANIM_F: seg_out = 7'b1011111; // f
            default: seg_out = 7'b1111111;
        endcase
    end

endmodule