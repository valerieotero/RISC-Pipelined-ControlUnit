//tester
module CUTester();
    wire [4:0] S;
    reg MOC = 1;
    reg Cond = 1;
    reg [31:0] IR;
    wire [4:0] NS;
    reg Clk = 0;
    reg Reset = 1;
    wire FR_Ld, RF_Ld, IR_Ld, MAR_Ld, MDR_Ld, RW, MOV, MA1, MA0, MB1, MB0, MC, MD, ME, OP4, OP3, OP2, OP1, OP0, Cin;
    initial begin
        IR = 32'b10000000100000010001000000000000; //add R-R
        repeat(2) begin
            repeat(10) begin
                Clk = ~Clk;
                #20;
                MOC = 1;
                Cond = 1;
                if(Clk) begin
                    $display("Current IR = %d", IR);
                    $display("CURRENT STATE = %d", S);
                    #5;
                    $display("NEW STATE = %d", test.NS);
                    $display("STATE SENT FROM STATE REGISTER = %d", statReg.S);
                    $display("STATE SIGNAL ENCODER OUTPUT:\n FR_Ld = %b,\n RF_Ld = %b,\n IR_Ld = %b,\n MAR_Ld = %b,\n MDR_Ld = %b,\n RW = %b,\n MOV = %b,\n MA1 = %b,\n MA0 = %b,\n MB1 = %b,\n MB0 = %b,\n MC = %b,\n MD = %b,\n ME = %b,\n OP4 = %b,\n OP3 = %b,\n OP2 = %b,\n OP1 = %b,\n OP0 = %b,\n Cin = %b\n", CSEncoder.FR_Ld, CSEncoder.RF_Ld, CSEncoder.IR_Ld, CSEncoder.MAR_Ld, CSEncoder.MDR_Ld, CSEncoder.RW, CSEncoder.MOV, CSEncoder.MA1, CSEncoder.MA0, CSEncoder.MB1, CSEncoder.MB0, CSEncoder.MC, CSEncoder.MD, CSEncoder.ME, CSEncoder.OP4, CSEncoder.OP3, CSEncoder.OP2, CSEncoder.OP1, CSEncoder.OP0, CSEncoder.Cin);
                end
                Reset = 0;
            end
        IR = 32'b10000110100000010001000000000000; //add immediate
        end   
    end

    ControlSignalEncoder CSEncoder(FR_Ld, RF_Ld, IR_Ld, MAR_Ld, MDR_Ld, RW, MOV, MA1, MA0, MB1, MB0, MC, MD, ME, OP4, OP3, OP2, OP1, OP0, Cin, S);
    StatusRegister statReg(S, NS, Clk, Reset);
    NextStateDecoder test(NS, S, MOC, Cond, IR);
endmodule

