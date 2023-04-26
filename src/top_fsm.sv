module top_fsm 
# (
    parameter clk_freq = 50_000_000,
    parameter stable_time = 10,
    parameter flash_speed = 23
)
(
    input logic clk,
    input logic [3:0] btn,
    output logic [3:0] led,
    output logic [2:0] rgb
);

    logic [3:0] btn_debounce;
    logic [3:0] btn_pulse;

genvar k;
generate
    for (k = 0; k<4; k++) begin
    debounce
        #(
            .clk_freq(clk_freq),
            .stable_time(stable_time)
        )
        db_btn_i
        (
            .clk(clk),
            .rst(0),
            .button(btn[k]),
            .result(btn_debounce[k])
        ); 

        single_pulse_detector sp_btn_i (
            .clk(clk),
            .rst(0),
            .input_signal(btn_debounce[k]),
            .output_pulse(btn_pulse[k])
        );
    end   
endgenerate
lock_fsm 
#(
    .flash_speed(flash_speed)
)
lock_fsm_i
(
    .clk(clk),
    .nwse(btn_pulse),
    .led(led),
    .rgb(rgb)
);



endmodule