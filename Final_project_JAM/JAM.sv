module JAM(
  // Input signals
	clk,
	rst_n,
  in_valid,
  in_cost,
  // Output signals
	out_valid,
  out_job,
	out_cost
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [6:0] in_cost;
output logic out_valid;
output logic [3:0] out_job;
output logic [9:0] out_cost;
 
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] cost_table[63:0],cost_table_ff[63:0];
logic [3:0] state,next;
logic [5:0] cnt64,cnt64_ff;
logic [23:0] best_order,best_order_ff,cur_order,cur_order_ff;
logic [9:0] best_cost,best_cost_ff;

logic [2:0] flip_bit,flip_bit_ff,swap_bit,swap_bit_ff; // [first,last]
logic [2:0] min,min_ff,flip_num,flip_num_ff;
logic [2:0] cnt8,cnt8_ff,cnt_out,cnt_out_ff;
logic [15:0] cnt_65536,cnt_65536_ff;   // cal total cycle  40320


//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
parameter IDLE = 0,READ = 1,CAL = 2, ADD = 3,FOUND = 4,MIN = 5,SWAP = 6,FLIP = 7,OUT = 8; 
integer i,j,k;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

//-------------------------------
// FSM
always @(posedge clk,negedge rst_n) begin
    if(!rst_n)
      state <= IDLE;  
    else 
      state <= next;    
end
// combinational 
always @(*) begin
  case (state)
    IDLE:  next = (in_valid)? READ : IDLE;  
    READ : next = (!in_valid)? CAL : READ;        
    CAL : next =  ADD;
    ADD : next = FOUND;
    FOUND : next = MIN;
    MIN : next = (cnt8_ff+1<flip_bit_ff)? MIN : SWAP;
    SWAP : next = FLIP;
    FLIP : next = (cnt_65536_ff == 40319)? OUT : ADD;  
    OUT : next = (cnt_out_ff==7)? IDLE : OUT;    
    default: next = IDLE;
  endcase
end


//READ
// combinational 
assign cnt64 = (in_valid)?  cnt64_ff+1 : 0;

always @ (*) begin
  for(i=0;i<64;i++)
    cost_table[i] = cost_table_ff[i];          
  if(in_valid)  
    cost_table[cnt64_ff] = in_cost;
end
// sequential
always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
      cnt64_ff <= 0;
      for(j=0;j<64;j++)
        cost_table_ff[j] <= 0;    
    end
    else begin
      cnt64_ff <= cnt64;
      for(k=0;k<64;k++)
        cost_table_ff[k] <= cost_table[k];    
    end
end
//-----------------------------

//getcost
always @ (*) begin
  if(state==CAL)begin
    best_cost = 1023;  
    best_order = best_order_ff;
  end
  else if(state==ADD)begin
    if((cost_table_ff[0+cur_order_ff[23:21]]+cost_table_ff[8+cur_order_ff[20:18]]+cost_table_ff[16+cur_order_ff[17:15]] +
        cost_table_ff[24+cur_order_ff[14:12]]+cost_table_ff[32+cur_order_ff[11:9]]+cost_table_ff[40+cur_order_ff[8:6]] +  
        cost_table_ff[48+cur_order_ff[5:3]]+cost_table_ff[56+cur_order_ff[2:0]]) < best_cost_ff) begin

        best_cost = (cost_table_ff[0+cur_order_ff[23:21]] + cost_table_ff[8+cur_order_ff[20:18]] +  cost_table_ff[16+cur_order_ff[17:15]] +
        cost_table_ff[24+cur_order_ff[14:12]] + cost_table_ff[32+cur_order_ff[11:9]] + cost_table_ff[40+cur_order_ff[8:6]]+cost_table_ff[48+cur_order_ff[5:3]] + cost_table_ff[56+cur_order_ff[2:0]]);
        best_order = cur_order_ff;        
    end
    else begin
      best_cost = best_cost_ff;
      best_order = best_order_ff;
    end
  end  
  else  begin
    best_cost = best_cost_ff;
    best_order = best_order_ff;
  end