//Control Unit Components
module NextStateDecoder(output reg [4:0] NS, input wire [4:0] S, input MOC, Cond, input [31:0] IR);
always@(S, MOC, Cond, IR) begin
    #25;
        case(S)
            5'b00000:           //state 0
                NS = 5'b00001;  //NS 1
            5'b00001:           //state 1
                NS = 5'b00010;  //NS 2
            5'b00010:           //state 2
                NS = 5'b00011;  //NS 3
            5'b00011: begin     //state 3
                if(MOC)         //NS 4 | 3
                    NS = 5'b00100;
                else
                    NS = 5'b00011;
            end
            5'b00100: begin     //state 4
                if(Cond == 1)begin
                    if(IR[24:21] == 4'b0100) begin // If the condition is an add
                        if(IR[20] == 1)     //checks for shift
                            NS = 5'b01011;
                        else begin
                            if(IR[25] == 1) //checks for immediate
                                NS = 5'b01100;
                            else            //if no shift and no immediate the only possible add left is register to register
                                NS = 5'b01010;
                        end
                    end

                    if(IR[24:21] == 1010)  // If the condition is an CMP
                        NS = 5'b01101;

                    if(IR[24:21] == 1101)  // If the condition is an MOV
                        NS = 5'b01110;

                    if(IR[27:25] == 010) begin // If the condition is an LDR/STR immediate offset
                        if(IR[20])
                            NS = 5'b10100;
                        else
                            NS = 5'b10111;
                    end

                    if(IR[27:25] == 011) begin // If the condition is an LDR/STR register offset
                        if(IR[20])
                            NS = 5'b10100;
                        else
                            NS = 5'b10111;
                    end

                    if(IR[27:25] == 100) begin // If the condition is an LDR/STR multiple
                        if(IR[20])
                            NS = 5'b10100;
                        else
                            NS = 5'b10111;
                    end

                    if(IR[27:25] == 101) begin // If the condition is a branch
                        if(IR[24] == 0)
                            NS = 5'b11110;
                    end
                end
                else
                    NS = 5'b00001;
            end
            5'b01010: //state 10
                NS = 5'b00001;
            5'b01011: //state 11
                NS = 5'b00001;
            5'b01100: //state 12
                NS = 5'b00001;
            5'b01101: //state 13
                NS = 5'b00001;
            5'b01110: //state 14
                NS = 5'b00001;   
            5'b10100: //state 20
                NS = 5'b10101;
            5'b10101: //state 21
                NS = 5'b10110;
            5'b10110: begin//state 22
                if(MOC)
                    NS = 5'b10111;
                else
                    NS = 5'b10110;
            end
            5'b10111: //state 23
                NS = 5'b00001;
            5'b11100: begin//state 28
                if(MOC)
                    NS = 5'b00001;
                else
                    NS = 5'b11100;
            end
            5'b11110: //state 30
                NS = 5'b00001;
        endcase
    end
endmodule

module StatusRegister(output reg [4:0] S, input [4:0] D, input Clk, Reset);
        always@(D, Clk, Reset) begin
            if (Clk == 1 && Reset == 1) begin
                S <= 5'b00000;
            end
            else if (Reset == 0 && Clk == 1) begin
                S <= D;
            end
        end
endmodule

module ControlSignalEncoder(output reg FR_Ld, RF_Ld, IR_Ld, MAR_Ld, MDR_Ld, RW, MOV, MA1, MA0, MB1, MB0, MC, MD, ME, OP4, OP3, OP2, OP1, OP0, Cin, input wire [4:0] S);
    always@(S) begin
        case(S)
        5'b0000: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 1;
            MB0 = 1;
            MC = 1;
            MD = 1;
            ME = 0;
            OP4 = 0;
            OP3 = 1;
            OP2 = 1;
            OP1 = 0;
            OP0 = 1;
        end
        5'b00001: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 1;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 1;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 1;
            ME = 0;
            OP4 = 1;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b00010: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 1;
            MOV = 1;
            MA1 = 1;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 1;
            MD = 1;
            ME = 0;
            OP4 = 1;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 1;
        end
        5'b00011: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 1;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 1;
            MOV = 1;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b00100: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b01010: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b01011: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b01100: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b01101: begin
            FR_Ld = 1;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b01110: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b10100: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 1;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 1;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 1;
            OP1 = 0;
            OP0 = 0;
        end
        5'b10101: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 1;
            MOV = 1;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b10110: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 1;
            RW = 1;
            MOV = 1;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b10111: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 0;
            MD = 1;
            ME = 0;
            OP4 = 0;
            OP3 = 1;
            OP2 = 1;
            OP1 = 0;
            OP0 = 1;
        end
        5'b11001: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 1;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 1;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 1;
            OP1 = 0;
            OP0 = 0;
        end
        5'b11010: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 1;
            RW = 0;
            MOV = 0;
            MA1 = 0;
            MA0 = 1;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 1;
            ME = 1;
            OP4 = 1;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b11011: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 1;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b11100: begin
            FR_Ld = 0;
            RF_Ld = 0;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 1;
            MA1 = 0;
            MA0 = 0;
            MB1 = 0;
            MB0 = 0;
            MC = 0;
            MD = 0;
            ME = 0;
            OP4 = 0;
            OP3 = 0;
            OP2 = 0;
            OP1 = 0;
            OP0 = 0;
        end
        5'b11110: begin
            FR_Ld = 0;
            RF_Ld = 1;
            IR_Ld = 0;
            MAR_Ld = 0;
            MDR_Ld = 0;
            RW = 0;
            MOV = 0;
            MA1 = 1;
            MA0 = 0;
            MB1 = 0;
            MB0 = 1;
            MC = 1;
            MD = 1;
            ME = 0;
            OP4 = 1;
            OP3 = 0;
            OP2 = 0;
            OP1 = 1;
            OP0 = 0;
        end
        endcase
    end
endmodule
