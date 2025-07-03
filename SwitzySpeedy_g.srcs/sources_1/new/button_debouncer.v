`timescale 1ns / 1ps

// ============================================================================
// Module: button_debouncer
// Description: 버튼 입력의 기계적 노이즈(채터링)를 제거하여 깨끗한 단일 펄스 신호를 출력합니다.
// ============================================================================
module button_debouncer(
    input wire clk,       // 기준 클럭 (예: clock_divider에서 만든 clk_1khz)
    input wire reset,     // 리셋 신호
    input wire btn_in,    // 물리적인 버튼의 불안정한 입력 신호
    output reg btn_pulse  // 안정화된 단일 펄스 출력
    );

    // 디바운싱을 위한 내부 상태 정의
    localparam S_IDLE = 2'b00;    // 버튼 입력 대기 상태
    localparam S_CHECK = 2'b01;   // 버튼이 눌린 것을 확인하고 노이즈가 끝날 때까지 기다리는 상태
    localparam S_PRESSED = 2'b10; // 버튼이 확실히 눌렸음을 확정하고, 떼기를 기다리는 상태

    reg [1:0] state = S_IDLE; // 현재 상태를 저장하는 레지스터

    // 노이즈 구간을 무시하기 위한 카운터 (1kHz 클럭 기준, 약 10ms)
    localparam DEBOUNCE_LIMIT = 10; 
    reg [3:0] counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            counter <= 0;
            btn_pulse <= 0;
        end
        else begin
            btn_pulse <= 0; // 기본적으로 펄스는 0으로 유지

            case (state)
                S_IDLE: begin
                    // 버튼이 눌리면 (신호가 1이 되면) S_CHECK 상태로 변경
                    if (btn_in) begin
                        state <= S_CHECK;
                    end
                end

                S_CHECK: begin
                    // 버튼이 계속 눌려있으면 카운터 증가
                    if (btn_in) begin
                        if (counter == DEBOUNCE_LIMIT) begin
                            // 정해진 시간 동안 계속 눌려있었다면, 유효한 입력으로 판단
                            state <= S_PRESSED;
                            btn_pulse <= 1; // 단 한 클럭 동안만 펄스 출력!
                        end
                        else begin
                            counter <= counter + 1;
                        end
                    end
                    else begin
                        // 중간에 버튼에서 손을 떼면 노이즈로 간주하고 초기 상태로 복귀
                        state <= S_IDLE;
                        counter <= 0;
                    end
                end

                S_PRESSED: begin
                    // 버튼에서 손을 뗄 때까지(신호가 0이 될 때까지) 현재 상태 유지
                    // 이렇게 해야 버튼을 누르고 있는 동안 펄스가 계속 나가는 것을 방지
                    if (!btn_in) begin
                        state <= S_IDLE;
                        counter <= 0;
                    end
                end

                default:
                    state <= S_IDLE;
            endcase
        end
    end

endmodule
