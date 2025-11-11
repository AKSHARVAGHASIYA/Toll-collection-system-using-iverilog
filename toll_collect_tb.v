module tb_toll_system;
    reg clk, reset, vehicle_detected;
    reg [1:0] vehicle_type;
    reg [15:0] card_balance;
    wire [15:0] new_balance;
    wire [7:0] toll_deducted;
    wire gate_open;
    wire [2:0] state;
    wire [7:0] display_msg;

    toll_system uut(
        .clk(clk), .reset(reset),
        .vehicle_detected(vehicle_detected),
        .vehicle_type(vehicle_type),
        .card_balance(card_balance),
        .new_balance(new_balance),
        .toll_deducted(toll_deducted),
        .gate_open(gate_open),
        .state(state),
        .display_msg(display_msg)
    );

    always #5 clk = ~clk; // Clock generation

    initial begin
        // GTKWave dump
        $dumpfile("toll_system.vcd");
        $dumpvars(0, tb_toll_system);

        // Console log
        $monitor("Time=%0t | State=%0d | Vehicle=%0b | Toll=%0d | Balance=%0d | NewBalance=%0d | Gate=%b | Display=%c", 
                 $time, state, vehicle_type, toll_deducted, card_balance, new_balance, gate_open, display_msg);

        // Init
        clk = 0; reset = 1; vehicle_detected = 0; vehicle_type = 0; card_balance = 0;
        #10 reset = 0;

        // Test 1: Car with enough balance
        card_balance = 200; vehicle_type = 2'b00; vehicle_detected = 1; #10;
        vehicle_detected = 0; #50;

        // Test 2: Truck with enough balance
        card_balance = new_balance; vehicle_type = 2'b01; vehicle_detected = 1; #10;
        vehicle_detected = 0; #50;

        // Test 3: Bike with NOT enough balance
        card_balance = 10; vehicle_type = 2'b10; vehicle_detected = 1; #10;
        vehicle_detected = 0; #50;

        $finish;
    end
endmodule
