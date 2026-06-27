module top_module_tb;

        reg  PCLK,PRESET_n,PWRITE_i,PSEL_i,PENABLE_i,miso_i;
        reg [2:0] PADDR_i;
        reg [7:0] PWDATA_i;
        wire  spi_interrupt_request_o,PREADY_o,PSLVERR_o,ss,sclk_o,mosi_o;
        wire [7:0] PRDATA_o;

        top_module DUT(PCLK,PRESET_n,PADDR_i,PWRITE_i,PSEL_i,PENABLE_i,PWDATA_i,PRDATA_o,spi_interrupt_request_o,PREADY_o,PSLVERR_o,ss,sclk_o,miso_i,mosi_o);


        initial
        begin
                PCLK = 0;
                forever #5 PCLK = ~PCLK;
        end


        task apb_write (input [2:0] addr,input [7:0] data);
        begin
                @(negedge PCLK);
                PSEL_i = 1;
                PENABLE_i = 0;
                PWRITE_i  = 1;
                PADDR_i   = addr;
                PWDATA_i  = data;
                @(negedge PCLK);
                PENABLE_i = 1;
                @(negedge PCLK);

                PSEL_i    = 0;
                PENABLE_i = 0;
                //PWRITE_i  = 0;
        end
        endtask

	task apb_read(input [2:0] addr);
        begin
                @(negedge PCLK);

                PSEL_i    = 1;
                PENABLE_i = 0;
                PWRITE_i  = 0;
                PADDR_i   = addr;

                @(negedge PCLK);

                PENABLE_i = 1;

                @(negedge PCLK);


                PSEL_i    = 0;
                PENABLE_i = 0;
        end
        endtask


        initial
        begin

        PRESET_n       = 0;

        PSEL_i         = 1;
        PENABLE_i      = 0;
        PWRITE_i       = 0;

        PADDR_i        = 0;
        PWDATA_i       = 0;
        miso_i    = 8'h00;
        #20;
        PRESET_n = 1;
        #50;
        apb_write(3'b000,8'b00010100);
        #100;
        apb_read(3'b000);

        //repeat(5) @(posedge PCLK);



        //apb_write(3'b000,8'b00010011);


        apb_write(3'b001,8'b00000000);


        apb_write(3'b010,8'b00000001);

	//apb_read(3'b001);
        @(negedge PCLK)
        apb_read(3'b001);
        #50;
        apb_read(3'b010);

        #50
        apb_write(3'b101,8'hA5);
        #40;
                miso_i = 0;
                #40;
                miso_i = 0;
                #40;
                miso_i = 1;
                #40;
                miso_i = 1;
                #40;
                miso_i = 1;
                #40;
                miso_i = 1;
                #40;
                miso_i = 0;
                #40;
                miso_i = 0;
                #40;

        #500;



        //recieve_data_i = 1;



        //recieve_data_i = 0;


        apb_read(3'b101);

        #200;
        $finish;

        end


/*
initial
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,apb_slave_interface_tb);
end
*/
endmodule
