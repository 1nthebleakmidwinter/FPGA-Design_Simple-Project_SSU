module led_blink (
      input        i_rstn  ,
      input        i_clk   ,
      input        i_pls_1k,
      input        i_go    ,
      output [7:0] o_led_on
  );
  
  reg       r_start;
  reg [9:0] r_cnt;
  reg [7:0] r_led;
  
  always@(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn) begin
          r_start <= 1'b0;
      end
      else begin
          if(i_go) r_start <= 1'b1;
          else r_start <= 1'b0;
      end
  end
  
  always@(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn) begin
          r_cnt <= 10'd0;    
      end
      else if(r_start & i_pls_1k) begin
          if(r_cnt==10'd1000) begin
          r_cnt <= 0;
      end
      else begin
          r_cnt <= r_cnt +1;
      end    
      end
  end
  
  always@(posedge i_clk, negedge i_rstn) begin
      if(!i_rstn) begin
          r_led <= 8'b0000_0000;
      end
      else begin
          if(r_cnt==10'd1000) r_led <= 8'b1000_0000;
          else r_led <= 8'b0000_0000;
      end
  end
  
  assign o_led_on = ~r_led;
  
  endmodule