module sequencer(input logic clk, input logic rst, input logic srst, input logic go_left, input logic go_right, 
                 output logic [7:0] seq_out);
    logic [7:0] next_seq_out;
    always_ff @ (posedge clk, posedge rst)begin
        if(rst == 1'b1)
            seq_out <= 8'b10000000;
        else
            seq_out <= next_seq_out;
    end
    always_comb begin
        next_seq_out = seq_out;
        if(srst == 1'b1)
            next_seq_out = 8'b10000000;
        else if(go_left == 1'b1)
            if(seq_out == 8'b10000000)
              next_seq_out = 8'b00000001;
            else
              next_seq_out = seq_out << 1;
        else if(go_right == 1'b1)
            if(seq_out == 8'b00000001)
              next_seq_out = 8'b10000000;
            else
              next_seq_out = seq_out >> 1;
    end
endmodule