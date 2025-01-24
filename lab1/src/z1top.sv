module z1top
(
  input  logic clk_i,
  input  logic rst_n_i,
  input  logic [3:0] buttons_i,
  output logic [3:0] leds_o
);
timeunit 1ns/100ps;


logic  [16:0] counter_up_ff, counter_up_n;
assign counter_up_n = counter_up_ff + 1;
assign leds_o[3] = counter_up_ff[9];

always_ff @(posedge clk_i, negedge rst_n_i) begin
  if (!rst_n_i) begin
    counter_up_ff <= '0;
  end else begin
    counter_up_ff <= counter_up_n;
  end
end




for (genvar i = 0; i < 3; i++) begin : led_button_instances
    button_led u_button_led 
    (
      .clk_i,
      .rst_n_i,
      .button_i(buttons_i[i]),
      .led_o(leds_o[i])
    );
end : led_button_instances

endmodule
