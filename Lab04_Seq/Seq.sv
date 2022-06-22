module Seq(clk,rst_n,in_data,in_state_reset,out_cur_state,out);
    input clk,rst_n,in_data,in_state_reset;
    output wire [2:0] out_cur_state;
    output wire out;
//----------------------------
//  FSM
//----------------------------
    parameter S_0 = 3'd0;
    parameter S_1 = 3'd1;
    parameter S_2 = 3'd2;
    parameter S_3 = 3'd3;
    parameter S_4 = 3'd4;
    parameter S_5 = 3'd5;
    parameter S_6 = 3'd6;
    parameter S_7 = 3'd7;

//---------------------------
// design
//---------------------------
    logic [2:0] state,next;
    always @ (posedge clk,negedge rst_n) begin
        if(!rst_n) begin 
            state<= S_0;  

        end
        else begin
            state<=next;    
        end
    end

    always @(*)begin
        if(in_state_reset) next = S_0;
        else begin        
            case(state)
                S_0 : begin        // none         
                    next = (in_data)? S_1 : S_2;
                end
                S_1 : begin        // one 1
                    next = (in_data)? S_1 : S_4;
                end
                S_2 : begin        // zero 1 one 0
                    next = (in_data)? S_4 : S_3;
                end
                S_3 : begin         // zero 1 two 0
                    next = (in_data)? S_5 : S_6;
                end
                S_4 : begin        // one 1 one 0
                    next = (in_data)? S_4 : S_5;
                end
                S_5 : begin        // one 1 two 0
                    next = (in_data)? S_5 : S_7;
                end
                S_6 : begin         // zero 1 three 0
                    next = (in_data)? S_7 : S_6;
                end
                S_7 : begin         // one 1 three 0  out = 1
                    next = (in_data)? S_7 : S_7;
                end
            endcase
        end
    end
    assign out = (state == S_7)?  1 : 0;
    assign out_cur_state = state;

endmodule