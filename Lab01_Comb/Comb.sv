module Comb(
  // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
  // Output signals
	out_num0,
	out_num1
);
//---------------------------------------------------------------------
    input [3:0] in_num0, in_num1, in_num2, in_num3;
    output logic [4:0] out_num0, out_num1;
//---------------------------------------------------------------------
    logic [3:0] xnor_gate,or_gate,xor_gate,and_gate;  
    logic [4:0] sum0,sum1;    
    assign xnor_gate = ~(in_num0^in_num1);
    assign or_gate = in_num1|in_num3;
    assign xor_gate = in_num2^in_num3;
    assign and_gate = in_num0&in_num2;
    assign {sum0[4],sum0[3:0]} = xnor_gate + or_gate;
    assign {sum1[4],sum1[3:0]} = and_gate + xor_gate;  
    assign out_num0 = (sum0>sum1)? sum1 :sum0;
    assign out_num1 = (sum0>sum1)? sum0 :sum1;  
endmodule