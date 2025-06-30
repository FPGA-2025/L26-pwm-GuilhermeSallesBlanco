module PWM_Control #(
    parameter CLK_FREQ = 25_000_000,
    parameter PWM_FREQ = 1_250
) (
    input  wire clk,
    input  wire rst_n,
    output wire [7:0] leds
);
    localparam [15:0] PWM_CLK_PERIOD = CLK_FREQ / PWM_FREQ;
    localparam integer PWM_DUTY_CYCLE = 50; // 0.0025% duty cycle

    localparam SECOND         = CLK_FREQ;
    localparam HALF_SECOND    = SECOND / 2;
    localparam QUARTER_SECOND = SECOND / 4;
    localparam EIGHTH_SECOND  = SECOND / 8;

    localparam [15:0] DUTY_MIN = PWM_CLK_PERIOD * 25 / 1_000_000; // 0.0025% duty cycle
    localparam [15:0] DUTY_MAX = PWM_CLK_PERIOD * 70 / 100; // 70% duty cycle

    reg [15:0] duty_cycle = DUTY_MIN;
    reg [23:0] fade_counter = 0;
    reg inc = 1;

    wire pwm_out;

    PWM pwm_inst(
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .period(PWM_CLK_PERIOD),
        .pwm_out(pwm_out)
    );

    assign leds = {8{pwm_out}};

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        duty_cycle   <= DUTY_MIN;
        fade_counter <= 0;
        inc          <= 1;
    end else begin
        if (fade_counter >= EIGHTH_SECOND) begin
            fade_counter <= 0;

            if (inc) begin
                if (duty_cycle < DUTY_MAX)
                    duty_cycle <= duty_cycle + 1;
                else
                    inc <= 0;
            end else begin
                if (duty_cycle > DUTY_MIN)
                    duty_cycle <= duty_cycle - 1;
                else
                    inc <= 1;
            end

        end else begin
            fade_counter <= fade_counter + 1;
        end
    end
end


endmodule