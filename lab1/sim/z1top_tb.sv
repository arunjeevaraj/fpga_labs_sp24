module z1top_tb;
timeunit 1ns/100ps;

  logic tb_clk;
  logic tb_rst_n;
  logic [3:0] tb_buttons;
  logic [3:0] tb_leds;


  initial begin : clock_gen
    tb_clk = 0;
    while (1) begin
        #5ns tb_clk = !tb_clk;
    end
  end : clock_gen

 initial begin : reset_gen
    tb_rst_n = 0;
    repeat (5) begin
        @(negedge tb_clk);
    end
    tb_rst_n = 1;
 end : reset_gen

// design
z1top u_dut (.clk_i(tb_clk),
     .rst_n_i(tb_rst_n),
     .leds_o(tb_leds),
     .buttons_i(tb_buttons));


// test run
initial begin : test
    tb_buttons = '0;
     @(posedge tb_rst_n); // wait for reset to de-assert

    repeat (500) begin 
        repeat (5) begin
            @(negedge tb_clk);
        end
            tb_buttons = 1;
        repeat (5) begin
            @(negedge tb_clk);
        end
            tb_buttons = 0;
    end
    $finish();
end :test

endmodule;