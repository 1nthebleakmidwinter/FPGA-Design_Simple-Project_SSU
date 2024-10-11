module key_assign(
    input        i_rstn     ,
    input        i_clk      ,
    input        i_key_valid,
    input  [4:0] i_key_value,
    output [4:0] o_bcd_data ,
    output       o_key_valid
);

reg [4:0] r_bcd_data;
reg       r_key_valid;

always@(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        r_bcd_data <= 4'hf; 
    end
    else if(i_key_valid) begin  //key** --> bcd data 
             if(i_key_value==5'd1) r_bcd_data <= 5'h10; //%
        else if(i_key_value==5'd6)  r_bcd_data <= 5'h11; //X
        else if(i_key_value==5'd11)  r_bcd_data <= 5'h12; //-
        else if(i_key_value==5'd16)  r_bcd_data <= 5'h13; //+
        
        else if(i_key_value==5'd2) r_bcd_data <= 5'h14; //Esc
        else if(i_key_value==5'd4)  r_bcd_data <= 5'h15; //Ent
        
        else if(i_key_value==5'd5)  r_bcd_data <= 5'h16; //F4
        else if(i_key_value==5'd10)  r_bcd_data <= 5'h17; //F3
        else if(i_key_value==5'd15)  r_bcd_data <= 5'h18; //F2
        else if(i_key_value==5'd20)  r_bcd_data <= 5'h19; //F1
        
        else if(i_key_value==5'd3) r_bcd_data <= 5'h0; //0
        else if(i_key_value==5'd7)  r_bcd_data <= 5'h1; //1
        else if(i_key_value==5'd8)  r_bcd_data <= 5'h2; //2
        else if(i_key_value==5'd9)  r_bcd_data <= 5'h3; //3
        else if(i_key_value==5'd12)  r_bcd_data <= 5'h4; //4
        else if(i_key_value==5'd13)  r_bcd_data <= 5'h5; //5
        else if(i_key_value==5'd14)  r_bcd_data <= 5'h6; //6
        else if(i_key_value==5'd17)  r_bcd_data <= 5'h7; //7
        else if(i_key_value==5'd18)  r_bcd_data <= 5'h8; //8
        else if(i_key_value==5'd19)  r_bcd_data <= 5'h9; //9
        
        else                        r_bcd_data <= 5'hf;
    end
end

always@(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        r_key_valid <= 1'b0;
    end
    else begin
        r_key_valid <= i_key_valid;
    end
end


assign o_bcd_data = r_bcd_data;
assign o_key_valid = r_key_valid;

endmodule