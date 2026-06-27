module spi_shifter(PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cphas_i,cpol_i,miso_recieve_sclk_i,miso_recieve_sclk0_i,mosi_send_sclk_i,mosi_send_sclk0_i,data_miso_o,miso_i,recieve_data_i,mosi_o,data_mosi_i);

        input PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cphas_i,cpol_i,miso_recieve_sclk_i,miso_recieve_sclk0_i,mosi_send_sclk_i,mosi_send_sclk0_i,miso_i,recieve_data_i;
        input [7:0] data_mosi_i;
        output reg [7:0] data_miso_o;
        output reg mosi_o;

        reg [7:0] shift_reg, temp_reg;
        reg [2:0] count1,count,count2,count3;

        always @(posedge PCLK, negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        shift_reg <= 8'h00;
                //      temp_reg  <= 8'h00;
                        data_miso_o <= 8'h00;
                end
                else if(send_data_i == 1)
                        shift_reg <= data_mosi_i;
                else if(recieve_data_i == 1)
                        data_miso_o <= temp_reg;
        end

        //bit by bit (mosi)

	always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        mosi_o <= 1'b0;
                        count <= 3'd0;
                        count1 <= 3'd7;
                end

                else
                begin
                        if(ss_i == 0)
                        begin
                                if((!cphas_i && cpol_i) || (cphas_i && !cpol_i))
                                begin
                                        if ((lsbfe_i == 1) && (mosi_send_sclk0_i == 1))
                                        begin
                                                if(count == 7)
                                                begin
                                                        mosi_o <= shift_reg[7];
                                                        count <= 0;
                                                end
                                                else
                                                begin
                                                        mosi_o <= shift_reg[count];
                                                        count <= count + 1;
                                                end
                                        end
                                        else if((lsbfe_i == 0) && (mosi_send_sclk0_i == 1))
                                        begin
                                                if(count1 == 0)
                                                begin
                                                        mosi_o <= shift_reg[0];
                                                        count1 <= 3'd7;
                                                end
                                                else
                                                begin
                                                        mosi_o <= shift_reg[count1];
                                                        count1 <= count1 - 1;
                                                end
                                        end
                                end
                                else if((!cphas_i && !cpol_i) || (cphas_i && cpol_i))
                                begin
                                        if ((lsbfe_i == 1) && (mosi_send_sclk_i == 1))
                                        begin
                                                if(count == 7)
                                                begin
                                                        mosi_o <= shift_reg[7];
                                                        count <= 0;
                                                end
                                                else
                                                begin
                                                        mosi_o <= shift_reg[count];
							count <= count + 1;
                                                end
                                        end

                                        else if ((lsbfe_i == 0) && (mosi_send_sclk_i == 1 ))
                                        begin
                                                if(count1 == 0)
                                                begin
                                                        mosi_o <= shift_reg[0];
                                                        count1 <= 3'd7;
                                                end
                                                else
                                                begin
                                                        mosi_o <= shift_reg[count1];
                                                        count1 <= count1 - 1;
                                                end
                                        end

                                end

                        end
                end

        end

                //recieve data bit by bit miso

        always @(posedge PCLK or negedge PRESET_n)
        begin
                if(!PRESET_n)
                begin
                        temp_reg <= 8'b0;
                        count2 <= 3'd0;
                        count3 <= 3'd7;
                end

                else
                begin
                        if(ss_i == 0)
                        begin
                                if((cphas_i && cpol_i) || (!cphas_i && !cpol_i))
                                begin
                                        if ((lsbfe_i == 1) && (miso_recieve_sclk_i == 1))
                                        begin
                                                if(count2 == 7)
                                                begin
                                                        temp_reg[7] <= miso_i;
                                                        count2 <= 0;
                                                end
                                                else
                                                begin
                                                        temp_reg[count2] <= miso_i;
                                                        count2 <= count2 + 1;
                                                end
					end

                                        else if ((lsbfe_i == 0) && (miso_recieve_sclk_i == 1))
                                        begin
                                                if(count3 == 0)
                                                begin
                                                        temp_reg[0] <= miso_i;
                                                        count3 <= 3'd7;
                                                end
                                                else
                                                begin
                                                        temp_reg[count3] <= miso_i;
                                                        count3 <= count3 - 1;
                                                end
                                        end

                                end

                                else if((cphas_i && !cpol_i) || (!cphas_i && cpol_i))
                                 begin
                                        if ((lsbfe_i == 1) && (miso_recieve_sclk0_i == 1))
                                        begin
                                                if(count2 == 7)
                                                begin
                                                        temp_reg[7] <= miso_i;
                                                        count2 <= 0;
                                                end
                                                else
                                                begin
                                                        temp_reg[count2] <= miso_i;
                                                        count2 <= count2 + 1;
                                                end
                                        end

                                        else if ((lsbfe_i == 0) && (miso_recieve_sclk0_i == 1))
                                        begin
                                                if(count3 == 0)
                                                begin
                                                        temp_reg[0] <= miso_i;
                                                        count3 <= 3'd7;
                                                end
                                                else
                                                begin
                                                        temp_reg[count3] <= miso_i;
                                                        count3 <= count3 - 1;
                                                end
                                        end

                                end
                        end
                end

        end
endmodule
