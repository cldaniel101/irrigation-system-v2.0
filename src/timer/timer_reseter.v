module timer_reseter (
    output reset,

    input forced_reset_from_button,
    input irrigation_on,
    input conflicting_values,
    input clock,

    input splinker_mode_on,

    input [1:0] minutes_d,
    input [3:0] minutes_u,
    input [2:0] seconds_d
);

    // Reset logic

    not (button_released, forced_reset_from_button);
    not (irrigation_off, irrigation_on);

    nor all_zero(
        reached_zero,
		seconds_d[2], seconds_d[1], seconds_d[0],
		minutes_u[3], minutes_u[2], minutes_u[1], minutes_u[0],
		minutes_d[1], minutes_d[0]
    );

    wire initialized;
    
    flipflop_d (uninitialized, clock, , , initialized);
    not (initialized, uninitialized);

    or (reset, irrigation_off, reached_zero, button_released, conflicting_values, uninitialized);

endmodule