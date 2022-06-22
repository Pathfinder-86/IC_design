module Maxmin(
  // Input signals
	in_num,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out_max,
	out_min
);

input [7:0] in_num;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [7:0] out_max, out_min;
//---------------------------------------------------------------------    
    logic [7:0] min_ff,min;
    logic [7:0] max_ff,max;
    logic [3:0] cnt,cnt_ff;
    logic out;
    logic [1:0] state,next;
    parameter IDLE = 0,COUNT = 1,OUT = 2;
//--------------------------------------------------------
    always @(posedge clk,negedge rst_n) begin
        if(!rst_n)begin
            max_ff <= 0;
            min_ff <= 255;  
            cnt_ff <= 0;    
            state <= IDLE;       
        end
        else begin
            max_ff <= max;
            min_ff <= min;
            cnt_ff <= cnt;        
            state <= next; 
        end
    end

    assign out_max = max_ff;
    assign out_min = min_ff;
    assign out_valid = (state==OUT)? 1 : 0;
    assign cnt = (in_valid)? cnt_ff+1 : 0;

    always @(*) begin
        case (state)
            IDLE : next = (in_valid)? COUNT : IDLE;
            COUNT : next = (cnt_ff==14)? OUT : COUNT;
            OUT : next = IDLE;
            default: next = IDLE;
        endcase
    end

    assign max = (!in_valid)? 0  : (in_num > max_ff)? in_num : max_ff;
    assign min = (!in_valid)? 255  : (in_num > min_ff)? min_ff : in_num;  
      
endmodule