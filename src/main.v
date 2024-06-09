module main(
	input low_water_level,
	input mid_water_level,
	input high_water_level,

	input earth_humidity,
	input air_humidity,
	input low_temperature,

	input selector,
	input clock,

	// LED RGB
	output alarm,

	// Array of LEDs Display
	output water_supply_valvule,
	output counter_2,
	output counter_1,
	output counter_0,
	output splinker_bomb,
	output dripper_valvule,

	// 7-Segment Display
	output segment_a, output segment_b, output segment_c,
    output segment_d, output segment_e, output segment_f,
    output segment_g,

	output display_0, output display_1,
	output display_2, output display_3,
	output displays_point,

	// Matrix of LEDs Display
	output matrix_col_0, output matrix_col_1, output matrix_col_2,
	output matrix_col_3, output matrix_col_4,

	output matrix_row_0, output matrix_row_1, output matrix_row_2,
	output matrix_row_3, output matrix_row_4, output matrix_row_5,
	output matrix_row_6

);

	//-------------------------------------------
	// Input & Error Checking
	//-------------------------------------------

	water_sensors_checker check_error(
		conflicting_values,

		low_water_level,
		mid_water_level,
		high_water_level
	);


	//-------------------------------------------
	// Water Supply
	//-------------------------------------------

	// Output
	water_supply_controller open_water_supply(
		water_supply_valvule,

		conflicting_values,
		high_water_level
	);


	//-------------------------------------------
	// Irrigation Controller and Selector
	//-------------------------------------------

	irrigation_controller check_prerequisites(
		irrigation_on,

		conflicting_values,
		earth_humidity,
		low_water_level
	);

	irrigation_selector select_irrigation(
		splinker_mode_on,

		air_humidity,
		low_temperature,
		mid_water_level
	);

	// Output
	and open_splinker(
		splinker_bomb,

		splinker_mode_on,
		irrigation_on
	);

	// Output
	and open_dripper(
		dripper_valvule,

		dripper_mode_on,
		irrigation_on
	);


	//-------------------------------------------
	// Alarm Output
	//-------------------------------------------

	// Output
	alarm_controller enable_alarm(
		alarm,

		mid_water_level,
		conflicting_values
	);


	//-------------------------------------------
	// Encoders
	//-------------------------------------------

	wire [1:0] encoded_water;
	wire [1:0] encoded_irrigation;

	water_encoder encode_water(
		encoded_water,

		high_water_level,
		mid_water_level,
		low_water_level
	);

	irrigation_encoder encode_irrigation(
		encoded_irrigation,

		splinker_mode_on
	);


	//-------------------------------------------
	// Matrix Display related
	//-------------------------------------------

	wire [2:0] ring_counting;

	// Clock reduction

	clock_divisor divide_clock(reduced_clock, clock, 1);


	// Ring Counter

	column_selector select_column(ring_counting, reduced_clock);

	// Output
	pipe redirect_couting_2(led2, ring_counting[2]);
	pipe redirect_couting_1(led1, ring_counting[1]);
	pipe redirect_couting_0(led0, ring_counting[0]);

	// Matrix Columns decoders

	wire [6:0] water_column_1;
	wire [6:0] water_column_2;

	water_level_decoder decode_water_level_to_matrix(
	   	water_column_1,
	   	water_column_0,

		encoded_water
	);

	wire [6:0] irrigation_column_2;
	wire [6:0] irrigation_column_1;
	wire [6:0] irrigation_column_0;

	irrigation_mode_decoder decode_irrigation_mode_to_matrix(
		irrigation_column_2,
		irrigation_column_1,
		irrigation_column_0,

		encoded_irrigation
	);

	// Matrix Sync

	wire [6:0] synced_column_2;
	wire [6:0] synced_column_1;
	wire [6:0] synced_column_0;

	select_matrix_display_mode select_display_mode(
		synced_column_2,
		synced_column_1,
		synced_column_0,

		reduced_clock,

		water_column_1,
		water_column_0,
		water_column_1,

		irrigation_col_2,
		irrigation_col_1,
		irrigation_col_0
	);

	matrix_ring_decoder decode_ring(
		matrix_col_0,
		matrix_col_1,
		matrix_col_2,
		matrix_col_3,
		matrix_col_4,

		ring_counting
	);

	matrix_driver drive_matrix(
		matrix_row_0,
		matrix_row_1,
		matrix_row_2,
		matrix_row_3,
		matrix_row_4,
		matrix_row_5,
		matrix_row_6,

		ring_counting,

		synced_column_2,
		synced_column_1,
		synced_column_0
	);

endmodule
