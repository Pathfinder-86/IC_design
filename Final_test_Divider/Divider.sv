module Divider(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_data,
  // Output signals
    out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] in_data;
output logic out_valid, out_data;
 
// FSM

logic [2:0] state,next;
logic [3:0] cnt16_ff,cnt16,cnt_out_ff,cnt_out;
parameter IDLE = 0,READ = 1,SORT = 2,CAL = 3,OUT = 4;

always @(posedge clk,negedge rst_n) begin
  if(!rst_n) begin
    state <= IDLE;
  end
  else begin
    state <= next;
  end
end

always @ (*) begin
  case (state) 
    IDLE : next = (in_valid)? READ : IDLE;
    READ : next = (!in_valid)? SORT : READ;
    SORT : next = CAL;
    CAL : next = (cnt16_ff==9)? OUT : CAL;
    OUT : next = (cnt_out_ff==9)? IDLE : OUT;
    default : next = IDLE;
  endcase
end

// READ
logic [3:0] data[3:0],data_ff[3:0];
logic [1:0] cnt4,cnt4_ff;
assign cnt4 = (in_valid)? cnt4_ff+1 : 0;
always @(posedge clk,negedge rst_n) begin
  if(!rst_n) begin
    cnt4_ff <= 0;
    data_ff[0] <= 0;
    data_ff[1] <= 0;
    data_ff[2] <= 0;
    data_ff[3] <= 0;
  end
  else begin
    cnt4_ff <= cnt4;
    data_ff[0] <= data[0];
    data_ff[1] <= data[1];
    data_ff[2] <= data[2];
    data_ff[3] <= data[3];
  end
end
always @ (*) begin
  data[0] = data_ff[0];
  data[1] = data_ff[1];
  data[2] = data_ff[2];
  data[3] = data_ff[3];
  if(in_valid)
    data[cnt4_ff] = (in_data-3);
end

// SORT

logic [9:0] sum;
logic [19:0] extend_dividend,dividend_ff;
logic [19:0] dividend,new_dividend;
logic [3:0] divisor,divisor_ff;
logic [3:0] data1[3:0],data2[1:0],data3[3:0],data4[1:0];
assign data1[0] = (data_ff[0]>data_ff[1])? data_ff[0] : data_ff[1];
assign data1[1] = (data_ff[0]>data_ff[1])? data_ff[1] : data_ff[0];
assign data1[2] = (data_ff[2]>data_ff[3])? data_ff[2] : data_ff[3];
assign data1[3] = (data_ff[2]>data_ff[3])? data_ff[3] : data_ff[2];


assign data2[0] = (data1[1]>data1[2])? data1[1] : data1[2];
assign data2[1] = (data1[1]>data1[2])? data1[2] : data1[1];

assign data3[0] = (data1[0]>data2[0])? data1[0] : data2[0];
assign data3[1] = (data1[0]>data2[0])? data2[0] : data1[0];
assign data3[2] = (data2[1]>data1[3])? data2[1] : data1[3];
assign data3[3] = (data2[1]>data1[3])? data1[3] : data2[1];

assign data4[0] = (data3[1]>data3[2])? data3[1] : data3[2];
assign data4[1] = (data3[1]>data3[2])? data3[2] : data3[1];

assign sum = 100 * data3[0] + 10 * data4[1] + data3[3];
assign extend_dividend = {10'b0,sum};
assign divisor = (state==SORT)? data4[0] : divisor_ff;

always @(posedge clk,negedge rst_n) begin
  if(!rst_n) begin
    dividend_ff <= 0 ;
    divisor_ff <= 0;
    cnt16_ff <= 0;
    cnt_out_ff <= 0;
  end
  else begin
    dividend_ff <= dividend;
    divisor_ff <= divisor;
    cnt16_ff <= cnt16;
    cnt_out_ff <= cnt_out;
  end
end

// CAL
assign cnt16 = (state==CAL)? cnt16_ff+1 : 0;
assign dividend = (state==SORT)? extend_dividend : (state==CAL)? new_dividend : dividend_ff;

always @ (*) begin
  if(state==CAL)begin    
    if(dividend_ff[13:9] >= divisor_ff)begin
      new_dividend = dividend_ff<<1;
      new_dividend[14:10] = (dividend_ff[13:9] - divisor_ff);    
      new_dividend[0] = 1'b1;
    end  
    else 
      new_dividend = dividend_ff<<1;
  end
  else
    new_dividend = 0;  
end

// OUT 
assign cnt_out = (state==OUT)? cnt_out_ff+1 : 0;
assign out_valid = (state==OUT)? 1 : 0;
assign out_data = (state==OUT)? (divisor_ff==0)? 1 : dividend_ff[9-cnt_out_ff] : 0;
endmodule