module top_fsm_tb;
    parameter clk_freq_tb = 1024;
    parameter stable_time_tb = 5;
    parameter flash_speed_tb = 1;
    logic clk_tb;
    logic [3:0] btn_tb;
    logic [3:0] led_tb;
    logic [2:0] rgb_tb;

    logic [3:0] n = 4'h8;
    logic [3:0] w = 4'h4;
    logic [3:0] s = 4'h2;
    logic [3:0] e = 4'h1;

    integer duty_cycle = 1;
    integer clock_cycle = 2*duty_cycle;
    integer button_pressed = (10+(stable_time_tb*clock_cycle));
    integer wait_time = 3*clock_cycle;

    top_fsm 
    #(
        .clk_freq(clk_freq_tb),
        .stable_time(stable_time_tb),
        .flash_speed(flash_speed_tb)
    )
    uut
    (
        .clk(clk_tb),
        .btn(btn_tb),
        .led(led_tb),
        .rgb(rgb_tb)
    );

    always #duty_cycle clk_tb = ~clk_tb;

    initial begin
        btn_tb = 0;
        clk_tb = 0; #clock_cycle;
        #button_pressed;

        // correct
        // ---------------------------
        btn_tb = s;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = w;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = w;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        #50;

        // reset
        // ---------------------------
        btn_tb = n;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        // r2
        // ---------------------------
        btn_tb = s;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        #10;

        // wrong
        // ---------------------------
        btn_tb = s;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = n;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        btn_tb = w;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        // stay in alarm
        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        #40;

        // go to a1
        btn_tb = w;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        #70;

       // back to alarm
        btn_tb = s;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        // go to a1
        btn_tb = w;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        // go to reset
        btn_tb = e;
        #button_pressed;
        btn_tb = 0;
        #clock_cycle;

        #10;
        $stop;
    end
endmodule