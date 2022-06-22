module VM(
    //Input 
    clk,
    rst_n,
    in_item_valid,
    in_coin_valid,
    in_coin,
    in_rtn_coin,
    in_buy_item,
    in_item_price,
    //OUTPUT
    out_monitor,
    out_valid,
    out_consumer,
    out_sell_num
);

    //Input 
input clk;    
input rst_n; 
input in_item_valid;
input in_coin_valid; 
input [5:0] in_coin; 
input in_rtn_coin;
input [2:0] in_buy_item;
input [4:0] in_item_price;    
    //OUTPUT
output logic [8:0] out_monitor;
output logic out_valid;
output logic [3:0] out_consumer;
output logic [5:0] out_sell_num;

//---------------------------------------------------------------------
//  Your design(Using FSM)     

parameter IDLE = 0,ITEM = 1,COIN = 2,COM = 3,BUY = 4,CHANGE_50 = 5,CHANGE_20 = 6,CHANGE_10 = 7,CHANGE_5 = 8,CHANGE_1 = 9;
logic [3:0] state,next;
//-----------------------------------
// FSM
//-----------------------------------
always @(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        state <= IDLE;
    end
    else begin
        state <= next;
    end
end

always @(*) begin
    case (state)
        IDLE : next = (in_item_valid)? ITEM : (in_coin_valid)? COIN : IDLE;
        ITEM : next = (in_coin_valid)? COIN : ITEM;
        COIN : next = (!in_coin_valid)? COM : COIN;  
        COM : next = BUY; 
        BUY : next = CHANGE_50;
        CHANGE_50 : next = CHANGE_20;
        CHANGE_20 : next = CHANGE_10;
        CHANGE_10 : next = CHANGE_5;
        CHANGE_5 : next = CHANGE_1;
        CHANGE_1 : next = IDLE;
        default : next = IDLE;
    endcase
end
//-----------------------------------
// ITEM PRICE
//-----------------------------------
logic [4:0] cost[5:0],cost_ff[5:0];
logic [2:0] cnt8,cnt8_ff;
always @(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cost_ff[0] <= 0;
        cost_ff[1] <= 0;
        cost_ff[2] <= 0;
        cost_ff[3] <= 0;
        cost_ff[4] <= 0;
        cost_ff[5] <= 0;
        cnt8_ff <= 0;
    end
    else begin
        cost_ff[0] <= cost[0];
        cost_ff[1] <= cost[1];
        cost_ff[2] <= cost[2];
        cost_ff[3] <= cost[3];
        cost_ff[4] <= cost[4];
        cost_ff[5] <= cost[5];
        cnt8_ff <= cnt8;
    end
end

assign cnt8 = (in_item_valid)? cnt8_ff+1 : 0;
assign cost[0] = (in_item_valid && cnt8_ff==0)? in_item_price : cost_ff[0];
assign cost[1] = (in_item_valid && cnt8_ff==1)? in_item_price : cost_ff[1];
assign cost[2] = (in_item_valid && cnt8_ff==2)? in_item_price : cost_ff[2];
assign cost[3] = (in_item_valid && cnt8_ff==3)? in_item_price : cost_ff[3];
assign cost[4] = (in_item_valid && cnt8_ff==4)? in_item_price : cost_ff[4];
assign cost[5] = (in_item_valid && cnt8_ff==5)? in_item_price : cost_ff[5];

//-----------------------------------
// monitor COM BUY
//-----------------------------------
logic [8:0] monitor,monitor_ff;
logic [8:0] monitor_temp,monitor_temp_ff;
logic [5:0] sell_num[5:0],sell_num_ff[5:0];
logic [3:0] consumer,consumer_ff;

integer sell_idx;
always @(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        monitor_temp_ff <= 0;
        monitor_ff <= 0;
        consumer_ff <= 0;
        for(sell_idx=0;sell_idx<6;sell_idx++)
            sell_num_ff[sell_idx] <= 0;
    end
    else begin
        monitor_temp_ff <= monitor_temp;
        monitor_ff <= monitor;
        consumer_ff <= consumer;
        for(sell_idx=0;sell_idx<6;sell_idx++)
            sell_num_ff[sell_idx] <= sell_num[sell_idx];
    end
end

assign out_monitor = monitor_ff;
assign out_valid = (state==BUY || state==CHANGE_50 || state==CHANGE_20 || state==CHANGE_10 || state==CHANGE_5 || state==CHANGE_1)? 1 : 0;
assign out_consumer = consumer_ff;

always @(*) begin
    if(in_coin_valid)
        monitor = monitor_ff+in_coin;    
    else if(state==COIN)begin
        if(in_rtn_coin)
            monitor = 0;
        else begin
            if(cost_ff[in_buy_item-1] > monitor_ff)
                monitor = monitor_ff;
            else
                monitor = 0;
        end
    end
    else
        monitor = monitor_ff;
end

// out_consumer
always @ (*) begin
    if(state==COIN)begin
        monitor_temp = (in_coin_valid)? monitor_temp_ff : (in_rtn_coin)? monitor_ff : (cost_ff[in_buy_item-1] > monitor_ff)? 0 : monitor_ff-cost_ff[in_buy_item-1];        
        out_sell_num = 0;
        consumer = (in_coin_valid)? 0 : (in_rtn_coin)? 0 : (cost_ff[in_buy_item-1] > monitor_ff)? 0 : in_buy_item;
    end
    else if(state==BUY)begin
        consumer = monitor_temp_ff/50;        
        monitor_temp = monitor_temp_ff - 50*(monitor_temp_ff/50);
        out_sell_num = sell_num_ff[0];
    end
    else if(state==CHANGE_50)begin
        if(monitor_temp_ff>=40)begin
            consumer = 2;
            monitor_temp = monitor_temp_ff-40;
        end
        else if(monitor_temp_ff>=20)begin
            consumer = 1;
            monitor_temp = monitor_temp_ff-20;
        end
        else begin
            consumer = 0;
            monitor_temp = monitor_temp_ff;
        end
        out_sell_num = sell_num_ff[1];
    end
    else if(state==CHANGE_20)begin
        if(monitor_temp_ff>=10)begin
            consumer = 1;
            monitor_temp = monitor_temp_ff-10;
        end
        else begin
            consumer = 0;
            monitor_temp = monitor_temp_ff;
        end
        out_sell_num = sell_num_ff[2];
    end
    else if(state==CHANGE_10)begin
        if(monitor_temp_ff>=5)begin
            consumer = 1;
            monitor_temp = monitor_temp_ff-5;
        end
        else begin
            consumer = 0;
            monitor_temp = monitor_temp_ff;
        end
        out_sell_num = sell_num_ff[3];
    end
    else if(state==CHANGE_5)begin
        consumer = monitor_temp_ff;
        monitor_temp = 0;
        out_sell_num = sell_num_ff[4];
    end
    else if(state==CHANGE_1)begin
        monitor_temp = monitor_temp_ff;
        consumer = 0;
        out_sell_num = sell_num_ff[5];
    end
    else begin
        consumer = consumer_ff;
        monitor_temp = monitor_temp_ff;
        out_sell_num = 0;
    end
end

always @ (*) begin
    if(in_item_price)begin
        for(sell_idx=0;sell_idx<6;sell_idx++)
            sell_num[sell_idx] = 0;
    end
    else if(state==COIN && !in_coin_valid)begin
        if(in_rtn_coin)begin
            for(sell_idx=0;sell_idx<6;sell_idx++)
                sell_num[sell_idx] = sell_num_ff[sell_idx];
        end
        else begin
            if(cost_ff[in_buy_item-1] > monitor_ff)begin
                for(sell_idx=0;sell_idx<6;sell_idx++)
                    sell_num[sell_idx] = sell_num_ff[sell_idx];
            end
            else begin
                for(sell_idx=0;sell_idx<6;sell_idx++)
                    sell_num[sell_idx] = sell_num_ff[sell_idx];
                sell_num[in_buy_item-1]+=1;
            end
        end
    end
    else begin
        for(sell_idx=0;sell_idx<6;sell_idx++)
            sell_num[sell_idx] = sell_num_ff[sell_idx];
    end
end

endmodule
