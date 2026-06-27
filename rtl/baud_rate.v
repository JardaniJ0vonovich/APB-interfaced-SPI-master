module baud_rate(PCLK, PRESET_n,spi_mode_i,spiswai_i,sppr_i,spr_i,cpol_i,cphas_i,ss_i,
                        sclk_o,miso_recieve_sclk_o,miso_recieve_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,BaudRateDivisor);

        input PCLK,PRESET_n,cpol_i,cphas_i,spiswai_i,ss_i;
        output reg sclk_o;
        output reg miso_recieve_sclk_o,miso_recieve_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o;
        input [2:0] sppr_i,spr_i;
        input [1:0] spi_mode_i;
        output  [11:0] BaudRateDivisor;

        parameter RUN = 2'b00,
                  WAIT = 2'b01,
                  STOP = 2'b10;


        reg [11:0] count;
        wire pre_sclk;

        assign BaudRateDivisor = (sppr_i + 1) * (2 ** (spr_i +1));
        assign pre_sclk = (cpol_i) ? 1'b1:1'b0;


        always @ (posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        begin
                                count <= 12'b0;
                                sclk_o  <= pre_sclk;
                        end
                else if (((spi_mode_i == RUN) || ((spi_mode_i == WAIT) && (spiswai_i == 0))) && (ss_i == 0))
                begin
                                if( count == (BaudRateDivisor/2) - 1)
                                begin
                                        sclk_o  <= ~sclk_o;
                                        count <= 12'b0;
                                end
                                else
                                begin
                                        count <= count + 1'b1;
                                end
                end
                else
                begin
                        count <= 1'b0;
                        sclk_o <= pre_sclk;
                end
        end

	// miso
        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        miso_recieve_sclk0_o <= 1'b0;
                        miso_recieve_sclk_o   <= 1'b0;
                end

//              else if (BaudRateDivisor == 2)
//                      begin
//                      end

                else if ((cpol_i && !cphas_i) || (!cpol_i && cphas_i))
                begin
                        if(sclk_o == 1)
                        begin
                                if (count == (BaudRateDivisor/2) - 1)
                                        miso_recieve_sclk0_o <= 1'b1;
                                else
                                        miso_recieve_sclk0_o <= 1'b0;
                        end
                        else
                                        miso_recieve_sclk0_o <= 1'b0;
                end

                else if ((!cpol_i && !cphas_i) || (cpol_i && cphas_i))
                begin
                        if(sclk_o == 0)
                        begin
                                if (count == (BaudRateDivisor/2) - 1)
                                        miso_recieve_sclk_o <= 1'b1;
                                else
                                        miso_recieve_sclk_o <= 1'b0;
                        end
                        else
                                        miso_recieve_sclk_o <= 1'b0;
                end

        end

	// mosi

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        mosi_send_sclk0_o <= 1'b0;
                        mosi_send_sclk_o   <= 1'b0;
                end

                else if ((cpol_i && !cphas_i) || (!cpol_i && cphas_i))
                begin
                        if(sclk_o == 1)
                        begin
                                if (count == (BaudRateDivisor/2) - 2)
                                        mosi_send_sclk0_o <= 1'b1;
                                else
                                        mosi_send_sclk0_o <= 1'b0;
                        end
                        else
                                mosi_send_sclk0_o <= 1'b0;
                end

                else if ((!cpol_i && !cphas_i) || (cpol_i && cphas_i))
                begin
                        if(sclk_o == 0)
                        begin
                                if (count == (BaudRateDivisor/2) - 2)
                                        mosi_send_sclk_o <= 1'b1;
                                else
                                        mosi_send_sclk_o <= 1'b0;
                        end
                        else
                                mosi_send_sclk_o <= 1'b0;
                end

        end

endmodule

