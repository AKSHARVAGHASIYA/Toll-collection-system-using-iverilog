module toll_system(
    input clk,
    input reset,
    input vehicle_detected,
    input [1:0] vehicle_type,     // 00=Car, 01=Truck, 10=Bike
    input [15:0] card_balance,    // Balance on user card
    output reg [15:0] new_balance,
    output reg [7:0] toll_deducted,
    output reg gate_open,
    output reg [2:0] state,       // FSM state output
    output reg [7:0] display_msg  // Display output (ASCII code)
);

    // Vehicle Types
    parameter CAR   = 2'b00;
    parameter TRUCK = 2'b01;
    parameter BIKE  = 2'b10;

    // Toll prices
    parameter CAR_TOLL   = 50;
    parameter TRUCK_TOLL = 100;
    parameter BIKE_TOLL  = 20;

    // FSM States
    parameter IDLE      = 3'b000;
    parameter CHECK     = 3'b001;
    parameter BALANCE   = 3'b010;
    parameter DEDUCT    = 3'b011;
    parameter OPEN_GATE = 3'b100;
    parameter DENY      = 3'b101;

    reg [2:0] next_state;

    // FSM state transition
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (vehicle_detected) next_state = CHECK;
            CHECK: next_state = BALANCE;
            BALANCE: if (card_balance >= toll_deducted) next_state = DEDUCT;
                     else next_state = DENY;
            DEDUCT: next_state = OPEN_GATE;
            OPEN_GATE: next_state = IDLE;
            DENY: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            toll_deducted <= 0;
            new_balance   <= 0;
            gate_open     <= 0;
            display_msg   <= " "; // blank
        end else begin
            case (state)
                IDLE: begin
                    toll_deducted <= 0;
                    gate_open <= 0;
                    display_msg <= "W"; // Welcome
                end
                CHECK: begin
                    case (vehicle_type)
                        CAR:   toll_deducted <= CAR_TOLL;
                        TRUCK: toll_deducted <= TRUCK_TOLL;
                        BIKE:  toll_deducted <= BIKE_TOLL;
                        default: toll_deducted <= 0;
                    endcase
                    display_msg <= "P"; // Pay toll
                end
                BALANCE: begin
                    display_msg <= "C"; // Checking
                end
                DEDUCT: begin
                    new_balance <= card_balance - toll_deducted;
                    display_msg <= "D"; // Deducting
                end
                OPEN_GATE: begin
                    gate_open <= 1;
                    display_msg <= "O"; // Open
                end
                DENY: begin
                    new_balance <= card_balance;
                    gate_open <= 0;
                    display_msg <= "X"; // Deny
                end
            endcase
        end
    end
endmodule
