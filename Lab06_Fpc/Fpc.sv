module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

//---------------------------------------------------------------------
// Common
//---------------------------------------------------------------------
logic mode_ff;
logic [7:0] frA,frB,expA,expB;
logic signA,signB;
assign frA = {1'b1,in_a[6:0]};
assign frB = {1'b1,in_b[6:0]};
assign expA = in_a[14:7]; 
assign expB = in_b[14:7];
assign signA = in_a[15];
assign signB = in_b[15];

logic valid_ff,valid;
assign valid = in_valid;
//---------------------------------------------------------------------
// ADD
//---------------------------------------------------------------------
logic [7:0] exp_ADD,frA_ADD_shift,frB_ADD_shift,exp_ADD_shift,exp_ADD_shift_ff;  // for add
logic signed [8:0] frA_COM,frB_COM;
logic signed [9:0] sum,sum_COM,fr_ADD_NOR;
logic [6:0] fr_ADD_NOR_ff;
logic sign_ADD,sign_ADD_ff;

assign exp_ADD = (expA>expB)? expA : expB;
assign frA_ADD_shift = (expA>=expB)? frA : frA >> (expB-expA+0);
assign frB_ADD_shift = (expB>=expA)? frB : frB >> (expA-expB+0);
assign frA_COM = (signA==1'b1)? ~frA_ADD_shift + 1 : frA_ADD_shift;
assign frB_COM = (signB==1'b1)? ~frB_ADD_shift + 1 : frB_ADD_shift;
assign sum = frA_COM + frB_COM;
assign sign_ADD = (sum[9]==1'b1)? 1 : 0;
assign sum_COM = (sign_ADD==1'b1)? ~sum+1 : sum;


always @ (*)begin
    casez(sum_COM)
        10'b?1??_????_?? : begin 
            exp_ADD_shift = exp_ADD+1;
            fr_ADD_NOR = sum_COM>>1;
        end
        10'b?01?_????_?? : begin 
            exp_ADD_shift = exp_ADD;
            fr_ADD_NOR = sum_COM;
        end
        10'b?001_????_?? : begin
            exp_ADD_shift = exp_ADD-1;
            fr_ADD_NOR = sum_COM<<1;
        end
        10'b?000_1???_?? : begin
            exp_ADD_shift = exp_ADD-2;
            fr_ADD_NOR = sum_COM<<2;
        end
        10'b?000_01??_?? : begin
            exp_ADD_shift = exp_ADD-3;
            fr_ADD_NOR = sum_COM<<3;
        end
        10'b?000_001?_?? : begin
            exp_ADD_shift = exp_ADD-4;
            fr_ADD_NOR = sum_COM<<4;
        end
        10'b?000_0001_?? : begin
            exp_ADD_shift = exp_ADD-5;
            fr_ADD_NOR = sum_COM<<5;
        end
        10'b?000_0000_1? : begin
            exp_ADD_shift = exp_ADD-6;
            fr_ADD_NOR = sum_COM<<6;
        end
        10'b?000_0000_01 : begin
            exp_ADD_shift = exp_ADD-7;
            fr_ADD_NOR = sum_COM<<7;
        end
        default : begin 
            exp_ADD_shift = exp_ADD;
            fr_ADD_NOR = sum_COM;
        end
    endcase
end
//---------------------------------------------------------------------
// MUL
//---------------------------------------------------------------------
logic [15:0] mul_fr;
logic sign_MUL,sign_MUL_ff;
logic [8:0] exp_MUL;
logic [7:0] exp_MUL_shift,exp_MUL_shift_ff;
logic [15:0] fr_MUL_NOR;
logic [6:0] fr_MUL_NOR_ff;

assign mul_fr = frA * frB;
assign sign_MUL =  signA ^ signB; 
assign exp_MUL = (expA + expB - 127);

always @ (*)begin
    casez(mul_fr[15:8])
        8'b1???_???? : begin
            exp_MUL_shift = exp_MUL+1;
            fr_MUL_NOR = mul_fr >> 1;
        end
        8'b01??_???? : begin
            exp_MUL_shift = exp_MUL;
            fr_MUL_NOR = mul_fr;
        end
        8'b001?_???? : begin
            exp_MUL_shift = exp_MUL-1;
            fr_MUL_NOR = mul_fr << 1;
        end
        8'b0001_???? : begin
            exp_MUL_shift = exp_MUL-2;
            fr_MUL_NOR = mul_fr << 2;
        end
        8'b0000_1??? : begin
            exp_MUL_shift = exp_MUL-3;
            fr_MUL_NOR = mul_fr << 3;
        end
        8'b0000_01??? : begin
            exp_MUL_shift = exp_MUL-4;
            fr_MUL_NOR = mul_fr << 4;
        end
        8'b0000_001? : begin
            exp_MUL_shift = exp_MUL-5;
            fr_MUL_NOR = mul_fr << 5;
        end
        8'b0000_0001 : begin
            exp_MUL_shift = exp_MUL-6;
            fr_MUL_NOR = mul_fr << 6;
        end
        default : begin 
            exp_MUL_shift = exp_MUL;
            fr_MUL_NOR = mul_fr;
        end
    endcase
end

always @ (posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        mode_ff <= 0;
        valid_ff <= 0;

        exp_ADD_shift_ff <= 0;
        fr_ADD_NOR_ff <= 0;
        sign_ADD_ff <= 0;        

        exp_MUL_shift_ff <= 0;
        sign_MUL_ff <= 0;
        
    end
    else begin
        valid_ff <= valid;
        mode_ff <= mode;

        exp_ADD_shift_ff <= exp_ADD_shift;
        fr_ADD_NOR_ff <= fr_ADD_NOR[6:0];
        sign_ADD_ff <= sign_ADD;

        fr_MUL_NOR_ff <=  fr_MUL_NOR[13:7];
        exp_MUL_shift_ff <= exp_MUL_shift; 
        sign_MUL_ff <= sign_MUL;    
    end
end

assign out_valid = valid_ff;
assign out = (valid_ff==1)? (mode_ff==1'b0)? {sign_ADD_ff,exp_ADD_shift_ff,fr_ADD_NOR_ff} : {sign_MUL_ff,exp_MUL_shift_ff,fr_MUL_NOR_ff} : 0;

endmodule

