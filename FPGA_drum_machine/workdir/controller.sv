module controller(input logic clk, input logic rst, input logic set_edit, input logic set_play, input logic set_raw,
                  output logic [1:0] mode);
    always_ff @ (posedge clk, posedge rst)begin
        if (rst == 1'b1)
            mode <= 2'b00;
        else if (set_edit == 1'b1)
            mode <= 2'b00;
        else if (set_play == 1'b1)
            mode <= 2'b01;
        else if (set_raw == 1'b1)
            mode <= 2'b10;
    end
endmodule