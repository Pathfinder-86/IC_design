module Conv(
  // Input signals
  clk,
  rst_n,
  image_valid,
  filter_valid,
  in_data,
  // Output signals
  out_valid,
  out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, image_valid, filter_valid;
input signed [3:0] in_data;
output logic signed [15:0] out_data;
output logic out_valid;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
parameter IDLE = 0,FILTER = 1,IMAGE = 2,OUT = 3;
logic [1:0] state,next;

logic [4:0] cnt32,cnt32_ff;
logic [3:0] cnt_out,cnt_out_ff;
logic [6:0] cnt64,cnt64_ff;
// FSM
always @(posedge clk,negedge rst_n) begin
    if(!rst_n)
      state <= IDLE;
    else
      state <= next;
end
always @ (*)begin
    case (state)
      IDLE : next = (filter_valid)? FILTER : IDLE;
      FILTER : next = (image_valid)? IMAGE : FILTER;
      IMAGE : next = (cnt64_ff==68)? OUT : IMAGE;
      OUT : next = (cnt_out_ff==15)? IDLE : OUT;
      default : next = IDLE;
    endcase
end
// FILTER
logic signed [3:0]  filter[9:0],filter_ff[9:0];
logic [3:0] cnt16,cnt16_ff;
assign cnt16 = (filter_valid)? cnt16_ff+1 : 0;
always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
      cnt16_ff <= 0;
      filter_ff[0] <= 0;
      filter_ff[1] <= 0;
      filter_ff[2] <= 0;
      filter_ff[3] <= 0;
      filter_ff[4] <= 0;
      filter_ff[5] <= 0;
      filter_ff[6] <= 0;
      filter_ff[7] <= 0;
      filter_ff[8] <= 0;
      filter_ff[9] <= 0;
    end
    else begin
      cnt16_ff <= cnt16;
      filter_ff[0] <= filter[0];
      filter_ff[1] <= filter[1];
      filter_ff[2] <= filter[2];
      filter_ff[3] <= filter[3];
      filter_ff[4] <= filter[4];
      filter_ff[5] <= filter[5];
      filter_ff[6] <= filter[6];
      filter_ff[7] <= filter[7];
      filter_ff[8] <= filter[8];
      filter_ff[9] <= filter[9];
    end
end
always @ (*)begin
  filter[0] = filter_ff[0];
  filter[1] = filter_ff[1];
  filter[2] = filter_ff[2];
  filter[3] = filter_ff[3];
  filter[4] = filter_ff[4];
  filter[5] = filter_ff[5];
  filter[6] = filter_ff[6];
  filter[7] = filter_ff[7];
  filter[8] = filter_ff[8];
  filter[9] = filter_ff[9];
  if(filter_valid)
    filter[cnt16_ff] = in_data;  
end

// IMAGE
logic signed [3:0]  image_88[7:0],image_88_ff[7:0];      
logic signed [9:0]  image_84[31:0],image_84_ff[31:0];
// 000 001 010 011 100 101 110 111 000
always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
      cnt32_ff <= 0;
      cnt_out_ff <= 0;
      cnt64_ff <= 0;      
      for(int i=0;i<8;i++)
        image_88_ff[i] <= 0;
      for(int j=0;j<32;j++)
        image_84_ff[j] <= 0;
    end
    else begin
      cnt32_ff <= cnt32;
      cnt_out_ff <= cnt_out;
      cnt64_ff <= cnt64;     
      for(int i=0;i<8;i++)
        image_88_ff[i] <= image_88[i];
      for(int j=0;j<32;j++)
        image_84_ff[j] <= image_84[j];
    end
end
always @ (*) begin
  for(int i=0;i<8;i++)
    image_88[i] = image_88_ff[i];
  if(image_valid)
    image_88[cnt64_ff[2:0]] = in_data;    
  for(int i=0;i<32;i++)
    image_84[i] = image_84_ff[i];
  if(cnt64_ff[2:0]<4 &&cnt64_ff>7) begin    // 000 001 010 011
    image_84[cnt32_ff] = filter_ff[0] * image_88_ff[0+cnt64_ff[1:0]] + filter_ff[1] * image_88_ff[1+cnt64_ff[1:0]] + filter_ff[2] * image_88_ff[2+cnt64_ff[1:0]] + 
    filter_ff[3] * image_88_ff[3+cnt64_ff[1:0]] + filter_ff[4] * image_88_ff[4+cnt64_ff[1:0]];
  end
end


assign cnt32 = (cnt32_ff==31)? 0 : (cnt64_ff[2:0]<4 && cnt64_ff>7)? cnt32_ff+1 : cnt32_ff;
assign cnt_out = (state==OUT)? cnt_out_ff+1 : 0;
assign cnt64 = (image_valid)? cnt64_ff+1 : (cnt64_ff>0 && cnt64_ff<68)? cnt64_ff+1 : 0;

logic signed [15:0] data,data_ff;
logic valid,valid_ff;
assign valid = (state==OUT)? 1: 0;
assign data = (state==OUT)? (image_84_ff[0+cnt_out_ff] * filter_ff[5] + image_84_ff[4+cnt_out_ff] * filter_ff[6] +
image_84_ff[8+cnt_out_ff] * filter_ff[7] + image_84_ff[12+cnt_out_ff] * filter_ff[8] + image_84_ff[16+cnt_out_ff] * filter_ff[9]) : 0;

always @ (posedge clk,negedge rst_n)begin
  if(!rst_n)begin
    valid_ff <= 0;
    data_ff <=0;
  end
  else begin
    valid_ff <= valid;
    data_ff <= data;
  end
end

assign out_valid = valid_ff;
assign out_data = data_ff;

endmodule
