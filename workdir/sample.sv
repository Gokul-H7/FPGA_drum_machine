module sample #(parameter SAMPLE_FILE = "../audio/kick.mem", parameter SAMPLE_LEN = 4000)
               (input logic clk, input logic rst, input logic enable,
                output logic [7:0] out);
    logic [7:0] audio_mem [4095:0];
    logic [11:0] counter;
    logic prev_en;
    initial $readmemh(SAMPLE_FILE, audio_mem, 0, SAMPLE_LEN);
    always_ff @ (posedge clk, posedge rst)begin
        
        if(rst == 1'b1)begin
            prev_en <= 0;
            counter <= 0;
            out <= 0;
        end
        else if(prev_en == 1'b1 && enable == 1'b1)begin
            prev_en <= enable;
            out <= audio_mem[counter];
            if (counter == SAMPLE_LEN)
                counter <= 0;
            else
                counter <= counter + 1;

        end
        else if(prev_en == 1'b1 && enable == 1'b0)begin
            prev_en <= enable;
            out <= audio_mem[counter];
            counter <= 0;
        end
        else begin
            prev_en <= enable;
            out <= audio_mem[counter];
        end
    end
endmodule