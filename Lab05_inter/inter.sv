module inter(
  // Input signals
    clk,
    rst_n,
    in_valid_1,
    in_valid_2,
    in_valid_3,
    data_in_1,
    data_in_2,
    data_in_3,
    ready_slave1,
    ready_slave2,
    // Output signals
    valid_slave1,
    valid_slave2,
    addr_out,
    value_out,
    handshake_slave1,
    handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
    input clk, rst_n, in_valid_1, in_valid_2, in_valid_3;
    input [6:0] data_in_1, data_in_2, data_in_3; 
    input ready_slave1, ready_slave2;
    output logic valid_slave1, valid_slave2;
    output logic [2:0] addr_out, value_out;
    output logic handshake_slave1, handshake_slave2;
//---------------------------------------------------------------------
// logic 
//---------------------------------------------------------------------
    logic [6:0] data,data1,data2,data3,data_1_ff,data_2_ff,data_3_ff;
    logic valid_2,valid_3,valid_2_ff,valid_3_ff; 
    logic [2:0] state,next;
    parameter IDLE = 0,M1 = 1,M2 = 2,M3 = 3,H1 = 4,H2 = 5,H3 = 6;
//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
    always @ (posedge clk,negedge rst_n) begin
        if(!rst_n)begin
            state <= IDLE;
            data_1_ff <= 0;
            data_2_ff <= 0;
            data_3_ff <= 0;
            valid_2_ff <= 0;
            valid_3_ff <= 0;
        end
        else begin
            state <= next;
            data_1_ff <= data1;
            data_2_ff <= data2;
            data_3_ff <= data3;
            valid_2_ff <= valid_2;
            valid_3_ff <= valid_3;
        end
    end

    assign data1 =  (in_valid_1)? data_in_1 : data_1_ff;
    assign data2 =  (in_valid_2)? data_in_2 : data_2_ff;
    assign data3 =  (in_valid_3)? data_in_3 : data_3_ff;

    assign valid_2 = (state==IDLE)? in_valid_2 : valid_2_ff;
    assign valid_3 = (state==IDLE)? in_valid_3 : valid_3_ff;

    

    always @ (*) begin
        case (state)
            IDLE : next = (in_valid_1)? M1 : (in_valid_2)? M2 : (in_valid_3)? M3 : IDLE;              
            M1 : next = ((data1[6]==0 && ready_slave1) ||(data1[6]==1 && ready_slave2))?  H1 :  M1;
            M2 : next = ((data2[6]==0 && ready_slave1) ||(data2[6]==1 && ready_slave2))?  H2 :  M2;
            M3 : next = ((data3[6]==0 && ready_slave1) ||(data3[6]==1 && ready_slave2))?  H3 :  M3;
            H1 : next = (valid_2_ff)? M2 : (valid_3_ff)? M3 : IDLE;
            H2 : next = (valid_3_ff)? M3 : IDLE;
            H3 : next = IDLE;
            default : next = IDLE;
        endcase
    end

    always @ (*) begin
        case (state)
            M1 : data = data_1_ff;
            M2 : data = data_2_ff;
            M3 : data = data_3_ff;
            H1 : data = data_1_ff;
            H2 : data = data_2_ff;
            H3 : data = data_3_ff;
            default : data = 0;
        endcase   
    end


    assign addr_out = data[5:3];
    assign value_out = data[2:0];
    assign valid_slave1 = ((state==M1 || state==M2 || state==M3) && data[6]==0)?  1 : 0;
    assign valid_slave2 = ((state==M1 || state==M2 || state==M3) && data[6]==1)?  1 : 0;
    assign handshake_slave1 = ((state==H1 || state==H2 || state==H3) && data[6]==0)?  1 : 0;
    assign handshake_slave2 = ((state==H1 || state==H2 || state==H3) && data[6]==1)?  1 : 0;

endmodule
