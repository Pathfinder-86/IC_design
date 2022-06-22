
module MIPS(
    //Input 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //OUTPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);

    //Input 
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
    //OUTPUT
output logic out_valid, instruction_fail;
output logic [31:0] out_1, out_2, out_3, out_4;


// out_reg,in_valid,instructon_fail
logic [19:0] output_reg0_ff,output_reg1,output_reg1_ff,output_reg2,output_reg2_ff;
logic instruction_fail1,instruction_fail_ff1,instruction_fail2,instruction_fail_ff2,instruction_fail3,instruction_fail_ff3;
logic valid0_ff,valid1,valid1_ff,valid2,valid2_ff,valid3,valid3_ff;

always @(posedge clk,negedge rst_n) begin
    if(!rst_n)begin
        output_reg0_ff <= 0;
        output_reg1_ff <= 0;
        output_reg2_ff <= 0;
        instruction_fail_ff1 <= 0;
        instruction_fail_ff2 <= 0;
        instruction_fail_ff3 <= 0;
        valid0_ff <= 0;
        valid1_ff <= 0;
        valid2_ff <= 0;
        valid3_ff <= 0;
    end
    else begin        
        output_reg0_ff <= output_reg;
        output_reg1_ff <= output_reg1;
        output_reg2_ff <= output_reg2;  
        instruction_fail_ff1 <= instruction_fail1;
        instruction_fail_ff2 <= instruction_fail2;
        instruction_fail_ff3 <= instruction_fail3;   
        valid0_ff <= in_valid;
        valid1_ff <= valid1;
        valid2_ff <= valid2;
        valid3_ff <= valid3;
    end
end

assign valid1 = valid0_ff;
assign valid2 = valid1_ff;
assign valid3 = valid2_ff;
assign out_valid = valid3_ff;
assign instruction_fail = (valid3_ff==1'b1)? instruction_fail_ff3 : 0;
assign output_reg1 = output_reg0_ff;
assign output_reg2 = output_reg1_ff;

// decode and read register
logic [31:0] instruction0_ff;
logic which_type,which_tpye_ff;   // 0 for R,1 for I
logic [2:0] rs,rs_ff,rt,rt_ff,rd,rd_ff,shamt,shamt_ff;
logic [5:0] funct,funct_ff;
logic [15:0] immediate,immediate_ff;

always @ (posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        instruction0_ff <= 0;
        which_tpye_ff <= 0;
        rs_ff <= 0;
        rt_ff <= 0;
        rd_ff <= 0;
        funct_ff <= 0;
        shamt_ff <= 0;
        immediate_ff <= 0;        
    end
    else begin
        instruction0_ff <= instruction;
        which_tpye_ff <= which_type;
        rs_ff <= rs;
        rt_ff <= rt;
        rd_ff <= rd;
        funct_ff <= funct;
        shamt_ff <= shamt;
        immediate_ff <= immediate;
    end
end
// 10001 0, 10010 1, 01000 2, 10111 3, 11111 4,10000 5
logic [31:0] value_ff[5:0],value[5:0];

always @ (posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        value_ff[0] <= 0;
        value_ff[1] <= 0;
        value_ff[2] <= 0;
        value_ff[3] <= 0;
        value_ff[4] <= 0;
        value_ff[5] <= 0;
    end
    else begin
        value_ff[0] <= value[0];
        value_ff[1] <= value[1];
        value_ff[2] <= value[2];
        value_ff[3] <= value[3];
        value_ff[4] <= value[4];
        value_ff[5] <= value[5];
    end
end

always @ (*) begin    
    instruction_fail1 = 0;
    if(valid0_ff==1'b1) begin
        if(instruction0_ff[31:26]==6'b000000)begin
            which_type = 0;        
            case (instruction0_ff[25:21])    
                5'b10001: rs = 0;
                5'b10010: rs = 1;
                5'b01000: rs = 2;
                5'b10111: rs = 3;
                5'b11111: rs = 4;
                5'b10000: rs = 5;
                default : begin 
                    rs = 0;
                    instruction_fail1 = 1;
                end
            endcase
            case (instruction0_ff[20:16])    
                5'b10001: rt = 0;
                5'b10010: rt = 1;
                5'b01000: rt = 2;
                5'b10111: rt = 3;
                5'b11111: rt = 4;
                5'b10000: rt = 5;
                default : begin 
                    rt = 0;
                    instruction_fail1 = 1;
                end
            endcase
            case (instruction0_ff[15:11])    
                5'b10001: rd = 0;
                5'b10010: rd = 1;
                5'b01000: rd = 2;
                5'b10111: rd = 3;
                5'b11111: rd = 4;
                5'b10000: rd = 5;
                default : begin 
                    rd = 0;
                    instruction_fail1 = 1;
                end
            endcase
            shamt = instruction0_ff[10:6];
            funct = instruction0_ff[5:0];
            immediate = 0;
        end
        else if(instruction0_ff[31:26]==6'b001000)begin
            which_type = 1;    
            case (instruction0_ff[25:21])    
                5'b10001: rs = 0;
                5'b10010: rs = 1;
                5'b01000: rs = 2;
                5'b10111: rs = 3;
                5'b11111: rs = 4;
                5'b10000: rs = 5;
                default : begin 
                    rs = 0;
                    instruction_fail1 = 1;
                end
            endcase
            case (instruction0_ff[20:16])    
                5'b10001: rt = 0;
                5'b10010: rt = 1;
                5'b01000: rt = 2;
                5'b10111: rt = 3;
                5'b11111: rt = 4;
                5'b10000: rt = 5;
                default : begin 
                    rt = 0;
                    instruction_fail1 = 1;
                end
            endcase
            immediate = instruction0_ff[15:0];
            rd = 0;
            shamt = 0;
            funct = 0;
        end
        else begin
            instruction_fail1 = 1;
            which_type = 0;
            rs = 0;
            rt = 0;
            immediate = 0;
            rd = 0;
            shamt = 0;
            funct = 0;
        end       
    end
    else begin
        which_type = 0;
        rs = 0;
        rt = 0;
        immediate = 0;
        rd = 0;
        shamt = 0;
        funct = 0;
    end 
end

// ALU
always @ (*) begin
    value[0] = value_ff[0];
    value[1] = value_ff[1];
    value[2] = value_ff[2];
    value[3] = value_ff[3];
    value[4] = value_ff[4];
    value[5] = value_ff[5];
    instruction_fail2 = 0;
    if(valid1_ff==1'b1) begin
        if(instruction_fail_ff1==1'b1)
            instruction_fail2 = 1;
        else if(which_tpye_ff==1'b0) begin        
            case (funct_ff)
                6'b100000: value[rd_ff] = value_ff[rs_ff] + value_ff[rt_ff];            
                6'b100100: value[rd_ff] = value_ff[rs_ff] & value_ff[rt_ff];   
                6'b100101: value[rd_ff] = value_ff[rs_ff] | value_ff[rt_ff]; 
                6'b100111: value[rd_ff] = ~(value_ff[rs_ff] | value_ff[rt_ff]); 
                6'b000000: value[rd_ff] = value_ff[rt_ff] << shamt_ff; 
                6'b000010: value[rd_ff] = value_ff[rt_ff] >> shamt_ff; 
                default: instruction_fail2 = 1;
            endcase
        end
        else
            value[rt_ff] = value_ff[rs_ff] + immediate_ff;
    end
    else begin
        value[0] = value_ff[0];
        value[1] = value_ff[1];
        value[2] = value_ff[2];
        value[3] = value_ff[3];
        value[4] = value_ff[4];
        value[5] = value_ff[5];
    end
end

// output select
logic [31:0] ans[3:0],ans_ff[3:0];
always @ (*) begin
    instruction_fail3 = 0;
    ans[0] = 0;
    ans[1] = 0;
    ans[2] = 0;
    ans[3] = 0;
    if(valid2_ff==1'b1)begin        
        if(instruction_fail_ff2 == 1'b1)
            instruction_fail3 = 1;        
        else begin
            case(output_reg2_ff[19:15])
                5'b10001: ans[3] = value_ff[0];
                5'b10010: ans[3] = value_ff[1];
                5'b01000: ans[3] = value_ff[2];
                5'b10111: ans[3] = value_ff[3];
                5'b11111: ans[3] = value_ff[4];
                5'b10000: ans[3] = value_ff[5];
                default : begin 
                    ans[3] = 0;
                    instruction_fail3 = 1;
                end
            endcase
            case(output_reg2_ff[14:10])
                5'b10001: ans[2] = value_ff[0];
                5'b10010: ans[2] = value_ff[1];
                5'b01000: ans[2] = value_ff[2];
                5'b10111: ans[2] = value_ff[3];
                5'b11111: ans[2] = value_ff[4];
                5'b10000: ans[2] = value_ff[5];
                default : begin 
                    ans[2] = 0;
                    instruction_fail3 = 1;
                end
            endcase
            case(output_reg2_ff[9:5])
                5'b10001: ans[1] = value_ff[0];
                5'b10010: ans[1] = value_ff[1];
                5'b01000: ans[1] = value_ff[2];
                5'b10111: ans[1] = value_ff[3];
                5'b11111: ans[1] = value_ff[4];
                5'b10000: ans[1] = value_ff[5];
                default : begin 
                    ans[1] = 0;
                    instruction_fail3 = 1;
                end
            endcase
            case(output_reg2_ff[4:0])
                5'b10001: ans[0] = value_ff[0];
                5'b10010: ans[0] = value_ff[1];
                5'b01000: ans[0] = value_ff[2];
                5'b10111: ans[0] = value_ff[3];
                5'b11111: ans[0] = value_ff[4];
                5'b10000: ans[0] = value_ff[5];
                default : begin 
                    ans[0] = 0;
                    instruction_fail3 = 1;
                end
            endcase
        end
    end
    else begin
        ans[0] = 0;
        ans[1] = 0;
        ans[2] = 0;
        ans[3] = 0;
    end
end

always @ (posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        ans_ff[0] <= 0;
        ans_ff[1] <= 0;
        ans_ff[2] <= 0;
        ans_ff[3] <= 0;        
    end
    else begin
        ans_ff[0] <= ans[0];
        ans_ff[1] <= ans[1];
        ans_ff[2] <= ans[2];
        ans_ff[3] <= ans[3];
    end
end

assign out_1 = (valid3_ff==1'b1 && instruction_fail_ff3 == 1'b0)? ans_ff[0] : 0;
assign out_2 = (valid3_ff==1'b1 && instruction_fail_ff3 == 1'b0)? ans_ff[1] : 0;
assign out_3 = (valid3_ff==1'b1 && instruction_fail_ff3 == 1'b0)? ans_ff[2] : 0;
assign out_4 = (valid3_ff==1'b1 && instruction_fail_ff3 == 1'b0)? ans_ff[3] : 0;

endmodule



