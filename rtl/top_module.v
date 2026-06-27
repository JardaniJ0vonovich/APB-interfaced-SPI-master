module top_module(PCLK,PRESET_n,PADDR_i,PWRITE_i,PSEL_i,PENABLE_i,PWDATA_i,PRDATA_o,spi_interrupt_request_o,PREADY_o,PSLVERR_o,ss,sclk_o,miso_i,mosi_o);
        input PCLK,PRESET_n,PWRITE_i,PSEL_i,PENABLE_i,miso_i;
        input [2:0] PADDR_i;
        input [7:0] PWDATA_i;
        output  spi_interrupt_request_o,PREADY_o,PSLVERR_o,ss,sclk_o,mosi_o;
        output [7:0] PRDATA_o;

        wire [11:0] BaudRateDivisor;
        wire [7:0] mosi_data;
        //wire miso_recieve_sclk,miso_recieve_sclk0,miso_send_sclk,miso_send_sclk0,recieve_data,ss,miso_data,tip,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,send_data,spi_mode;
        wire [7:0] miso_data;
        wire [2:0] sppr;
        wire [2:0] spr;
        wire [1:0] spi_mode;

        wire miso_recieve_sclk;
        wire miso_recieve_sclk0;
        wire mosi_send_sclk;
        wire mosi_send_sclk0;
        wire recieve_data;
        wire tip;
        wire mstr;
        wire cpol;
        wire cpha;
        wire lsbfe;
        wire spiswai;
        wire send_data;

        baud_rate B1 (.PCLK(PCLK),.PRESET_n(PRESET_n),.spi_mode_i(spi_mode),.spiswai_i(spiswai),.sppr_i(sppr),.spr_i(spr),.cpol_i(cpol),.cphas_i(cpha),.ss_i(ss),.sclk_o(sclk_o),.miso_recieve_sclk_o(miso_recieve_sclk),.miso_recieve_sclk0_o(miso_recieve_sclk0),.mosi_send_sclk_o(mosi_send_sclk),.mosi_send_sclk0_o(mosi_send_sclk0),.BaudRateDivisor(BaudRateDivisor));

        spi_shifter S1(.PCLK(PCLK),.PRESET_n(PRESET_n),.ss_i(ss),.send_data_i(send_data),.lsbfe_i(lsbfe),.cphas_i(cpha),.cpol_i(cpol),.miso_recieve_sclk_i(miso_recieve_sclk),.miso_recieve_sclk0_i(miso_recieve_sclk0),.mosi_send_sclk_i(mosi_send_sclk),.mosi_send_sclk0_i(mosi_send_sclk0),.data_mosi_i(mosi_data),.data_miso_o(miso_data),.mosi_o(mosi_o),.recieve_data_i(recieve_data),.miso_i(miso_i));

        spi_slave_select S2(.PCLK(PCLK),.PRESET_n(PRESET_n),.mstr_i(mstr),.spiswai_i(spiswai),.spi_mode_i(spi_mode),.send_data_i(send_data),.BaudRateDivisor_i(BaudRateDivisor),.recieve_data_o(recieve_data),.ss_o(ss),.tip_o(tip));

        apb_slave_interface A1(.PCLK(PCLK),.PRESET_n(PRESET_n),.PADDR_i(PADDR_i),.PWRITE_i(PWRITE_i),.PSEL_i(PSEL_i),.PENABLE_i(PENABLE_i),.PWDATA_i(PWDATA_i),.ss_i(ss),.miso_data_i(miso_data),.recieve_data_i(recieve_data),.tip_i(tip),.PRDATA_o(PRDATA_o),.mstr_o(mstr),.cpol_o(cpol),.cpha_o(cpha),.lsbfe_o(lsbfe),.spiswai_o(spiswai),.sppr_o(sppr),.spr_o(spr),.spi_interrupt_request_o(spi_interrupt_request_o),.PREADY_o(PREADY_o),.PSLVERR_o(PSLVERR_o),.send_data_o(send_data),.mosi_data_o(mosi_data),.spi_mode_o(spi_mode));

endmodule

