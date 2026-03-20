`timescale 1ns/1ns

module Traffic_tb();
    logic clk_100MHz;
    logic TAORB;
    logic reset;
    logic [5:0] led;

    Traffic_top uut (
        .clk_100MHz(clk_100MHz),
        .TAORB(TAORB),
        .reset(reset),
        .led(led)
    );

    // 100MHz Clock
    always #5 clk_100MHz = ~clk_100MHz;

    initial begin
        clk_100MHz = 0;
        reset = 1;
        TAORB = 1; // A yolu dolu başlasın
        #50 reset = 0;

        // S0 (GREENRED) 
        #10000;
        
        // S0 -> S1 (5 second) -> S2
        TAORB = 0; 
        
        // S2 (REDGREEN)
        #10000; 
        
        // S2 -> S3 (5 second) -> S0
        TAORB = 1; 
        #10000;
        $stop;
    end
endmodule