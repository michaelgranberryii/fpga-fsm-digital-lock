`timescale 1ns/1ps
module lock_fsm 
#(
    parameter flash_speed = 23
)
(
    input logic clk,
    input logic [3:0] nwse,
    output logic [3:0] led,
    output logic [2:0] rgb
);
    typedef enum {lock, s1, s2, s3, unlock, w1, w2, w3, alarm, a1, r1, r2, r3, reset } state;
    state currstate;

    logic [3:0] led_reg;
    logic [2:0] rgb_reg;
    logic [flash_speed:0] count_flash;
    logic [(1+flash_speed):0] count_flash2;

    // FSM
    always_ff @(posedge clk) begin : fsm_state
            case (currstate)
        
                // lock
                lock: begin
                    if (nwse[1]) begin // S
                        currstate <= s1;
                    end
                    else if ((nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= w1;
                    end
                    else if (nwse[0]) begin
                        currstate <= r1;
                    end
                    else begin
                        currstate <= lock;
                    end
                end 

                // reset
                r1: begin
                    if (nwse[0]) begin
                        currstate <= reset;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= w2;
                    end
                    else begin
                        currstate <= r1;
                    end
                end
                r2: begin
                    if (nwse[0]) begin
                        currstate <= reset;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= w3;
                    end
                    else begin
                        currstate <= r2;
                    end
                end
                r3: begin
                    if (nwse[0]) begin
                        currstate <= reset;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= alarm;
                    end
                    else begin
                        currstate <= r2;
                    end
                end
                reset: begin
                        currstate <= lock;
                end

                // correct sequence
                s1: begin
                    if (nwse[2]) begin // W
                        currstate <= s2;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h8)) begin
                        currstate <= w2;
                    end
                    else if (nwse[0]) begin
                        currstate <= r2;
                    end
                    else begin
                        currstate <= s1;
                    end
                end
                s2: begin
                    if (nwse[0]) begin // E
                        currstate <= s3;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= w3;
                    end
                    else begin
                        currstate <= s2;
                    end
                end
                s3: begin
                    if (nwse[2]) begin // W
                        currstate <= unlock;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h1) || (nwse == 4'h8)) begin
                        currstate <= alarm;
                    end
                    else if (nwse[0]) begin
                        currstate <= reset;
                    end
                    else begin
                        currstate <= s3;
                    end
                end

                // unlock
                unlock: begin
                    if(|nwse) begin
                        currstate <= lock;
                    end
                end

                // wrong sequence
                w1: begin
                    if (nwse[0]) begin
                        currstate <= r2;
                    end
                    else if (|nwse) begin
                        currstate <= w2;
                    end
                end
                w2: begin
                    if (nwse[0]) begin
                        currstate <= r3;
                    end
                    else if (|nwse) begin
                        currstate <= w3;
                    end
                end
                w3: begin
                    if (|nwse) begin
                        currstate <= alarm;
                    end
                end

                // alarm
                alarm: begin
                    if ((nwse == 4'h4)) begin
                        currstate <= a1;
                    end
                    else begin
                        currstate <= alarm;
                    end
                end
                a1: begin
                    if ((nwse == 4'h1)) begin
                        currstate <= reset;
                    end
                    else if ((nwse == 4'h2) || (nwse == 4'h4) || (nwse == 4'h8)) begin
                        currstate <= alarm;
                    end
                    else begin
                        currstate <= a1;
                    end
                end

                // default
                default: begin
                    currstate <= lock;
                end
            endcase
    end // always_ff block

    // Flashing lights
    always_ff @( posedge clk ) begin : flash_light 
        if (currstate == unlock) begin
            count_flash <= count_flash + 1;
            if (count_flash == 0) begin
                led_reg <= ~led_reg;
            end
        end
        else if (currstate == alarm) begin
            count_flash <= count_flash + 1;
            if (count_flash == 0) begin
                rgb_reg[2] <= ~rgb_reg[2];
            end
        end
        else if (currstate == a1) begin
            count_flash2 <= count_flash2 + 1;
            if (count_flash2 == 0) begin
                rgb_reg[2] <= ~rgb_reg[2];
            end
        end
        else begin
            led_reg <= 4'h0;
            rgb_reg <= 3'h0;
            count_flash <= 0;
            count_flash2 <= 0;
        end
    end

    // FSM Output
    always_comb begin : fsm_output
        case (currstate)
            reset: begin
                rgb <= 3'h0;
                led <= 4'h0;
            end
            lock: begin
                rgb <= 3'h1;
                led <= 4'h0;
            end 
            s1, w1, r1: begin
                rgb <= 3'h0;
                led <= 4'h1;
            end
            s2, w2, r2: begin
                rgb <= 3'h0;
                led <= 4'h3;
            end
            s3, w3, r3: begin
                rgb <= 3'h0;
                led <= 4'h7;
            end
            unlock: begin
                rgb <= 3'h0;
                led <= led_reg;
            end
            alarm, a1: begin
                rgb <= rgb_reg;
                led <= 4'h0;
            end
            default: begin
                rgb <= 3'h0;
                led <= 4'h0;
            end
        endcase
    end

endmodule