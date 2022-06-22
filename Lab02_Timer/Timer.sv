module Timer(
  // Input signals
	clk,
	rst_n,
	in_valid,
	in ,
  // Output signals
	out_valid,    
);
//---------------------------------------------------------------------
    input [4:0]in;
    input clk,rst_n,in_valid;
    output logic out_valid;    
//---------------------------------------------------------------------
    logic [4:0] cnt,cnt_ff;
    logic [4:0] timer,timer_ff;
    logic out;
    logic [1:0] state,next;
    parameter IDLE = 0,COUNT = 1,OUT = 2;
    always @(posedge clk,negedge rst_n)begin
        if(!rst_n)begin
            state <= IDLE;
            cnt_ff <= 0;
            timer_ff <= 0;            
        end
        else begin
            state <= next;
            timer_ff <= timer;
            cnt_ff <= cnt;            
        end        
    end
    assign out_valid = (state==OUT)? 1 : 0;
    assign timer = (in_valid)? in : timer_ff;
    assign cnt = (state==COUNT)? cnt_ff+1 : 0;

    always @ (*)begin
        case (state)
            IDLE : next = (in_valid)? COUNT : IDLE;
            COUNT : next = (cnt_ff==timer_ff-1)? OUT : COUNT;            
            OUT : next = IDLE;
        endcase
    end
endmodule