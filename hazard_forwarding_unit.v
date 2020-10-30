module HazardDetection
(
	output reg IF_ID_Ld_out, RF_PC_Ld_out, Control_Unit_Mux_Signal_out,
    input is_LoadStore_instr_in_MEM, is_Load_instr_in_IF, was_prev_instr_Store, has_prev_instr_left_WB
);
	always @(*) begin 
                                                       
        if(is_LoadStore_instr_in_MEM == 1'b1 //Structural Hazard   
           || (is_Load_instr_in_IF == 1'b1 && (was_prev_instr_Store==1'b1 && has_prev_instr_left_WB ==1'b1))) //RAW Hazard 
        // || (a load instr is in IF pipe && (prev instr was a store && has left WB pipe))        
        begin
			IF_ID_Ld_out <= 1'b1;
			RF_PC_Ld_out <= 1'b1;
			Control_Unit_Mux_Signal_out <= 1'b1;
		end else begin
			IF_ID_Ld_out <= 1'b0;
			RF_PC_Ld_out <= 1'b0;
			Control_Unit_Mux_Signal_out <= 1'b0;
		end	

        //mesh forwarding unit


	end
endmodule


module ForwardingUnit();  
endmodule