module apb_slave_interface(PCLK,PRESET_n,PADDR_i,PWRITE_i,PSEL_i,PENABLE_i,PWDATA_i,ss_i,miso_data_i,recieve_data_i,tip_i,
        PRDATA_o,mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,sppr_o,spr_o,spi_interrupt_request_o,PREADY_o,PSLVERR_o,send_data_o,mosi_data_o,spi_mode_o);

        input PCLK,PRESET_n,PWRITE_i,PSEL_i,PENABLE_i,ss_i,recieve_data_i,tip_i;

        output mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,spi_interrupt_request_o,PREADY_o,PSLVERR_o;

        output reg send_data_o;
        output reg [7:0] mosi_data_o;
        input [7:0] PWDATA_i,miso_data_i;
        input [2:0] PADDR_i;
        output reg [7:0] PRDATA_o;
        output [2:0] sppr_o,spr_o;
        output reg [1:0] spi_mode_o;

        `define SPI_APB_DATA_WIDTH 8
        `define SPI_REG_WIDTH 8
        `define SPI_APB_ADDR_WIDTH 3


        parameter IDLE = 2'b00, SETUP = 2'b01, ENABLE = 2'b10, SPI_RUN = 2'b00, SPI_WAIT = 2'b01, SPI_STOP = 2'b10;

        reg [1:0] state,next_state,next_mode;
        reg [7:0] SPI_CR_1, SPI_CR_2, SPI_BR, SPI_SR, SPI_DR;
        reg modf, wr_enb, rd_enb;
        wire spif, sptef, modfen, spe, spie, ssoe, sptie;

        //APB fsm

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        state <= IDLE;
                else
                        state <= next_state;
        end
	always @(*)
        begin
                case(state)
                        IDLE :
                                begin
                                        if (PSEL_i && !PENABLE_i)
                                                next_state = SETUP;
                                        else
                                                next_state = IDLE;
                                end
                        SETUP :
                                begin
                                        if(PSEL_i && PENABLE_i)
                                                next_state = ENABLE;
                                        else if(PSEL_i && !PENABLE_i)
                                                next_state = SETUP;
                                        else
                                                next_state = IDLE;
                                end
                        ENABLE :
                                begin
                                        if(PSEL_i && PENABLE_i)
                                                next_state = ENABLE;
                                        else if(PSEL_i && !PENABLE_i)
                                                next_state = SETUP;
                                        else
                                                next_state = IDLE;
                                end
                        default : next_state = IDLE;
                endcase
        end

        //SPI fsm

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        spi_mode_o <= SPI_RUN;
                else
                        spi_mode_o <= next_mode;
        end

	always @(*)
        begin
                case(spi_mode_o)

                        SPI_RUN :
                                begin
                                        if(!spe)
                                                next_mode = SPI_WAIT;
                                        else
                                                next_mode = SPI_RUN;
                                end

                        SPI_WAIT :
                                begin
                                        if(spe)
                                                next_mode = SPI_RUN;
                                        else if(spiswai_o)
                                                next_mode = SPI_STOP;
                                        else
                                                next_mode = SPI_WAIT;
                                end

                        SPI_STOP :
                                begin
                                        if(!spiswai_o)
                                                next_mode = SPI_WAIT;
                                        else if(spe)
                                                next_mode = SPI_RUN;
                                        else
                                                next_mode = SPI_STOP;
                                end

                        default : next_mode = SPI_RUN;

                endcase
        end



        assign PREADY_o = (state == ENABLE);
        assign PSLVERR_o = ((state == ENABLE) && (tip_i == 0));

        // read and write enables

	always @(*)
        begin
                wr_enb = 1'b0;
                rd_enb = 1'b0;
                if ((state == ENABLE) && (PWRITE_i == 1))
                        wr_enb = 1'b1;

                else if ((state == ENABLE) && (PWRITE_i == 0))
                        rd_enb = 1'b1;
        end

        // write operation on SPI

        parameter CR1_ADDR = 3'b000, CR2_ADDR = 3'b001, BR_ADDR  = 3'b010, SR_ADDR  = 3'b011 , DR_ADDR  = 3'b101;

        always @ (posedge PCLK or negedge PRESET_n)
        begin
                if (!PRESET_n)
                begin
                        SPI_CR_1 <= 8'd4;
                        SPI_CR_2 <= 8'h00;
                        SPI_BR   <= 8'h00;
                end
                else if (wr_enb)
                begin
                        case(PADDR_i)
                                3'b000 : SPI_CR_1 <= PWDATA_i;
                                3'b001 : SPI_CR_2 <= PWDATA_i & 8'b00011011;
                                3'b010 : SPI_BR   <= PWDATA_i & 8'b01110111;
                        endcase
                end
        end

        // APB ready data path

        always @(*)
        begin
                PRDATA_o = 8'h0;

                if (rd_enb)
                begin
                        case(PADDR_i)
                                3'b000 : PRDATA_o = SPI_CR_1;
                                3'b001 : PRDATA_o = SPI_CR_2;
                                3'b010 : PRDATA_o = SPI_BR;
                                3'b011 : PRDATA_o = SPI_SR;
                                3'b101 : PRDATA_o = SPI_DR;
                                default : PRDATA_o = 8'h0;
                        endcase
                end

                else
                        PRDATA_o = 8'h00;
        end

	//decode control reg fields

        assign mstr_o    = SPI_CR_1[4];
        assign cpol_o    = SPI_CR_1[3];
        assign cpha_o    = SPI_CR_1[2];
        assign lsbfe_o   = SPI_CR_1[0];
        assign spe       = SPI_CR_1[6];
        assign spie      = SPI_CR_1[7];
        assign sptie     = SPI_CR_1[5];
        assign spiswai_o = SPI_CR_2[1];
        assign modfen    = SPI_CR_2[4];
        assign sppr_o    = SPI_BR[6:4];
        assign spr_o     = SPI_BR[2:0];
        assign ssoe      = SPI_CR_1[1];

        //MODF

        always @(*)
        begin
                if (((ss_i == 0) && (mstr_o == 1) && (modfen == 1)) && (ssoe == 0))
                        modf = 1'b1;
                else
                        modf = 1'b0;
        end

        //SPI_STATUS_REG

        assign sptef = (SPI_DR == 8'h0);
        assign spif  = (SPI_DR != 8'h0);

        always @(*)
        begin
                SPI_SR = {spif,1'b0,sptef,modf,3'b0};
                //SPI_SR[7] = spif;
                //SPI_SR[5] = sptef;
                //SPI_SR[4] = modf;
        end

        // seq block for send data

	always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        send_data_o <= 1'b0;
                        mosi_data_o <= 8'b0;
                end

                else if(mosi_data_o == SPI_DR)
                        send_data_o <= 1'b0;


                else if(((SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i)) && ((spi_mode_o == SPI_RUN) || ((spi_mode_o == SPI_WAIT) && (spiswai_o == 0))))
                begin
                        send_data_o <= 1'b1;
                        mosi_data_o <= SPI_DR;
                end


                else
                begin
                        send_data_o <= 0;
                        mosi_data_o <= mosi_data_o;
                end

        end

        /*

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        mosi_data_o <= 0;
                else if ((SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i) && ((spi_mode_o == SPI_RUN) || ((spi_mode_o == SPI_WAIT)))
                                mosi_data_o <= SPI_DR;
                else
                        mosi_data_o <= mosi_data_o;
        end

        */

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        SPI_DR <= 8'h0;

                else if((wr_enb == 1)&&(PADDR_i == DR_ADDR))
                        SPI_DR <= PWDATA_i;

                else if(((spi_mode_o == SPI_RUN) || ((spi_mode_o == SPI_WAIT) && (spiswai_o == 0))) && (recieve_data_i == 1))
                        SPI_DR <= miso_data_i;
                else
                        SPI_DR <= SPI_DR;
        end

	//interupt logic

        assign spi_interrupt_request_o = (!spie && !sptie) ? 1'b0: (spie && !sptie)?(spif || modf) : (!spie && sptie) ? sptef : (spif |modf | sptef);
endmodule
