module Checkdigit(
    // Input signals
    in_num,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid,
    out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_num;
input in_valid, rst_n, clk;
output  logic out_valid;
output  logic [3:0] out;
//---------------------------------------------------------------------
// logic declare
// 9 * 15 = 145
logic [4:0] cnt,cnt_ff;
logic [6:0] sum_ff,sum;

always @ (posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        sum_ff <= 0;
        cnt_ff <= 0;    
        out_ff <= 0; 
    end
    else begin
        sum_ff <= sum;
        cnt_ff <= cnt;
        out_ff <= out_c;
    end 
end

cnt = (cnt_ff==16)? 0 : cnt_ff + 1;
sum = (cnt_ff==16)?  0 : (!in_valid)?  sum_ff : (cnt_ff[0]==1'b0)? sum_ff + (in_num<<1) : sum_ff + in_num;

assign out_valid = (cnt_ff==16)? 1 : 0;
assign out = (cnt_ff==16)? (sum_ff % 10==0)? 15 : sum_ff % 10 : 0;

endmodule