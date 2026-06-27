module spi_slave_select(PCLK,PRESET_n,mstr_i,spiswai_i,spi_mode_i,send_data_i,BaudRateDivisor_i,recieve_data_o,ss_o,tip_o);

        input PCLK,PRESET_n,mstr_i,spiswai_i,send_data_i;
        input [1:0] spi_mode_i;
        input [11:0] BaudRateDivisor_i;
        output tip_o;
        output reg ss_o,recieve_data_o;

        reg [15:0] count;
        wire [15:0] target_s;

        parameter RUN = 2'b00, WAIT = 2'b01, STOP = 2'b10;

        assign target_s = BaudRateDivisor_i * 8;
        assign tip_o = ~ss_o;

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(PRESET_n == 0)
                        begin
                                count <= 16'd0;
                                ss_o <= 1;
                                recieve_data_o <= 0;
                        end

                else if ((mstr_i == 1) && ((spi_mode_i == RUN) || ((spi_mode_i == WAIT) && (spiswai_i ==0))))
                        begin
                                if(send_data_i == 1)
                                        begin
                                                ss_o <= 0;
                                                recieve_data_o <= 0;
                                        end
                                else
                                        begin
                                         if ((ss_o == 0) && (count < (target_s )))
                                                begin
                                                        ss_o <= 1'b0;
                                                        count <= count + 1;
                                                end

                                        else if ((ss_o == 0) && (count == (target_s )))
                                                begin
                                                        recieve_data_o  <= 1'b1;
                                                        ss_o <= 1'b1;
                                                        count <= count + 1;
                                                end


                                        else if ((count == target_s + 1) && (ss_o == 1))
                                        begin
                                                recieve_data_o <= 1;
                                                count <= 16'h00;
                                        end

					else if ((recieve_data_o == 1) && (ss_o == 1))
                                                recieve_data_o <= 0;
                                        end
                        end

                else if ((mstr_i == 0) || (spi_mode_i == STOP))
                         begin
                                ss_o <= 1;
                                recieve_data_o <= 0;
                                count <= 16'b0;
                        end
        end

        /*

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                        recieve_data_o <= 0;
                else
                        recieve_data_o <= recieve_data_o;
        end
        */

endmodule
