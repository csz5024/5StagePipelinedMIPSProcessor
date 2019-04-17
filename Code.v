`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2019 07:49:02 PM
// Design Name: 
// Module Name: lab03
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ProgramCounter(
    input [31:0] newPc,
    input clk,
    output reg [31:0] Pc);
    
    always @ (posedge clk) begin
        Pc = newPc;
    end
endmodule
 
module adder (
    input [31:0] Pc,
    output reg [31:0] newPc);
    
    initial begin
        newPc = 32'd100;
    end
    always @ (*) begin
        newPc = Pc + 4;
    end
endmodule


module IFID(
    input [31:0] doin,
    input clk,
    output reg [31:0] doout);
    
    always @ (posedge clk) begin
        doout = doin;
    end
endmodule


module InstrFetch(
    input [31:0] a,
    output reg [31:0] do
    );
    
    reg [31:0]mem[0:128];

    initial
    begin    
        mem[32'd100] = 32'h8C220000;
        mem[32'd104] = 32'h8C230004;
        mem[32'd108] = 32'h8C240008;
        mem[32'd112] = 32'h8c25000C;
        mem[32'd116] = 32'h004A3020;
    end
    
    always @ (*)
    begin
        //$display("mem[a] = %h", mem[a]);
        do = mem[a];
        //$display("do = %h", do);
    end
endmodule


module ControlUnit(
    //just output values, not used
    input [31:0] op,
    //input [31:0] func,
    output reg wreg,
    output reg m2reg,
    output reg wmem,
    output reg[1:0] aluc,
    output reg aluimm,
    output reg regrt    
    );
    
    reg [5:0] opcode;
    
    always @ (*)
    begin 
        opcode = op[31:26];
        case(opcode)
            //R type instruction
            6'b000000:
            begin
                regrt=0;
                aluc=2'b10;
                wreg=1;
                aluimm=0;
                wmem=0;
                m2reg=0;
            end
            //I type instruction
            default:
            begin
                regrt=1;
                aluc=2'b00;
                wreg=1;
                aluimm=1;
                wmem=0;
                m2reg=1;
            end
        endcase
    end
endmodule


module RorI(
    input [31:0] rd,
    //input [31:0] rt,
    input regrt,
    output reg[4:0] stuff
);
    wire[4:0] rd2;
    wire[4:0] rt;
    assign rd2 = rd[15:11];
    assign rt = rd[20:16];

    always @ (*)
    begin
        case(regrt)    
            1'b0:stuff=rd2;
            1'b1:stuff=rt;
        endcase
    end
endmodule


module InstrReg(
    input [31:0] rna, //address
    input clk,
    input we,
    //wn is register write
    input [4:0] wn,
    //d is data
    input [31:0] d,
    output reg[31:0] QA,
    output reg[31:0] QB
    );
    
    reg[4:0] rnaa;
    reg[4:0] rnb;
    reg [31:0]ireg[0:31];
    integer i;

    
    initial 
    begin        
        for (i=0; i < 32; i=i+1) begin
            ireg[i]=32'd0; 
        end
    end
        
    
    always @ (posedge clk)
    begin
        
        case(we)
            //J and sw type
            1'b0:ireg[wn]=d;
            //R and lw type
            1'b1:ireg[wn]=d;
        endcase
        
    end
    always @ (negedge clk) begin
        rnaa = rna[25:21];
        rnb = rna[20:16];
        QA = ireg[rnaa];
        QB = ireg[rnb];
        $display("%b %b",ireg[rnaa], ireg[rnb]);
    end
    
endmodule    
    
    
module signext(
    input [31:0] imm,
    output reg[31:0] imm2 
    );
    
    reg[15:0] immtemp;
    reg[31:0] temp;
    
    always @ (*)
    begin
        immtemp = imm[15:0];   
        immtemp = immtemp>>15;
        case(immtemp)
            16'd1:
            begin
                temp[15:0] = imm[15:0];
                temp[31:16] = 16'h1111;
                imm2 = temp;
            end
            default:
            begin
                temp[15:0] = imm[15:0];
                temp[31:16] = 16'h0000;
                imm2 = temp;
            end
        endcase
     end
  
endmodule


module IDEXE(
    input clk,
    input wreg,
    input m2reg,
    input wmem,
    input [1:0] aluc,
    input aluimm,
    input [4:0] writeback,
    input [31:0] QA,
    input [31:0] QB,
    input [31:0] imm,
    input [31:0] immext,
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg[1:0] ealuc,
    output reg ealuimm,
    output reg[4:0] wn,
    output reg[31:0] eQA,
    output reg[31:0] eQB,
    output reg[5:0] eimm,
    output reg[31:0] eimm2
    );

    always @ (posedge clk) begin
        ewreg=wreg;
        em2reg=m2reg;
        ewmem=wmem;
        ealuc=aluc;
        ealuimm=aluimm;
        wn=writeback;
        eQA=QA;
        eQB=QB;
        eimm2=immext;
        eimm=imm[5:0];
    end
endmodule

module eQBorIMM2(
    input ealuimm,
    input [31:0] eQB,
    input [31:0] eimm2,
    output reg[31:0] select
    );

    always @ (*) begin
    case(ealuimm)
        1'b0:select=eQB;
        1'b1:select=eimm2;
    endcase
    end
endmodule

module ALUcontrol(
    input [1:0] aluop,
    input [5:0] func,
    output reg[3:0] aluc
    );
    
    always @ (*)
    begin
        case(aluc)
            //branch
            2'b01:aluc=4'b0110; //subtract
            //R type
            2'b10:
            begin
                case(func)
                    6'b100000:aluc=4'b0010; //add
                    6'b100010:aluc=4'b0110; //subtract
                    6'b100100:aluc=4'b0000; //AND
                    6'b100101:aluc=4'b0001; //OR
                    6'b101010:aluc=4'b0111; //slt
                endcase
            end
            //I type
            default: aluc=4'b0010; //add
        endcase
    end
endmodule


module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output reg [31:0] r
);
    always @ (*) begin
        case(aluc)
            4'b0010: r=a+b; //add
            4'b0110: r=a-b; //subtract
            4'b0000: r=a&b; //and
            4'b0001: r=a|b; //or
            4'b0111: r=a<b; //slt
        endcase
    end
endmodule

module EXEMEM(
    input clk,
    input ewreg,
    input em2reg,
    input ewmem, 
    input [4:0] ewn,
    input [31:0] er,
    input [31:0] eeQB,
    output reg mwreg,
    output reg mm2reg,
    output reg mwmem,
    output reg[4:0] mwn,
    output reg[31:0] mr,
    output reg[31:0] meQB
);

    always @ (posedge clk) begin
        mwreg=ewreg;
        mm2reg=em2reg;
        mwmem=ewmem;
        mwn=ewn;
        mr=er;
        meQB=eeQB;
    end

endmodule

module DataMem(
    input we,
    input [31:0] a,
    input [31:0] di,
    output reg[31:0] do
    );
    
    reg [31:0]dmem[0:128];
    
    initial
    begin
        dmem[32'd0] = 32'hA00000AA;
        dmem[32'd4] = 32'h10000011;
        dmem[32'd8] = 32'h20000022;
        dmem[32'd12] = 32'h30000033;
        dmem[32'd16] = 32'h40000044;
        dmem[32'd20] = 32'h50000055;
        dmem[32'd24] = 32'h60000066;
        dmem[32'd28] = 32'h70000077;
        dmem[32'd32] = 32'h80000088;
        dmem[32'd36] = 32'h90000099;
    end
    
    always @ (*) begin
        //perform mad combos here
        case(we)
            // load word
            1'b0:
            begin
                do=dmem[a];
            end
            //store word
            1'b1:
            begin
                dmem[a]=di;
            end
        endcase
    end
endmodule

module MEMWB(
    input clk,
    input mwreg,
    input mm2reg,
    input [4:0] mwn,
    input [31:0] mr,
    input [31:0] do,
    output reg wwreg,
    output reg wm2reg,
    output reg[4:0] wn,
    output reg[31:0] wr,
    output reg[31:0] wdo
    );

    always @ (posedge clk) begin
        wwreg=mwreg;
        wm2reg=mm2reg;
        wn=mwn;
        wr=mr;
        wdo=do;
    end

endmodule

module wb(
    input [31:0] wr,
    input [31:0] wdo,
    input wm2reg,
    output reg[31:0] d
    );
    
    // R type m2reg is 0
    always @ (*) begin
        case(wm2reg)
            1'b0:d=wr;
            1'b1:d=wdo;
        endcase
    end
endmodule