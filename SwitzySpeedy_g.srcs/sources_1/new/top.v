`timescale 1ns / 1ps

// =================================================================================
// Module: top
// Description: SwitzySpeedy 게임의 최상위 모듈 (최종 통합 재수정 버전)
// =================================================================================
module top(
    input wire clk,
    input wire reset,
    input wire [15:0] sw,
    input wire btn_start,
    input wire btn_left,
    input wire btn_right,
    input wire btn_equal,
    output wire [15:0] led,
    output wire [3:0] fnd_an,
    output wire [6:0] fnd_seg
    );

    // ---------------------------------------------------------------------------
    // 1. 와이어 및 레지스터 선언
    // ---------------------------------------------------------------------------
    wire clk_1khz, tick_1hz;
    wire btn_start_pulse, btn_left_pulse, btn_right_pulse, btn_equal_pulse;
    wire sw15_pulse;
    reg  sw15_dly, sw15_dly2;

    localparam S_IDLE=4'd0, S_GAME_START=4'd1, S_R1_SHOW=4'd2, S_R1_INPUT=4'd3,
               S_R2_START=4'd4, S_R2_GAME=4'd5, S_R3_START=4'd6, S_R3_SHOW=4'd7,
               S_R3_INPUT=4'd8, S_TRANSITION=4'd10, S_WIN=4'd11, S_LOSE=4'd12;
    
    reg [3:0] state = S_IDLE, next_state = S_IDLE;
    reg [27:0] delay_counter, idle_anim_counter;
    reg [5:0]  round_timer;
    reg [2:0]  current_round;
    reg [7:0]  r1_pattern, r2_initial_leds;
    reg [13:0] r3_pattern;
    // reg [1:0]  r3_correct_answer; // [수정 1] 타이밍 문제 해결을 위해 reg 대신 wire로 변경
    reg is_correct;
    reg [19:0] fnd_data_reg;
    reg [15:0] led_reg;
    
    localparam R3_ANS_EQUAL=2'b00, R3_ANS_LEFT=2'b01, R3_ANS_RIGHT=2'b10;
    localparam C_BLANK=5'd10, C_O=5'd11, C_X=5'd12, C_DASH=5'd13, C_G=5'd14, C_L=5'd15, C_E=5'd16,
               C_ANIM_A=5'd17, C_ANIM_B=5'd18, C_ANIM_C=5'd19, C_ANIM_D=5'd20, C_ANIM_E=5'd21, C_ANIM_F=5'd22;
    // ---------------------------------------------------------------------------
    // 2. 하위 모듈 인스턴스화
    // ---------------------------------------------------------------------------
    clock_divider u_clk_div (.clk_100mhz(clk), .reset(reset), .clk_1khz(clk_1khz), .tick_1hz(tick_1hz));
    button_debouncer u_db_start (.clk(clk_1khz), .reset(reset), .btn_in(btn_start), .btn_pulse(btn_start_pulse));
    button_debouncer u_db_left  (.clk(clk_1khz), .reset(reset), .btn_in(btn_left),  .btn_pulse(btn_left_pulse));
    button_debouncer u_db_right (.clk(clk_1khz), .reset(reset), .btn_in(btn_right), .btn_pulse(btn_right_pulse));
    button_debouncer u_db_equal (.clk(clk_1khz), .reset(reset), .btn_in(btn_equal), .btn_pulse(btn_equal_pulse));
    fnd_controller u_fnd_ctrl (.clk(clk_1khz), .reset(reset), .data_in(fnd_data_reg), .fnd_an(fnd_an), .fnd_seg(fnd_seg));
    
    wire [7:0] rand_8bit; wire [13:0] rand_14bit;
    lfsr #(.WIDTH(8)) u_lfsr8 (.clk(clk), .reset(reset), .enable(1'b1), .rand_out(rand_8bit));
    lfsr #(.WIDTH(14)) u_lfsr14 (.clk(clk), .reset(reset), .enable(1'b1), .rand_out(rand_14bit));

    wire [3:0] r3_left_count, r3_right_count;
    popcount u_pop_left  (.data_in(r3_pattern[6:0]),   .count_out(r3_left_count));
    popcount u_pop_right (.data_in(r3_pattern[13:7]),  .count_out(r3_right_count));

    // ---------------------------------------------------------------------------
    // 3. 조합 회로 로직
    // ---------------------------------------------------------------------------
    assign sw15_pulse = ~sw15_dly2 && sw15_dly;
    
    wire [7:0] r2_toggled_leds;
    assign r2_toggled_leds[0] = r2_initial_leds[0] ^ sw[0] ^ sw[1] ^ sw[7];
    assign r2_toggled_leds[1] = r2_initial_leds[1] ^ sw[1];
    assign r2_toggled_leds[2] = r2_initial_leds[2] ^ sw[1] ^ sw[2] ^ sw[3];
    assign r2_toggled_leds[3] = r2_initial_leds[3] ^ sw[3];
    assign r2_toggled_leds[4] = r2_initial_leds[4] ^ sw[3] ^ sw[4] ^ sw[5];
    assign r2_toggled_leds[5] = r2_initial_leds[5] ^ sw[5];
    assign r2_toggled_leds[6] = r2_initial_leds[6] ^ sw[5] ^ sw[6] ^ sw[7];
    assign r2_toggled_leds[7] = r2_initial_leds[7] ^ sw[7];
    
    assign led = led_reg;

    // [수정 1] 3라운드 정답을 조합논리(wire)로 즉시 계산하여 타이밍 문제를 원천적으로 제거합니다.
    wire [1:0] r3_correct_answer = (r3_left_count > r3_right_count) ? R3_ANS_LEFT :
                                   (r3_left_count < r3_right_count) ? R3_ANS_RIGHT : R3_ANS_EQUAL;

    wire r3_player_is_correct = (btn_left_pulse  && r3_correct_answer == R3_ANS_LEFT)  ||
                              (btn_right_pulse && r3_correct_answer == R3_ANS_RIGHT) ||
                              (btn_equal_pulse && r3_correct_answer == R3_ANS_EQUAL);

    // ---------------------------------------------------------------------------
    // 4. 순차 회로 로직 (FSM 및 데이터 처리)
    // ---------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) state <= S_IDLE;
        else state <= next_state;
    end

    // 다음 상태 결정 로직 (조합회로)
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:       if (btn_start_pulse) next_state = S_GAME_START;
            S_GAME_START: if (delay_counter == 200_000_000 - 1) next_state = S_R1_SHOW;
            S_R1_SHOW:    if (delay_counter == 100_000_000 - 1) next_state = S_R1_INPUT;
            S_R1_INPUT:   if (sw15_pulse || round_timer == 0) next_state = S_TRANSITION;
            S_R2_START:   if (delay_counter == 200_000_000 - 1) next_state = S_R2_GAME;
            S_R2_GAME:    if (sw15_pulse || round_timer == 0) next_state = S_TRANSITION;
            S_R3_START:   if (delay_counter == 200_000_000 - 1) next_state = S_R3_SHOW;
            S_R3_SHOW:    if (delay_counter == 100_000_000 - 1) next_state = S_R3_INPUT;
            S_R3_INPUT:   if (btn_left_pulse || btn_right_pulse || btn_equal_pulse || round_timer == 0) next_state = S_TRANSITION;
            S_TRANSITION: begin
                if (delay_counter == 100_000_000 - 1) begin
                    if (is_correct) begin
                        if      (current_round == 1) next_state = S_R2_START;
                        else if (current_round == 2) next_state = S_R3_START;
                        else if (current_round == 3) next_state = S_WIN;
                    end else begin
                        next_state = S_LOSE;
                    end
                end
            end
            S_WIN, S_LOSE: if (delay_counter == 200_000_000 - 1) next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end
    
    // 데이터 처리 및 출력 레지스터 업데이트 (순차회로)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            delay_counter <= 0; idle_anim_counter <= 0; round_timer <= 0;
            current_round <= 0; led_reg <= 16'b0; fnd_data_reg <= 20'hAAAAA;
            is_correct <= 1'b0; sw15_dly <= 0; sw15_dly2 <= 0;
        end else begin
            // 엣지 감지 로직
            sw15_dly <= sw[15];
            sw15_dly2 <= sw15_dly;

            // 상태가 바뀔 때(State Transition) 1회만 실행되는 로직
            if (state != next_state) begin
                delay_counter <= 0;
                idle_anim_counter <= 0;
                
                if (next_state == S_TRANSITION) begin
                    if (state == S_R1_INPUT)      is_correct <= (round_timer > 0) && (sw[7:0] == r1_pattern);
                    else if (state == S_R2_GAME)  is_correct <= (round_timer > 0) && (&r2_toggled_leds);
                    else if (state == S_R3_INPUT) begin
                        if (round_timer > 0 && r3_player_is_correct) begin
                            is_correct <= 1'b1;
                        end else begin
                            is_correct <= 1'b0;
                        end
                    end
                end

                // FND 및 라운드 데이터 설정
                case (next_state)
                    S_IDLE:       begin current_round <= 0; end
                    S_GAME_START: begin fnd_data_reg <= {C_DASH,C_DASH,C_DASH,C_DASH}; end
                    S_R1_SHOW:    begin current_round <= 1; r1_pattern <= rand_8bit; round_timer <= 3; end
                    S_R2_START:   begin fnd_data_reg <= {C_DASH,C_DASH,C_DASH,C_DASH}; end
                    S_R2_GAME:    begin current_round <= 2; r2_initial_leds <= rand_8bit; round_timer <= 15; end
                    S_R3_START:   begin fnd_data_reg <= {C_DASH,C_DASH,C_DASH,C_DASH}; end
                    S_R3_SHOW:    begin current_round <= 3; r3_pattern <= rand_14bit; round_timer <= 3; end
                    S_TRANSITION: begin 
                        if ( (state == S_R1_INPUT && (round_timer > 0) && (sw[7:0] == r1_pattern)) || 
                             (state == S_R2_GAME  && (round_timer > 0) && (&r2_toggled_leds))    ||
                             (state == S_R3_INPUT && (round_timer > 0) && r3_player_is_correct) ) begin
                            fnd_data_reg <= {C_BLANK,C_O,C_O,C_BLANK};
                        end else begin
                            fnd_data_reg <= {C_BLANK,C_X,C_X,C_BLANK};
                        end
                    end
                    S_WIN:        begin fnd_data_reg <= {C_G,C_O,C_O,C_DASH}; end
                    S_LOSE:       begin fnd_data_reg <= {C_L,C_O,5'd5,C_E}; end
                    default:      begin end
                endcase
            end 
            // 상태가 유지되는 동안(State Stable) 계속 실행되는 로직
            else begin
                delay_counter <= delay_counter + 1;
                
                // [수정 2] 대기 상태가 아닐 때만 LD15가 SW15를 따라 토글되도록 수정
                if (state != S_IDLE) begin
                    led_reg[15] <= sw[15];
                end else begin
                    led_reg[15] <= 1'b0;
                end
                
                // LED 출력 업데이트
                case(state)
                    S_IDLE:      led_reg[14:0] <= 15'b0;
                    S_R1_SHOW:   led_reg[7:0] <= r1_pattern;
                    S_R2_GAME:   led_reg[7:0] <= r2_toggled_leds;
                    S_R3_SHOW:   led_reg[14:1] <= r3_pattern;
                    default:     led_reg[14:0] <= 15'b0;
                endcase

                // FND 및 타이머 업데이트
                case(state)
                    S_IDLE: begin
                        idle_anim_counter <= idle_anim_counter + 1;
                        case (idle_anim_counter[26:23])
                            4'd0: fnd_data_reg <= {C_ANIM_A, C_BLANK, C_BLANK, C_BLANK}; 4'd1: fnd_data_reg <= {C_BLANK, C_ANIM_A, C_BLANK, C_BLANK};
                            4'd2: fnd_data_reg <= {C_BLANK, C_BLANK, C_ANIM_A, C_BLANK}; 4'd3: fnd_data_reg <= {C_BLANK, C_BLANK, C_BLANK, C_ANIM_A};
                            4'd4: fnd_data_reg <= {C_BLANK, C_BLANK, C_BLANK, C_ANIM_B}; 4'd5: fnd_data_reg <= {C_BLANK, C_BLANK, C_BLANK, C_ANIM_C};
                            4'd6: fnd_data_reg <= {C_BLANK, C_BLANK, C_BLANK, C_ANIM_D}; 4'd7: fnd_data_reg <= {C_BLANK, C_BLANK, C_ANIM_D, C_BLANK};
                            4'd8: fnd_data_reg <= {C_BLANK, C_ANIM_D, C_BLANK, C_BLANK}; 4'd9: fnd_data_reg <= {C_ANIM_D, C_BLANK, C_BLANK, C_BLANK};
                            4'd10:fnd_data_reg <= {C_ANIM_E, C_BLANK, C_BLANK, C_BLANK}; 4'd11:fnd_data_reg <= {C_ANIM_F, C_BLANK, C_BLANK, C_BLANK};
                            default: fnd_data_reg <= {C_BLANK,C_BLANK,C_BLANK,C_BLANK};
                        endcase
                    end
                    S_R1_INPUT, S_R2_GAME, S_R3_INPUT: begin
                        if(tick_1hz && round_timer > 0) round_timer <= round_timer - 1;
                        fnd_data_reg[19:10] <= {C_BLANK, C_BLANK};
                        fnd_data_reg[9:5]  <= round_timer / 10;
                        fnd_data_reg[4:0]  <= round_timer % 10;
                    end
                    default: begin end
                endcase
            end
        end
    end
endmodule