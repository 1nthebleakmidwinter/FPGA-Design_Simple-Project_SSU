module disp_cal (
      input         i_rstn      ,
      input         i_clk       ,
      input         i_pls_1k    ,
      input         i_key_valid ,
      input         i_start     ,
      input  [ 4:0] i_bcd_data  ,
      output [31:0] o_bcd8d     ,
      output        o_fin       ,
      output [3:0]  o_led_op    ,
      output        buzzer
  );
  wire [3:0] w_digit_1, w_digit_2, w_digit_3, w_digit_4,
             w_digit_5, w_digit_6, w_digit_7, w_digit_8;
  wire [5:0] w_sec;
  wire [5:0] w_min;
  wire [6:0] w_hour;
  wire [4:0] w_month;
  wire [5:0] w_day;
  reg sel1, sel2, sel3, sel4, sel5, sel6, sel7, sel8;
  
  //timer start
  reg r_start_d1;
  reg r_start_d2;
  reg r_start_d3;
  reg r_start;
  reg r_start_en;
  
  reg set_min;
  reg set_hour;
  reg set_sec;
  reg set_day;
  reg set_month;
  reg next;
  reg next2;
  
  reg [31:0] num1;
  reg [31:0] num2;
  reg [1:0] operand;
  reg [53:0] result;
  
  reg [1:0] mode;
  reg [4:0] r_month;
  reg [5:0] r_day;
  reg [5:0] r_hour;
  reg [6:0] r_min;
  reg [5:0] r_cnt_sec;
  reg [26:0] r_time_sec;
  reg        r_fin;
  reg        r_fin_d;
  reg stop;
  reg r_buzzer;
  
  initial begin
    mode <= 2'd0;
    r_cnt_sec <= 6'd0;
    r_time_sec <= 27'd0;
    r_fin      <= 1'b0;
    r_day <= 5'd1;
    r_month <= 4'd1;
    r_hour <= 5'd0;
    r_min <= 6'd0;
    r_buzzer <= 1'b0;
    num1 <= 32'd0;
    num2 <= 32'd0;
    next <= 1'b0;
    next2 <= 1'b0;
    set_min <= 1'b0;
    set_hour <= 1'b0;
    set_day<=1'b0;
    set_month<=1'b0;
    set_sec<=1'b0;
     
    sel1 <= 1'b0;
    sel2 <= 1'b0;
    sel3 <= 1'b0;
    sel4 <= 1'b0;
    sel5 <= 1'b0;
    sel6 <= 1'b0;
    sel7 <= 1'b0;
    sel8 <= 1'b0;
  end
  
  always@(posedge i_clk, negedge i_rstn) begin   //지연
      if(!i_rstn) begin
          r_start_d1 <= 1'b1;
          r_start_d2 <= 1'b1;
          r_start_d3 <= 1'b1;
      end
      else begin
          r_start_d1 <= i_start;
          r_start_d2 <= r_start_d1;
          r_start_d3 <= r_start_d2;
      end
  end
  //r_start_en 1 : timer playing
  //r_start_en 0 : timer stop 
  
  always@(posedge i_clk, negedge i_rstn) begin 
      if(!i_rstn) begin
          r_start_en <= 1'b0;
          r_start    <= 1'b0;
      end
      else begin
	  //rising edge detect
          if(r_start_d2 & (!r_start_d3) ) begin 
             r_start_en <= ~r_start_en;
             r_start    <= 1'b1;
          end
          else if (stop) begin
            r_start_en <= 1'b0;
            r_start    <= 1'b0;
          end
      end
  end    
  
  always@(posedge i_clk, negedge i_rstn) begin
      if(mode == 2'd0) begin
        if(!i_rstn) begin
            r_cnt_sec <= 6'd0;
            r_time_sec <= 27'd0;
            r_fin      <= 1'b0;
            r_day <= 5'd1;
            r_month <= 4'd1;
            r_hour <= 5'd0;
            r_min <= 6'd0;
            
            sel1 <= 1'b0;
            sel2 <= 1'b0;
            sel3 <= 1'b0;
            sel4 <= 1'b0;
            sel5 <= 1'b0;
            sel6 <= 1'b0;
            sel7 <= 1'b0;
            sel8 <= 1'b0;
        end
        else if (i_key_valid & (!r_start_en) & (!set_month & !set_day & !set_hour & !set_min)) begin  //r_start_en 이 0일 경우 r_cnt_sec 에 sec 값 셋팅 ;
            if(i_bcd_data==5'h10) begin
                sel1 <= 1'b1;
                sel2 <= 1'b1;
                r_min <= 6'd0;     
                set_min <= 1'b1;
            end
            else if(i_bcd_data==5'h11) begin 
                sel3 <= 1'b1;
                sel4 <= 1'b1;
                r_hour <= 5'd0;
                set_hour <= 1'b1;
            end
            else if(i_bcd_data==5'h12 & !(r_month == 4'd0)) begin 
                sel5 <= 1'b1;
                sel6 <= 1'b1;
                r_day <= 5'd0;
                set_day <= 1'b1;
            end
            else if(i_bcd_data==5'h13) begin
                sel7 <= 1'b1;
                sel8 <= 1'b1;
                r_month <= 4'd0;
                r_day <= 5'd1; 
                set_month <= 1'b1;
            end

            else if(i_bcd_data==5'h18) begin
                mode <= 2'd1;
                r_cnt_sec <= 6'd0;
                r_min <= 6'd0;
                r_hour <= 5'd0;
            end
            else if(i_bcd_data==5'h17) begin
                mode <= 2'd2;
                num1<=32'd0;
                num2<=32'd0;
                result<=54'd0;
                next<=1'b0;
                next2<=1'b0;
            end
            
          //time set -> timer counter reset
            r_fin <= 1'b0;
            r_time_sec <= 27'd0;
        end
      
        else if (i_key_valid & (!r_start_en) & set_month) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_month <= r_month+4'd0;
                  next <= 1'b1;
                  sel8 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_month <= r_month+4'd10;
                  next <= 1'b1;
                  sel8 <= 1'b0;
              end
          end
          else begin
              if(i_bcd_data==5'h0) begin
                  r_month <= r_month+4'd0;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_month <= r_month+4'd1;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_month <= r_month+4'd2;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h3 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd3;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h4 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd4;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h5 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd5;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h6 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd6;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h7 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd7;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h8 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd8;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
              else if(i_bcd_data==5'h9 & !(r_month / 10 == 1)) begin
                  r_month <= r_month+4'd9;
                  next <= 1'b0;
                  set_month <= 1'b0;
                  sel7 <= 1'b0;
              end
            end
        end      
      
        else if (i_key_valid & (!r_start_en) & set_day) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_day <= r_day+5'd0;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_day <= r_day+5'd10;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_day <= r_day+5'd20;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
              else if(i_bcd_data==5'h3 & !(r_month == 4'd2)) begin
                  r_day <= r_day+5'd30;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
            end
            else begin
              if(i_bcd_data==5'h0) begin
                  r_day <= r_day+5'd0;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h1 & ((r_day / 10 <= 2) | ((r_day / 10 == 3) & (((r_month<=7) & (r_month%2 ==1)) | ((r_month>7) & (r_month%2 ==0)))))) begin
                  r_day <= r_day+5'd1;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h2 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd2;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h3 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd3;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h4 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd4;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h5 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd5;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h6 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd6;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h7 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd7;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h8 & r_day / 10 <= 2) begin
                  r_day <= r_day+5'd8;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h9 & r_day / 10 <= 2 & !(r_month==2 & r_day/10==2)) begin
                  r_day <= r_day+5'd9;
                  next <= 1'b0;
                  set_day <= 1'b0;
                  sel5 <= 1'b0;
              end
            end
        end      
      
        else if (i_key_valid & (!r_start_en) & set_hour) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_hour <= r_hour+5'd0;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_hour <= r_hour+5'd10;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_hour <= r_hour+5'd20;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
            end
            else begin
              if(i_bcd_data==5'h0) begin
                  r_hour <= r_hour+5'd0;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_hour <= r_hour+5'd1;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_hour <= r_hour+5'd2;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_hour <= r_hour+5'd3;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h4 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd4;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h5 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd5;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h6 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd6;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h7 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd7;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h8 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd8;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h9 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd9;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel3 <= 1'b0;
              end
            end
        end
      
        else if (i_key_valid & (!r_start_en) & set_min) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_min <= r_min+6'd0;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_min <= r_min+6'd10;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_min <= r_min+6'd20;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_min <= r_min+6'd30;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
              else if(i_bcd_data==5'h4) begin
                  r_min <= r_min+6'd40;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
              else if(i_bcd_data==5'h5) begin
                  r_min <= r_min+6'd50;
                  next <= 1'b1;
                  sel2 <= 1'b0;
              end
            end
            else begin
              if(i_bcd_data==5'h0) begin
                  r_min <= r_min+6'd0;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_min <= r_min+6'd1;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_min <= r_min+6'd2;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_min <= r_min+6'd3;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h4) begin
                  r_min <= r_min+6'd4;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h5) begin
                  r_min <= r_min+6'd5;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h6) begin
                  r_min <= r_min+6'd6;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h7) begin
                  r_min <= r_min+6'd7;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h8) begin
                  r_min <= r_min+6'd8;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
              else if(i_bcd_data==5'h9) begin
                  r_min <= r_min+6'd9;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel1 <= 1'b0;
              end
            end
        end
        else if(r_start_en) begin
          r_fin <= 1'b1;
          if(r_time_sec==27'd9999999) begin
              r_time_sec <= 27'd0;
              r_cnt_sec <= r_cnt_sec + 1;
              
              if(r_cnt_sec == 6'd59) begin
                  r_cnt_sec <= 6'd0;
                  r_min <= r_min + 6'd1;
                  
                  if(r_min==6'd59) begin
                      r_min <= 6'd0;
                      r_hour <= r_hour + 5'd1;
                    
                      if(r_hour==5'd23) begin
                          r_hour <= 5'd0;
                          r_day <= r_day + 5'd1;
                          
                          if(r_day==5'd28 & r_month==4'd2) begin
                              r_day <= 5'd1;
                              r_month <= r_month+4'd1;
                              if(r_month==4'd12)  r_month <= 4'd1;
                          end
                        
                          else if(r_day==5'd30 & ((r_month<=4'd7 & r_month%2==0) | (r_month>4'd7 & r_month%2==1))) begin
                              r_day <= 5'd1;
                              r_month <= r_month+4'd1;
                              if(r_month==4'd12)  r_month <= 4'd1;
                          end
                          
                          else if(r_day==5'd31 & ((r_month<=4'd7 & r_month%2==1) | (r_month>4'd7 & r_month%2==0))) begin
                              r_day <= 5'd1;
                              r_month <= r_month+4'd1;
                              if(r_month==4'd12)  r_month <= 4'd1;
                          end
                      end
                  end
              end
          end
          else begin
              r_time_sec <= r_time_sec + 1;
          end
        end
        else if(!r_start_en) begin
          r_time_sec <= 27'd0;
          r_fin <= 1'b0;
        end
      end
      
      else if(mode == 2'd1) begin
        if(!i_rstn) begin
            r_cnt_sec <= 6'd0;
            r_time_sec <= 27'd0;
            r_hour <= 5'd0;
            r_min <= 6'd0;
            r_buzzer <= 1'b0;
            
            sel1 <= 1'b0;
            sel2 <= 1'b0;
            sel3 <= 1'b0;
            sel4 <= 1'b0;
            sel5 <= 1'b0;
            sel6 <= 1'b0;
            sel7 <= 1'b0;
            sel8 <= 1'b0;
        end
        else if(i_key_valid & (!r_start_en) & (!set_hour & !set_min & !set_sec)) begin
            if(i_bcd_data==5'h10) begin
                sel1 <= 1'b1;
                sel2 <= 1'b1;
                r_cnt_sec <= 6'd0;     
                set_sec <= 1'b1;
            end
            else if(i_bcd_data==5'h11) begin 
                sel3 <= 1'b1;
                sel4 <= 1'b1;
                r_min <= 6'd0;
                set_min <= 1'b1;
            end
            else if(i_bcd_data==5'h12) begin
                sel5 <= 1'b1;
                sel6 <= 1'b1;
                r_hour <= 5'd0;
                set_hour <= 1'b1;
            end
            
            else if(i_bcd_data==5'h19) begin
                mode <= 2'd0;
                r_hour <= 5'd0;
                r_min <= 6'd0;
                r_cnt_sec <= 6'd0;
            end
            else if(i_bcd_data==5'h17) begin
                mode <= 2'd2;
                num1<=32'd0;
                num2<=32'd0;
                result<=54'd0;
                next<=1'b0;
                next2<=1'b0;
            end
            
        end
        else if (i_key_valid & (!r_start_en) & set_hour) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_hour <= r_hour+5'd0;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_hour <= r_hour+5'd10;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_hour <= r_hour+5'd20;
                  next <= 1'b1;
                  sel6 <= 1'b0;
              end
            end
            else begin
              if(i_bcd_data==5'h0) begin
                  r_hour <= r_hour+5'd0;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_hour <= r_hour+5'd1;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_hour <= r_hour+5'd2;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_hour <= r_hour+5'd3;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h4 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd4;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h5 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd5;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h6 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd6;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h7 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd7;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h8 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd8;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
              else if(i_bcd_data==5'h9 & r_hour / 10 < 2) begin
                  r_hour <= r_hour+5'd9;
                  next <= 1'b0;
                  set_hour <= 1'b0;
                  sel5 <= 1'b0;
              end
            end
        end
        
        else if(i_key_valid & !r_start_en & set_sec) begin
            if(!next) begin
                if(i_bcd_data==5'h0) begin
                    r_cnt_sec <= r_cnt_sec+6'd0;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
                else if(i_bcd_data==5'h1) begin
                    r_cnt_sec <= r_cnt_sec+6'd10;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
                else if(i_bcd_data==5'h2) begin
                    r_cnt_sec <= r_cnt_sec+6'd20;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
                else if(i_bcd_data==5'h3) begin
                    r_cnt_sec <= r_cnt_sec+6'd30;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
                else if(i_bcd_data==5'h4) begin
                    r_cnt_sec <= r_cnt_sec+6'd40;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
                else if(i_bcd_data==5'h5) begin
                    r_cnt_sec <= r_cnt_sec+6'd50;
                    next <= 1'b1;
                    sel2 <= 1'b0;
                end
            end
            else begin
                if(i_bcd_data==5'h0) begin
                  r_cnt_sec <= r_cnt_sec+6'd0;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h1) begin
                  r_cnt_sec <= r_cnt_sec+6'd1;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h2) begin
                  r_cnt_sec <= r_cnt_sec+6'd2;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h3) begin
                  r_cnt_sec <= r_cnt_sec+6'd3;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h4) begin
                  r_cnt_sec <= r_cnt_sec+6'd4;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h5) begin
                  r_cnt_sec <= r_cnt_sec+6'd5;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h6) begin
                  r_cnt_sec <= r_cnt_sec+6'd6;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h7) begin
                  r_cnt_sec <= r_cnt_sec+6'd7;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h8) begin
                  r_cnt_sec <= r_cnt_sec+6'd8;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
                else if(i_bcd_data==5'h9) begin
                  r_cnt_sec <= r_cnt_sec+6'd9;
                  next <= 1'b0;
                  set_sec <= 1'b0;
                  sel1 <= 1'b0;
                end
            end
        end
        
        else if (i_key_valid & (!r_start_en) & set_min) begin
            if(!next) begin
              if(i_bcd_data==5'h0) begin
                  r_min <= r_min+6'd0;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_min <= r_min+6'd10;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_min <= r_min+6'd20;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_min <= r_min+6'd30;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h4) begin
                  r_min <= r_min+6'd40;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
              else if(i_bcd_data==5'h5) begin
                  r_min <= r_min+6'd50;
                  next <= 1'b1;
                  sel4 <= 1'b0;
              end
            end
            else begin
              if(i_bcd_data==5'h0) begin
                  r_min <= r_min+6'd0;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h1) begin
                  r_min <= r_min+6'd1;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h2) begin
                  r_min <= r_min+6'd2;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h3) begin
                  r_min <= r_min+6'd3;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h4) begin
                  r_min <= r_min+6'd4;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h5) begin
                  r_min <= r_min+6'd5;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h6) begin
                  r_min <= r_min+6'd6;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h7) begin
                  r_min <= r_min+6'd7;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h8) begin
                  r_min <= r_min+6'd8;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
              else if(i_bcd_data==5'h9) begin
                  r_min <= r_min+6'd9;
                  next <= 1'b0;
                  set_min <= 1'b0;
                  sel3 <= 1'b0;
              end
            end
        end
        else if(r_start_en) begin
          if(!stop) begin
              if(r_time_sec==27'd9999999 & !(r_hour == 5'd0 & r_min == 6'd0 & r_cnt_sec == 6'd0)) begin
                  r_time_sec <= 27'd0;
                  r_cnt_sec <= r_cnt_sec - 1;
                  
                  if(r_cnt_sec == 6'd0 & (!(r_hour==5'd0) | !(r_min==6'd0))) begin
                      r_cnt_sec <= 6'd59;
                      r_min <= r_min - 6'd1;
                      
                      if(r_min==6'd0) begin
                          r_min <= 6'd59;
                          r_hour <= r_hour - 5'd1;
                      end
                  end
                  
                  else if(r_hour == 5'd0 & r_min == 6'd0 & r_cnt_sec == 6'd1) begin
                    stop <= 1'b1;
                    r_buzzer <= 1'b1;
                  end
              end
              else if(r_hour == 5'd0 & r_min == 6'd0 & r_cnt_sec == 6'd0) begin
                stop <= 1'b1;
                r_buzzer <= 1'b1;
              end
              else begin
                  r_time_sec <= r_time_sec + 1;
              end
            end
          end
        else if(!r_start_en) begin
          r_time_sec <= 27'd0;
          r_buzzer <= 1'b0;
          stop <= 1'b0;
        end
      end
      
      else if(mode == 2'd2) begin
        if(!i_rstn) begin
            num1 <= 32'd0;
            num2 <= 32'd0;
            result <= 54'd0;
            next <= 2'b0;
            next2 <= 2'b0;
        end
        else if(num1 > 32'd99999999 | num2 > 32'd99999999 | result > 54'd99999999) mode <= 2'd3;
        else if(i_key_valid & !next) begin
            if(i_bcd_data==5'h0) begin
                num1 <= num1*10 + 32'd0;
            end
            else if(i_bcd_data==5'h1) begin
                num1 <= num1*10 + 32'd1;
            end
            else if(i_bcd_data==5'h2) begin
                num1 <= num1*10 + 32'd2;
            end
            else if(i_bcd_data==5'h3) begin
                num1 <= num1*10 + 32'd3;
            end
            else if(i_bcd_data==5'h4) begin
                num1 <= num1*10 + 32'd4;
            end
            else if(i_bcd_data==5'h5) begin
                num1 <= num1*10 + 32'd5;
            end
            else if(i_bcd_data==5'h6) begin
                num1 <= num1*10 + 32'd6;
            end
            else if(i_bcd_data==5'h7) begin
                num1 <= num1*10 + 32'd7;
            end
            else if(i_bcd_data==5'h8) begin
                num1 <= num1*10 + 32'd8;
            end
            else if(i_bcd_data==5'h9) begin
                num1 <= num1*10 + 32'd9;
            end
            
            else if(i_bcd_data == 5'h13) begin
                operand <= 2'd0; //+
                next <= 1'b1;
            end
            else if(i_bcd_data == 5'h12) begin
                operand <= 2'd1; //-
                next <= 1'b1;
            end
            else if(i_bcd_data == 5'h11) begin
                operand <= 2'd2; //x
                next <= 1'b1;
            end
            else if(i_bcd_data == 5'h10) begin
                operand <= 2'd3; //%
                next <= 1'b1;
            end
            else if(i_bcd_data==5'h19) begin
                mode <= 2'd0;
                r_hour <= 5'd0;
                r_min <= 6'd0;
                r_cnt_sec <= 6'd0;
            end
            else if(i_bcd_data==5'h18) begin
                mode <= 2'd1;
                r_cnt_sec <= 6'd0;
                r_min <= 6'd0;
                r_hour <= 5'd0;
            end
        end
  
        else if(i_key_valid & next) begin
            if(i_bcd_data==5'h0 & !next2) begin
                num2 <= num2*10 + 32'd0;
            end
            else if(i_bcd_data==5'h1 & !next2) begin
                num2 <= num2*10 + 32'd1;
            end
            else if(i_bcd_data==5'h2 & !next2) begin
                num2 <= num2*10 + 32'd2;
            end
            else if(i_bcd_data==5'h3 & !next2) begin
                num2 <= num2*10 + 32'd3;
            end
            else if(i_bcd_data==5'h4 & !next2) begin
                num2 <= num2*10 + 32'd4;
            end
            else if(i_bcd_data==5'h5 & !next2) begin
                num2 <= num2*10 + 32'd5;
            end
            else if(i_bcd_data==5'h6 & !next2) begin
                num2 <= num2*10 + 32'd6;
            end
            else if(i_bcd_data==5'h7 & !next2) begin
                num2 <= num2*10 + 32'd7;
            end
            else if(i_bcd_data==5'h8 & !next2) begin
                num2 <= num2*10 + 32'd8;
            end
            else if(i_bcd_data==5'h9 & !next2) begin
                num2 <= num2*10 + 32'd9;
            end
            else if(i_bcd_data==5'h15) begin
                next2 <= 1'b1;
                if(operand==2'd0) begin
                    result <= num1+num2;
                end
                else if(operand==2'd1) begin
                    result <= num1-num2;
                    if (num1 < num2) mode <= 2'd3;
                end
                else if(operand==2'd2) begin
                    result <= num1*num2;
                end
                else if(operand==2'd3) begin
                    result <= num1/num2;
                    if(num1<num2) mode <= 2'd3;
                end
            end
            else if(i_bcd_data==5'h14) begin
                num1<=32'd0;
                num2<=32'd0;
                result<=54'd0;
                next<=1'b0;
                next2<=1'b0;
            end
            else if(i_bcd_data==5'h19) begin
            mode <= 2'd0;
            r_hour <= 5'd0;
            r_min <= 6'd0;
            r_cnt_sec <= 6'd0;
            end
            else if(i_bcd_data==5'h18) begin
                mode <= 2'd1;
                r_cnt_sec <= 6'd0;
                r_min <= 6'd0;
                r_hour <= 5'd0;
            end
        end
      end
      else if(mode==2'd3) begin
        if(i_key_valid) begin
            if(i_bcd_data==5'h14) begin
                mode <= 2'd2;
                num1<=32'd0;
                num2<=32'd0;
                result<=54'd0;
                next<=1'b0;
                next2<=1'b0;
            end
        end
      end
  end
    
  //hour
  assign w_hour = r_hour;
  //min
  assign w_min = r_min;
  //sec
  assign w_month = r_month;
  assign w_day = r_day;
  
  //sec
  assign w_digit_1 =
    mode==2'd3 ? 4'hd :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100-w_digit_2*10) :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100-w_digit_2*10) :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100-w_digit_2*10) :
    sel1 ? 4'ha : 
    mode == 2'd0 ? (w_min - (w_digit_2 * 10)) :
    (r_cnt_sec-(r_cnt_sec/10)*10);
  assign w_digit_2 = 
    mode==2'd3 ? 4'h0 :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100)/10 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100)/10 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000-w_digit_3*100)/10 :
    sel2 ? 4'ha : 
    mode == 2'd0 ? (w_min / 10) :
    r_cnt_sec/10;
    
  assign w_digit_3 = 
    mode==2'd3 ? 4'hd :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000)/100 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000)/100 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000-w_digit_4*1000)/100 :
    sel3 ? 4'ha : 
    mode == 2'd0 ? (w_hour - (w_digit_4 * 10)) :
    (w_min - ((w_min/10) * 10));
  assign w_digit_4 = 
    mode==2'd3 ? 4'hd :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000)/1000 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000)/1000 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000-w_digit_5*10000)/1000 :
    sel4 ? 4'ha : 
    mode == 2'd0 ? (w_hour / 10) :
    (w_min / 10);

  assign w_digit_5 = 
    mode==2'd3 ? 4'hc :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000)/10000 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000)/10000 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000-w_digit_6*100000)/10000 :
    sel5 ? 4'ha : 
    mode == 2'd0 ? (w_day - (w_digit_6 * 10)) :
    (w_hour - ((w_hour/10) * 10));
  assign w_digit_6 = 
    mode==2'd3 ? 4'hb :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000-w_digit_7*1000000)/100000 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000-w_digit_7*1000000)/100000 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000-w_digit_7*1000000)/100000 :
    sel6 ? 4'ha : 
    mode == 2'd0 ? (w_day / 10) :
    (w_hour / 10);

  assign w_digit_7 = 
    mode==2'd3 ? 4'hb :
    mode==2'd2 & !next ? (num1-w_digit_8*10000000)/1000000 :
    mode==2'd2 & next & !next2 ? (num2-w_digit_8*10000000)/1000000 :
    mode==2'd2 & next & next2 ? (result-w_digit_8*10000000)/1000000 :
    mode == 2'd1 ? 4'hb :
    sel7 ? 4'ha : 
    mode == 2'd0 ? (w_month - (w_digit_8 * 10)) :
    4'hb;
  assign w_digit_8 =
    mode==2'd3 ? 4'hb :
    mode==2'd2 & !next ? num1/10000000 :
    mode==2'd2 & next & !next2 ? num2/10000000 :
    mode==2'd2 & next & next2 ? result/10000000 :
    mode == 2'd1 ? 4'hb : 
    sel8 ? 4'ha : 
    mode == 2'd0 ? (w_month / 10) :
    4'hb;
  
  assign o_bcd8d = {w_digit_8, w_digit_7,
                    w_digit_6, w_digit_5,
                    w_digit_4, w_digit_3,
                    w_digit_2, w_digit_1};
  assign o_fin = r_fin;
  assign o_led_op =
    mode == 2'd0 & set_min ? 4'b1110 :
    mode == 2'd0 & set_hour ? 4'b1101 :
    mode == 2'd0 & set_day ? 4'b1011 :
    mode == 2'd0 & set_month ? 4'b0111 :
    mode == 2'd1 & set_sec ? 4'b1110 :
    mode == 2'd1 & set_min ? 4'b1101 :
    mode == 2'd1 & set_hour ? 4'b1011 :
    mode == 2'd2 & next & operand==2'd0 & !next2 ? 4'b0111 :
    mode == 2'd2 & next & operand==2'd1 & !next2 ? 4'b1011 :
    mode == 2'd2 & next & operand==2'd2 & !next2 ? 4'b1101 :
    mode == 2'd2 & next & operand==2'd3 & !next2 ? 4'b1110 :
    4'b1111;
  assign buzzer = r_buzzer;
  
  endmodule