module sequence_editor(input logic clk, input logic rst, input logic [1:0] mode, input logic [2:0] set_time_idx, input logic [3:0] tgl_play_smpl, 
                       output logic [3:0] seq_smpl_1, seq_smpl_2, seq_smpl_3, seq_smpl_4, seq_smpl_5, seq_smpl_6, seq_smpl_7, seq_smpl_8);
    
    logic [3:0] seq_array [7:0];
    //assign seq_array = {seq_smpl_8, seq_smpl_7, seq_smpl_6, seq_smpl_5, seq_smpl_4, seq_smpl_3, seq_smpl_2, seq_smpl_1};
    assign seq_smpl_1 = seq_array[0];
    assign seq_smpl_2 = seq_array[1];
    assign seq_smpl_3 = seq_array[2];
    assign seq_smpl_4 = seq_array[3];
    assign seq_smpl_5 = seq_array[4];
    assign seq_smpl_6 = seq_array[5];
    assign seq_smpl_7 = seq_array[6];
    assign seq_smpl_8 = seq_array[7];
    always_ff @ (posedge clk, posedge rst)begin
        if(rst == 1'b1) begin
            seq_array[0] <= 4'b0;
            seq_array[1] <= 4'b0;
            seq_array[2] <= 4'b0;
            seq_array[3] <= 4'b0;
            seq_array[4] <= 4'b0;
            seq_array[5] <= 4'b0;
            seq_array[6] <= 4'b0;
            seq_array[7] <= 4'b0;
        end
        else if(mode == 2'b00)begin
            // seq_array[set_time_idx][0] <= seq_array[set_time_idx][0] ^ tgl_play_smpl[0];
            // seq_array[set_time_idx][1] <= seq_array[set_time_idx][1] ^ tgl_play_smpl[1];
            // seq_array[set_time_idx][2] <= seq_array[set_time_idx][2] ^ tgl_play_smpl[2];
            // seq_array[set_time_idx][3] <= seq_array[set_time_idx][3] ^ tgl_play_smpl[3];
            seq_array[set_time_idx] <= seq_array[set_time_idx] ^ tgl_play_smpl;
        end
    end
endmodule