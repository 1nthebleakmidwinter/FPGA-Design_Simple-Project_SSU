module tb_clock_top3;

reg clk;
reg rstn;
reg start_sw;
reg [4:0] key_push;

wire [3:0] key_out;
wire [4:0] key_in;

initial begin
    #0;  rstn=0;
    #10; rstn=1;
end
initial begin
    #0; clk=0;
    forever begin
        #50 clk = ~clk;
    end
end

initial begin
    #0; key_push=5'd0; start_sw =1;
    #1000;
    key_push = 10;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 6;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 7;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 4;  #33_000_000;
    key_push = 0;  #33_000_000;
    key_push = 2;  #33_000_000;
    key_push = 0;  #33_000_000;
end

key_pad U_KEY_MATRIX (
    .rst            (rstn),
    .clk            (clk),
    .key_v          (key_push),
    .key_column_in  (key_out),
    .key_row_out    (key_in)
);

timer_top U_TIMER_TOP(
    .i_rstn      (rstn),
    .i_clk       (clk),
    .i_start_sw  (start_sw),
    .i_key_in    (key_in),
    .o_key_out   (key_out),
    .o_buzzer    (),
    .o_led       (),
    .o_seg_d     (),
    .o_seg_com   ()
);
endmodule