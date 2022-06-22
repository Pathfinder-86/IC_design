`include "synchronizer.v"
module CDC(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			in_a,
			mode,
			in_b,
		  //  Output signals
			out_valid,
			out
			);		
input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_a,in_b;
input mode;
output logic out_valid;
output logic [7:0]out; 			




//---------------------------------------------------------------------
//   your design  (Using synchronizer)       
// Example :
//logic P,Q,Y;
//synchronizer x5(.D(P),.Q(Y),.clk(clk_2),.rst_n(rst_n));           
//---------------------------------------------------------------------		



logic P_wire,P_ff,Q_wire,Q_ff;
parameter IDLE = 0,COM = 1,OUT = 2;
logic [1:0] state,next;
logic [3:0] in_a_wire,in_b_wire,in_a_ff,in_b_ff;
logic mode_wire,mode_ff;
logic CDC_res;
logic [7:0] out_ff,out_wire;

synchronizer x5(.D(P_ff),.Q(Q_wire),.clk(clk_2),.rst_n(rst_n));     

always @ (posedge clk_1,negedge rst_n)begin    //P
    if(!rst_n) begin
        in_a_ff <= 0;
        in_b_ff <= 0;
        mode_ff <= 0;
        P_ff <= 0;
    end
    else begin
        in_a_ff <= in_a_wire;
        in_b_ff <= in_b_wire;        
        mode_ff <= mode_wire;
        P_ff <= P_wire;      
    end
end

always @ (posedge clk_2,negedge rst_n)begin     //Q
    if(!rst_n) begin
        state <= IDLE;
        out_ff <= 0;      
        Q_ff <= 0;
    end
    else begin
        state <= next;
        out_ff <= out_wire;
        Q_ff <= Q_wire;
    end
end


assign P_wire = P_ff ^ in_valid;
assign CDC_res = Q_ff ^ Q_wire;
assign in_a_wire = (in_valid)? in_a : 0;
assign in_b_wire = (in_valid)? in_b : 0;
assign mode_wire = (in_valid)? mode : 0;
assign out = (state==OUT)? out_ff : 0;
assign out_valid = (state==OUT)? 1 : 0;
assign out_wire = (state==COM)?  (mode_ff==0)? in_a_ff + in_b_ff : in_a_ff * in_b_ff : 0;
		
always @ (*) begin        
    case (state) 
        IDLE : next = (CDC_res==1)? COM : IDLE;
        COM : next = OUT;
        OUT : next = IDLE;
        default : next = IDLE;
    endcase
end

endmodule