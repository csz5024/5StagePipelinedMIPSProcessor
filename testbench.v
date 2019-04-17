`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2019 06:19:51 PM
// Design Name: 
// Module Name: testbench
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


module testbench(
    );
    
    reg clk;
    reg update;
    wire[31:0] pc;
    wire[31:0] newPc;
    wire[31:0] do2;
    wire[31:0] do3;
    wire[1:0] aluc;
    wire[1:0] ealuc;
    wire[4:0] wn;
    wire[4:0] ewn;
    wire[4:0] mwn;
    wire[4:0] wwn;
    wire[3:0] alufour;
    wire[5:0] eimm;
    wire[31:0] QA;
    wire[31:0] eQA;
    wire[31:0] QB;
    wire[31:0] eQB;
    wire[31:0] imm2;
    wire[31:0] eimm2;
    wire[31:0] select1; 
    wire[31:0] er;
    wire[31:0] mr;
    wire[31:0] meQB;
    wire[31:0] doodle;
    wire[31:0] wdoodle;
    wire[31:0] wr;
    wire[31:0] d;
    wire wreg, m2reg, wmem, aluimm, regrt, ewreg, em2reg, ewmem, ealuimm, mwreg, mm2reg, mwmem, wm2reg, wwreg;
    
    ProgramCounter pc1(newPc, clk, pc);
    adder adder1(pc, newPc);
    InstrFetch fetch(pc, do2);
    IFID iffy(do2, clk, do3);
    ControlUnit control(do3, wreg, m2reg, wmem, aluc, aluimm, regrt);
    RorI dubya(do3, regrt, wn);
    InstrReg inst(do3, clk, wwreg, wwn, d, QA, QB);
    signext sign(do3, imm2);
    IDEXE idexe(clk, wreg, m2reg, wmem, aluc, aluimm, wn, QA, QB, do3, imm2, ewreg, em2reg, ewmem, ealuc, ealuimm, ewn, eQA, eQB, eimm, eimm2);
    ALUcontrol aluco(ealuc, eimm, alufour);
    eQBorIMM2 qborI(ealuimm, eQB, eimm2, select1);
    ALU alu(eQA, select1, alufour, er);
    EXEMEM exemem(clk, ewreg, em2reg, ewmem, ewn, er, eQB, mwreg, mm2reg, mwmem, mwn, mr, meQB);
    DataMem datamem(mwmem, mr, meQB, doodle);
    MEMWB memwb(clk, mwreg, mm2reg, mwn, mr, doodle, wwreg, wm2reg, wwn, wr, wdoodle);
    wb wbwb(wr, wdoodle, wm2reg, d);
    initial begin
        clk = 1;
        
        //wwreg = 0;
        //wwn = 5'b0;
        //d = 31'b0;
    end
    always begin
        #1;
        clk = ~clk;
    end
    
endmodule