end


always @ (*) begin  
  if(state==CAL)begin
    cur_order = {3'd0,3'd1,3'd2,3'd3,3'd4,3'd5,3'd6,3'd7};
  end
  else if(state==SWAP)begin    
    cur_order = cur_order_ff;
    case (swap_bit_ff)
      0 : cur_order[2:0] = flip_num_ff;
      1 : cur_order[5:3] = flip_num_ff;
      2 : cur_order[8:6] = flip_num_ff;
      3 : cur_order[11:9] = flip_num_ff;
      4 : cur_order[14:12] = flip_num_ff;
      5 : cur_order[17:15] = flip_num_ff;
      6 : cur_order[20:18] = flip_num_ff; 
      default :  cur_order = 0;     
    endcase
    case (flip_bit_ff)
      1 : cur_order[5:3] = min_ff;
      2 : cur_order[8:6] = min_ff;
      3 : cur_order[11:9] = min_ff;
      4 : cur_order[14:12] = min_ff;
      5 : cur_order[17:15] = min_ff;
      6 : cur_order[20:18] = min_ff;
      7 : cur_order[23:21] = min_ff; 
      default :  cur_order = 0;     
    endcase           
  end
  else if(state==FLIP)begin
    case (flip_bit_ff)
      7 : cur_order = {cur_order_ff[23:21],cur_order_ff[2:0],cur_order_ff[5:3],cur_order_ff[8:6],cur_order_ff[11:9],cur_order_ff[14:12],cur_order_ff[17:15],cur_order_ff[20:18]};
      6 : cur_order = {cur_order_ff[23:18],cur_order_ff[2:0],cur_order_ff[5:3],cur_order_ff[8:6],cur_order_ff[11:9],cur_order_ff[14:12],cur_order_ff[17:15]};        
      5 : cur_order = {cur_order_ff[23:15],cur_order_ff[2:0],cur_order_ff[5:3],cur_order_ff[8:6],cur_order_ff[11:9],cur_order_ff[14:12]};
      4 : cur_order = {cur_order_ff[23:12],cur_order_ff[2:0],cur_order_ff[5:3],cur_order_ff[8:6],cur_order_ff[11:9]};
      3 : cur_order = {cur_order_ff[23:9],cur_order_ff[2:0],cur_order_ff[5:3],cur_order_ff[8:6]};
      2 : cur_order = {cur_order_ff[23:6],cur_order_ff[2:0],cur_order_ff[5:3]};
      default : cur_order = cur_order_ff;  
    endcase
  end
  else begin
    cur_order = cur_order_ff;
  end
end


assign cnt_65536 = (cnt_65536_ff==40319 && state==FLIP)? 0 : (state==FLIP)? cnt_65536_ff+1  :  cnt_65536_ff;

always @ (*) begin
  if(state==FOUND)begin
    if(cur_order_ff[5:3] < cur_order_ff[2:0]) begin
      flip_bit = 1;  
      flip_num = cur_order_ff[5:3];         
    end
    else if(cur_order_ff[8:6] < cur_order_ff[5:3])begin
      flip_bit = 2;  
      flip_num = cur_order_ff[8:6];         
    end
    else if(cur_order_ff[11:9] < cur_order_ff[8:6])begin
      flip_bit = 3;  
      flip_num = cur_order_ff[11:9];         
    end
    else if(cur_order_ff[14:12] < cur_order_ff[11:9])begin
      flip_bit = 4;  
      flip_num = cur_order_ff[14:12];         
    end
    else if(cur_order_ff[17:15] < cur_order_ff[14:12])begin
      flip_bit = 5;  
      flip_num = cur_order_ff[17:15];         
    end
    else if(cur_order_ff[20:18] < cur_order_ff[17:15])begin
      flip_bit = 6;  
      flip_num = cur_order_ff[20:18];         
    end
    else begin
      flip_bit = 7;  
      flip_num = cur_order_ff[23:21];         
    end
  end
  else begin
    flip_bit = flip_bit_ff;
    flip_num = flip_num_ff;
  end
