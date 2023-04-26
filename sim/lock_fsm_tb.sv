`timescale 1ns/1ps
module lock_fsm_tb;
    parameter flash_speed_tb = 1;
    logic clk_tb;
    logic [3:0] nwse_tb;
    logic [3:0] led_tb;
    logic [2:0] rgb_tb;

    logic [3:0] n = 4'h8;
    logic [3:0] w = 4'h4;
    logic [3:0] s = 4'h2;
    logic [3:0] e = 4'h1;

    integer duty_cycle = 1;
    integer clock_cycle = 2*duty_cycle;
    integer button_pressed = clock_cycle;
    integer wait_time = 3*clock_cycle;

    lock_fsm 
    #(
        .flash_speed(flash_speed_tb)
    )
    uut
    (
        .clk(clk_tb),
        .nwse(nwse_tb),
        .led(led_tb),
        .rgb(rgb_tb)
    );

    always #duty_cycle clk_tb = ~clk_tb;

 initial begin
        nwse_tb = 0;
        clk_tb = 0; #clock_cycle;
        #wait_time;

        // correct
        // ---------------------------
        nwse_tb = s;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = w;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = w;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        #50;

        // reset
        // ---------------------------
        nwse_tb = n;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        // r2
        // ---------------------------
        nwse_tb = s;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        #10;

        // wrong
        // ---------------------------
        nwse_tb = s;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = n;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        nwse_tb = w;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        // stay in alarm
        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        #40;

        // go to a1
        nwse_tb = w;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        #70;
        
       // back to alarm
        nwse_tb = s;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        // go to a1
        nwse_tb = w;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;
        #wait_time;

        // go to reset
        nwse_tb = e;
        #button_pressed;
        nwse_tb = 0;
        #clock_cycle;

        #10;
        $stop;
    end
endmodule