module z1top(
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);

  logic[3:0] buttons_ff;
  
  and(LEDS[0], BUTTONS[0], SWITCHES[0]);
  assign LEDS[5:1] = 0;
endmodule