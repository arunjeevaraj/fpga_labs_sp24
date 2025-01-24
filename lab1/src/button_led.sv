module button_led
(
    input  logic clk_i,
    input  logic rst_n_i,
    output logic led_o,
    input  logic button_i
);
timeunit 1ns/100ps;

  logic button_ff[0:2];
  logic led_ff, led_n;

  logic button_pressed, button_not_pressed;
  logic[7:0] timer_guard_n, timer_guard_ff;
  logic led_toggle;

  logic button_p_edge;
  logic button_n_edge;

  typedef enum logic[1:0] {st_idle, st_button_pressed, st_guard, st_button_deasserted } state_t;
  state_t c_state, n_state;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i== 0) begin
        button_ff      <= '{default:'0};
        led_ff         <= '1;
        timer_guard_ff  <= '1;
        c_state         <= st_idle;
    end else begin
        button_ff      <= {button_i, button_ff[0:1]};
        led_ff         <= led_n;
        timer_guard_ff  <= timer_guard_n;
        c_state         <= n_state;
    end
  end

  assign button_p_edge = button_ff[0] & !button_ff[1] & !button_ff[2];
  assign button_n_edge = !button_ff[0] & button_ff[1] & button_ff[2];
  assign button_pressed =  (button_ff[0] | button_ff[1]) | button_ff[2];
  assign button_not_pressed =  (!button_ff[0] | !button_ff[1]) | !button_ff[2];
  assign led_o = led_ff;
  assign led_n = led_toggle ^ led_ff;

  always_comb begin : state_machine
    led_toggle = 0;
    timer_guard_n = timer_guard_ff;
    case (c_state)
    st_idle: begin
        timer_guard_n = '0;
        n_state = st_idle;
        if (button_p_edge) begin
            n_state = st_button_pressed;
        end
    end
    st_button_pressed: begin
        n_state = st_button_pressed;
        if (timer_guard_ff == '0) begin
            if (button_pressed)
                timer_guard_n = timer_guard_ff + 1;
            else 
                timer_guard_n = timer_guard_ff;
        end else begin
            timer_guard_n = timer_guard_ff +1;
            if (timer_guard_ff == '1) begin
                n_state = st_guard;
            end
        end
    end
    st_guard : begin
        n_state = st_guard;
        if (button_n_edge) begin
            n_state = st_button_deasserted;
        end
    end
    st_button_deasserted : begin
        n_state = st_button_deasserted;
        if (timer_guard_ff == '0) begin
            if (button_not_pressed)
                timer_guard_n = timer_guard_ff + 1;
            else 
                timer_guard_n = timer_guard_ff;
        end else begin
            timer_guard_n = timer_guard_ff +1;
            if (timer_guard_ff == '1) begin
                n_state = st_idle;
                led_toggle = 1;
            end
        end
    end
    default: begin
        n_state = st_idle;
    end
    endcase
  end : state_machine
endmodule : button_led