end


always @(*) begin
  if(state==ADD) begin
    min = 7;
    swap_bit = swap_bit_ff;
    cnt8 = 0;
  end
  else if(state==MIN) begin    // find minimum num and swap         
    case (cnt8_ff)
      0 :  begin
        if(min_ff >= cur_order_ff[2:0] && cur_order_ff[2:0] > flip_num_ff) begin
          min = cur_order_ff[2:0];             
          swap_bit = 0;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end
      1 : begin
        if(min_ff >= cur_order_ff[5:3] && cur_order_ff[5:3] > flip_num_ff) begin
          min = cur_order_ff[5:3];             
          swap_bit = 1;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end
      2 : begin
        if(min_ff >= cur_order_ff[8:6] && cur_order_ff[8:6] > flip_num_ff) begin
          min = cur_order_ff[8:6];
          swap_bit = 2;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end 
      3 : begin
        if(min_ff >= cur_order_ff[11:9] && cur_order_ff[11:9] > flip_num_ff) begin
          min = cur_order_ff[11:9];             
          swap_bit = 3;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end
      4 : begin
        if(min_ff >= cur_order_ff[14:12] && cur_order_ff[14:12] > flip_num_ff) begin
          min = cur_order_ff[14:12];             
          swap_bit = 4;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end
      5 : begin
        if(min_ff >= cur_order_ff[17:15] && cur_order_ff[17:15] > flip_num_ff) begin
          min = cur_order_ff[17:15];             
          swap_bit = 5;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end     
      6 : begin
        if(min_ff >= cur_order_ff[20:18] && cur_order_ff[20:18] > flip_num) begin
          min = cur_order_ff[20:18];             
          swap_bit = 6;  
        end
        else begin
          min = min_ff;
          swap_bit = swap_bit_ff;
        end
      end           
      default: begin
        min = min_ff;
        swap_bit = swap_bit_ff;
      end
    endcase
    cnt8 = cnt8_ff+1;
  end
  else begin
    swap_bit = swap_bit_ff;
    cnt8 = cnt8_ff;
    min = min_ff;
  end
end    

always @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
      min_ff = 0;
      best_cost_ff <= 0;
      best_order_ff <= 0;
      cur_order_ff <= 0;
      cnt_65536_ff <= 0;
      cnt8_ff <= 0;
      flip_bit_ff <= 0;
      swap_bit_ff <= 0;
      flip_num_ff <= 0;
    end
    else begin
      min_ff = min;
      best_cost_ff <= best_cost;
      best_order_ff <= best_order;
      cur_order_ff <= cur_order;
      cnt_65536_ff <= cnt_65536;
      cnt8_ff <= cnt8;
      flip_bit_ff <= flip_bit;
      swap_bit_ff <= swap_bit;
      flip_num_ff <= flip_num;
    end
end


// OUT 
assign out_cost = (state==OUT)? best_cost_ff : 0;
assign out_valid = (state==OUT)? 1 : 0;


always @ (*) begin
  if(state==OUT)begin
    case (cnt_out_ff)
      0 : out_job = best_order_ff[23:21]+1;
      1 : out_job = best_order_ff[20:18]+1;
      2 : out_job = best_order_ff[17:15]+1;
      3 : out_job = best_order_ff[14:12]+1;
      4 : out_job = best_order_ff[11:9]+1;
      5 : out_job = best_order_ff[8:6]+1;
      6 : out_job = best_order_ff[5:3]+1;
      7 : out_job = best_order_ff[2:0]+1;      
      default out_job = 0;
    endcase
  end
  else out_job = 0;
end

assign cnt_out = (state==OUT)? cnt_out_ff+1 : 0;

always @ (posedge clk,negedge rst_n)begin
  if(!rst_n)
    cnt_out_ff <= 0;
  else 
    cnt_out_ff <= cnt_out;
end

endmodule