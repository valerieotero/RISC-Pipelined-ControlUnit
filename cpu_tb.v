// `include "PPU.v"

// module PPU_tb;

    
//     /*-------------------------------------- PRECHARGE INSTRUCTION RAM --------------------------------------*/

//     integer file, fw, code, i; reg [31:0] data;
//     reg clk = 0;
//     reg Reset = 0;
//     reg [31:0] PCO;
//     reg [31:0] Address = 32'b0; 
//     wire [31:0] DataOut;
//     wire ID_B_instr, ID_mem_read_write, EX_Shift_imm, EX_load_instr, EX_RF_Enable,  EX_mem_size, EX_mem_read_write, ID_mem_size, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size, WB_load_instr, WB_RF_Enable, WB_mem_read_write;
//     wire [6:0] C_U_out;
//     wire [31:0] mux_out_1_A, mux_out_2_B, mux_out_3_C, mux_out_1, mux_out_2, mux_out_3, A_O, MEM_A_O, MEM_MUX3, Data_RAM_Out, WB_A_O, WB_Data_RAM_Out, EX_Bit11_0;
//     wire [3:0]  EX_Bit15_12, EX_ALU_OP, ID_Bit15_12, cc_main_alu_out,MEM_Bit15_12,WB_Bit15_12;
//     wire [11:0]  ID_Bit11_0;
//     wire [7:0] EX_addresing_modes, ID_addresing_modes;
    
//     initial
//         begin
//         file = $fopen("ramintr.txt","rb");
//         Address = 32'b0; // 32'b0;
//             while (!$feof(file)) begin //while not the end of file
//             code = $fscanf(file, "%b", data);
//             ram1.Mem[Address] = data;
//             Address = Address + 1;
//             // clk = ~clk;
//         end

//     $fclose(file);  
//     end
    
//     inst_ram256x8 ram1 (DataOut, Address);

//     /*-------------------------------------- Clock --------------------------------------*/

//     main PPU(clk, Reset); //.clk(clk), .Reset(Reset));
    
//     // always@(clk)
//     initial begin
        
//         $display("\n\n                    ------------------ID State-------------------            ------------------EX State------------------           --------MEM State------          -------WB State-------");
//         $display("         PC      B_instr | shift_imm |   alu  | load | R F | mem_r_w           shift_imm | alu  | load | R F | mem_r_w                load | R F | mem_r_w            load | R F | mem_r_w ");
//         PCO = 32'b0; 
//     end
//     // begin      
//     always begin
//         $display("%d           %b   |     %b     |  %b  |  %b   |  %b  |  %b                       %b  | %b |   %b  |  %b  | %b                         %b |  %b  | %b                     %b |  %b  |  %b",  PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, WB_load_instr, WB_RF_Enable, WB_mem_read_write);

//         // Address = #1 32'b11100000100000100101000000000101; //1100000100000100101000000000101;
//         // clk = ~clk;          
                  
//         // $display("%d        %b     |       %b      |   %b  |     %b   |   %b   |  %b                      %b  |   %b  |    %b    |   %b   | %b                         %b |    %b   | %b                        %b |   %b   |  %b", PCO, ID_B_instr, C_U_out[6], C_U_out[5:2], C_U_out[1], C_U_out[0], ID_mem_read_write,  EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,EX_mem_read_write, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, WB_load_instr, WB_RF_Enable, WB_mem_read_write);
//         #5;
//         PCO = PCO + 32'd4;
  
//         // Address =  32'b11011011000000000000000000000001;
            
        
//     end 
    
//     // inst_ram256x8 ram1 (DataOut, Address);
//     control_unit control_unit1(ID_B_instr, ID_mem_read_write, C_U_out, clk, DataOut);
//     register_file register_file_1(PA, PB, PD, PW, PCI, PCO, WB_Bit15_12_out, ID_Bit19_16, ID_Bit3_0, SD, RFLd, PC_RF_ld, clk, Reset); //falta RW = WB_Bit15_12_out

//     // ID_EX_pipeline_register ID_EX_pipeline_register(mux_out_1_A, mux_out_2_B, mux_out_3_C, EX_Bit15_12, EX_Shift_imm, EX_ALU_OP, EX_load_instr, EX_RF_Enable,
//     //                                     EX_Bit11_0, EX_addresing_modes, EX_mem_size, EX_mem_read_write,

//     //                                     mux_out_1, mux_out_2, mux_out_3, ID_Bit15_12, C_U_out, ID_Bit11_0, ID_addresing_modes, ID_mem_size, ID_mem_read_write, clk);
//     // EX_MEM_pipeline_register EX_mem_pipeline_register(mux_out_3_C, A_O, EX_Bit15_12, cc_main_alu_out, EX_load_instr, EX_RF_Enable, clk, EX_mem_read_write, EX_mem_size,
//     //                             MEM_A_O, MEM_MUX3, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, MEM_mem_read_write, MEM_mem_size);
//     // MEM_WB_pipeline_register MEM_WB_pipeline_register(MEM_A_O, Data_RAM_Out, MEM_Bit15_12, MEM_load_instr, MEM_RF_Enable, clk, WB_A_O, WB_Data_RAM_Out, WB_Bit15_12, WB_load_instr, WB_RF_Enable);
            
// endmodule
