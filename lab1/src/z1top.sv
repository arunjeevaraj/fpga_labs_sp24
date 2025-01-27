module z1top
(
  input  logic clk_i,
  input  logic rst_n_i,
  input  logic [3:0] buttons_i,
  output logic [3:0] leds_o
);
timeunit 1ns/100ps;

// 125 Mhz.. Needs to count log2(125Mhz) to hit 1 sec of toggle rate for LED.
logic  [27:0] counter_up_ff, counter_up_n;
logic  [3:0] button_toggles_o;
// select the bit of the counter, to create various delays.
logic  [2:0] counter_bit_sel_ff[0:3];
logic  [2:0] counter_bit_sel_n[0:3];
// the counter is used to create various delays.
assign counter_up_n = counter_up_ff + 1;

always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (!rst_n_i) begin
      counter_up_ff <= '0;
      for (int i = 0; i < 4; i++) begin
        counter_bit_sel_ff[i] <=  3'h4;
      end
    end else begin
      counter_up_ff <= counter_up_n;
      for (int i = 0; i < 4; i++) begin
        counter_bit_sel_ff[i] <=  counter_bit_sel_n[i];
      end
    end
end

// for debugging.
//assign leds_o = 4'(counter_bit_sel_ff[0]);
for (genvar i = 0; i < 4; i++) begin : button_capture_instances
    assign counter_bit_sel_n[i] = button_toggles_o[i] ? counter_bit_sel_ff[i] + 1 : counter_bit_sel_ff[i];
    assign leds_o[i] = counter_up_ff[20 + int'(counter_bit_sel_n[i])];
    
    button_capture u_button_capture 
    (
      .clk_i,
      .rst_n_i,
      .button_i(buttons_i[i]),
      .button_toggle_o(button_toggles_o[i])
    );
end : button_capture_instances

endmodule
