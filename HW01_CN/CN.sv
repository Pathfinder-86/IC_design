module CN(
    // Input signals
    opcode,
	in_n0,
	in_n1,
	in_n2,
	in_n3,
	in_n4,
	in_n5,
    // Output signals
    out_n
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
input [4:0] opcode;
output logic [8:0] out_n;
//---------------------------------------------------------------------

logic [4:0] decode_num[5:0];
logic [4:0] sort_num[5:0];


register_file r0 (in_n0,decode_num[0]);
register_file r1 (in_n1,decode_num[1]);
register_file r2 (in_n2,decode_num[2]);
register_file r3 (in_n3,decode_num[3]);
register_file r4 (in_n4,decode_num[4]);
register_file r5 (in_n5,decode_num[5]);

logic [4:0] s0[5:0];
assign s0[0] = (decode_num[0]<decode_num[1])? decode_num[0] : decode_num[1];
assign s0[1] = (decode_num[0]<decode_num[1])? decode_num[1] : decode_num[0];
assign s0[2] = (decode_num[2]<decode_num[3])? decode_num[2] : decode_num[3];
assign s0[3] = (decode_num[2]<decode_num[3])? decode_num[3] : decode_num[2];
assign s0[4] = (decode_num[4]<decode_num[5])? decode_num[4] : decode_num[5];
assign s0[5] = (decode_num[4]<decode_num[5])? decode_num[5] : decode_num[4];
logic [4:0] s1[3:0];
assign s1[0] = (s0[1]<s0[2])? s0[1] : s0[2];
assign s1[1] = (s0[1]<s0[2])? s0[2] : s0[1];
assign s1[2] = (s0[3]<s0[4])? s0[3] : s0[4];
assign s1[3] = (s0[3]<s0[4])? s0[4] : s0[3];
logic [4:0] s2[5:0];
assign s2[0] = (s0[0]<s1[0])? s0[0] : s1[0];
assign s2[1] = (s0[0]<s1[0])? s1[0] : s0[0];
assign s2[2] = (s1[1]<s1[2])? s1[1] : s1[2];
assign s2[3] = (s1[1]<s1[2])? s1[2] : s1[1];
assign s2[4] = (s1[3]<s0[5])? s1[3] : s0[5];
assign s2[5] = (s1[3]<s0[5])? s0[5] : s1[3];
logic [4:0] s3[3:0];
assign s3[0] = (s2[1]<s2[2])? s2[1] : s2[2];
assign s3[1] = (s2[1]<s2[2])? s2[2] : s2[1];
assign s3[2] = (s2[3]<s2[4])? s2[3] : s2[4];
assign s3[3] = (s2[3]<s2[4])? s2[4] : s2[3];

logic [4:0] s4[3:0];
assign sort_num[0] = (s2[0]<s3[0])? s2[0] : s3[0];
assign s4[0] = (s2[0]<s3[0])? s3[0] : s2[0];
assign s4[1] = (s3[1]<s3[2])? s3[1] : s3[2];
assign s4[2] = (s3[1]<s3[2])? s3[2] : s3[1];
assign s4[3] = (s3[3]<s2[5])? s3[3] : s2[5];
assign sort_num[5] = (s3[3]<s2[5])? s2[5] : s3[3];


assign sort_num[1] = (s4[0]<s4[1])? s4[0] : s4[1];
assign sort_num[2] = (s4[0]<s4[1])? s4[1] : s4[0];
assign sort_num[3] = (s4[2]<s4[3])? s4[2] : s4[3];
assign sort_num[4] = (s4[2]<s4[3])? s4[3] : s4[2];

logic [4:0] cal_num[5:0];
integer i,j,k,l;
always @(*) begin    
    case (opcode[4:3])
        2'b11: begin
            for(i=0;i<6;i++)
                cal_num[i] = sort_num[i];
        end
        2'b10: begin
            for(i=0;i<6;i++)
                cal_num[5-i] = sort_num[i];
        end
        2'b00: begin
            for(i=0;i<6;i++)
                cal_num[i] = decode_num[i];
        end
        2'b01: begin
            for(i=0;i<6;i++)
                cal_num[5-i] = decode_num[i];
        end
        default: begin
            for(i=0;i<6;i++)
                cal_num[i] = 0;
        end
    endcase
    case (opcode[2:0])
        3'b000: begin
            out_n = cal_num[2] - cal_num[1];
        end
        3'b001: begin
           out_n = cal_num[0] + cal_num[3];
        end
        3'b010: begin
            out_n = (cal_num[3]*cal_num[4])>>1;
        end
        3'b011: begin
            out_n = cal_num[1] + (cal_num[5]<<1);
        end
        3'b100: begin
            out_n = cal_num[1] & cal_num[2];
        end
        3'b101: begin
            out_n = ~cal_num[0];
        end
        3'b110: begin
            out_n = cal_num[3] ^ cal_num[4];
        end
        3'b111: begin
            out_n = cal_num[1]<<1;
        end
        default: begin
            out_n = 0;
        end
    endcase
end

endmodule

//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;
always @ (*) begin
    case(address)
        4'b0000:value = 5'd9;
        4'b0001:value = 5'd27;
        4'b0010:value = 5'd30;
        4'b0011:value = 5'd3;
        4'b0100:value = 5'd11;
        4'b0101:value = 5'd8;
        4'b0110:value = 5'd26;
        4'b0111:value = 5'd17;
        4'b1000:value = 5'd3;
        4'b1001:value = 5'd12;
        4'b1010:value = 5'd1;
        4'b1011:value = 5'd10;
        4'b1100:value = 5'd15;
        4'b1101:value = 5'd5;
        4'b1110:value = 5'd23;
        4'b1111:value = 5'd20;
        default: value = 0;
    endcase
end

endmodule
