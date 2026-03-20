module Traffic(
    input logic clk,rst,TAORB,
    output logic [5:0] led
    );

    typedef enum bit [1:0] { 

        GREENRED = 2'b00,
        YELLOWRED = 2'b01,
        REDGREEN = 2'b10,
        REDYELLOW = 2'b11

    } state_t;

    state_t state_reg;
    state_t state_next;
    logic [2:0] TIMER;

    always_ff@(posedge clk or posedge rst) begin
        if(rst) begin
            state_reg <= GREENRED;
            TIMER <= 3'b000; //resets the TIMER in rst state 
        end
        else begin
            state_reg <= state_next;
            // waits 5 second in the YELLOWRED and REDYELLOW states
            if(state_next == YELLOWRED || state_next == REDYELLOW)
            TIMER <= TIMER + 1;
            else
            TIMER <= 3'b000;
        end
    end

    always_comb begin 

    case (state_reg)
        GREENRED:begin
            led=6'b001100;
            if (!TAORB) begin
                state_next = YELLOWRED;
            end
            else begin
                state_next = GREENRED;
            end
        end

        YELLOWRED:begin
            led = 6'b010100; 
            if(TIMER == 5)
            state_next = REDGREEN;
            else
            state_next = YELLOWRED;
        end

        REDGREEN:begin
            led = 6'b100001;
            if(TAORB)
            state_next = REDYELLOW;
            else
            state_next = REDGREEN;
        end

        REDYELLOW:begin
            led = 6'b100010;

            if(TIMER == 5)
            state_next = GREENRED;
            else
            state_next = REDYELLOW;
        end
        default:state_next = GREENRED;
    endcase
    end
endmodule

module halfsecond(
    input logic clk_100MHz,reset,
    output logic clk_half_sec
);

logic [25:0] r_count=0;
logic r_half=0;

always_ff @(posedge clk_100MHz or posedge reset) begin
    
    if(reset) begin
    r_count <= 26'b0;
    r_half  <= 1'b0;
    end
    else begin
        if(r_count == 49999999) begin
            r_count <= 26'b0;
            r_half <= ~r_half;
        end
    else 
    r_count <= r_count+1;
    end
end
assign clk_half_sec = r_half;
endmodule

module Traffic_top(
input logic clk_100MHz,
input logic TAORB, 
input logic reset, 
output logic [5:0] led
);

wire w_1Hz;

Traffic r4(
.clk(w_1Hz), 
.rst(reset), 
.TAORB (TAORB), 
.led (led)    
);

halfsecond uno (
.clk_100MHz(clk_100MHz),
.reset(reset),
.clk_half_sec (w_1Hz) 
);

endmodule