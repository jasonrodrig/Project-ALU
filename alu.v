module alu(clk,rst,inp_valid,mode,cmd,ce,opa,opb,cin,res,cout,oflow,g,l,e,err);
    parameter data_width = 8;

                input wire clk , rst , mode , ce , cin;
                input wire [ data_width - 1 : 0 ] opa , opb ;
                input wire [ 1 : 0 ] inp_valid;
                input wire [ 3 : 0 ] cmd;
                output reg [ ( 2 * data_width ) - 1 : 0 ] res;
                output reg oflow , cout , g , l , e , err;

                parameter ADD = 0 , SUB = 1 , ADD_CIN = 2 , SUB_CIN = 3 , INC_A = 4 , DEC_A = 5 , INC_B = 6 , DEC_B = 7 , CMP = 8 , SPECIAL1 = 9 , SPECIAL2 = 10, SPECIAL3 = 11 ,SPECIAL4  = 12;

                parameter AND = 0 , NAND = 1 , OR = 2 , NOR = 3 , XOR = 4 , XNOR = 5 , NOT_A = 6 , NOT_B = 7 , SHR1_A = 8 , SHL1_A = 9 , SHR1_B = 10, SHL1_B = 11 , ROL_A_B  = 12 , ROR_A_B = 13;

                reg [ data_width - 1 : 0 ] rega , regb ;
                reg [ $clog2( data_width ) - 1 : 0 ] shift_amt ;
                // reg [1:0] delay;
                // localparam s0 = 2'b00 , s1= 2'b01, s2 = 2'b10; s3 = 2'b11;
                // reg [2:0] state;
                // reg start;
                // reg [ 2 * ( data_width ) - 1 : 0 ] res_buf;

                // always@(posedge clk or posedge rst) begin
                //    if(rst) begin
                //       delay <= 0;
                //       state <= 0;
                //       {rega,regb} <= 0;
                //       res <= 0;
                //       end
                //    else begin
                //        case(state)
                //         s0 : begin
                //             if(delay == 0) begin
                //                rega <= opa;
                //                regb <= opb;
                //                delay <= delay + 1;
                //                start <= 1;
                //                state <= s1;
                //              end
                //              else begin
                //                state <= s0;
                //              end
                //              end
                //         s1 : begin
                //               if(delay == 1) begin
                //                 delay <= delay + 1;
                //                 start <= 0;
                //                 state <= s2;
                //               end
                //               else begin
                //                 state <= s1;
                //               end
                //               end
                //          s2 : begin
                //              if(delay == 2) begin
                //               start <= 1;
                //               res <= res_buf;
                //               delay <=0;
                //               state <= s0;
                //               end
                //              else begin
                //               state <= s2;
                //               start <= 0;
                //              end
                //              end
                //        default : state <= s0;
                //      endcase     
                //     end
                //    end

                always@( posedge clk or posedge rst ) begin
                   if( rst ) begin
                    res       <= 0 ;
                    oflow     <= 0 ;
                    cout      <= 0 ;
                    g         <= 0 ;
                    l         <= 0 ;
                    e         <= 0 ;
                    err       <= 0 ;
                    rega      <= 0 ;
                    regb      <= 0 ;
                    shift_amt <= 0 ;
                    res       <= 0 ;
                    //delay   <= 0 ;
                    end

                    else begin
                   
                   // if(start) begin
                    {cout,e,g,l,oflow,err} = 6'b0;
                case ( inp_valid )
                2'b00:  begin
                        rega <= 0 ; regb <= 0; res <= 0;
                        end
                2'b01:  begin
                        rega <= opa ; regb <= 0 ;
                        end
                2'b10:  begin
                        rega <= 0 ; regb <= opb ;
                        end
                2'b11:  begin
                        rega <= opa ; regb <= opb ;
                        end
                default: begin
                         rega <= 0 ; regb <= 0 ; res<=0;
                         end
                endcase

                        if( ce ) begin

                                   if( mode ) begin
                                         
                                                {cout,e,g,l,oflow,err} = 6'b0;
                                                res = 16'b0000000000000000;
                                          
                                            case(cmd)

                                            ADD:      begin
                                                      if( inp_valid != 0) begin
                                                          res = rega + regb;
                                                          cout = res[ data_width ] ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1 ;
                                                          res = 0 ;
                                                      end
                                                      end

                                            SUB:      begin
                                                      if( inp_valid != 0 )begin
                                                          res = rega - regb;
                                                          oflow = ( rega < regb ) ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1 ;
                                                          res = 0 ;
                                                      end
                                                      end

                                            ADD_CIN:  begin
                                                      if( inp_valid != 0 )begin
                                                          res = rega + regb + cin;
                                                          cout = res[ data_width ] ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1 ;
                                                          res = res ;
                                                      end
                                                      end

                                            SUB_CIN:  begin
                                                      if( inp_valid != 0 )begin
                                                         res = rega - regb - cin;
                                                         oflow = ( rega < regb ) ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1 ;
                                                          res = 0 ;
                                                      end
                                                      end

                                            INC_A:    begin
                                                      if(inp_valid == 2'b01) begin
                                                          res = rega + 1;
                                                          cout = res[ data_width ] ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1 ;
                                                          res = 0 ;
                                                      end
                                                      end

                                            DEC_A:    begin
                                                      if(inp_valid == 2'b01) begin
                                                          res = rega - 1;
                                                          $display("%b",res);
                                                          oflow = ( 0 == rega ) ? 1 : 0;
                                                      end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                            INC_B:    begin
                                                      if(inp_valid == 2'b10) begin
                                                          res = regb + 1;
                                                          cout = res[data_width ] ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                            DEC_B:    begin
                                                      if(inp_valid == 2'b10) begin
                                                           res = regb - 1;
                                                           oflow = ( 0 == regb ) ? 1 : 0;
                                                      end
                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                            CMP:      begin
                                                         if( inp_valid != 0 )begin
                                                             if( rega > regb ) begin
                                                                 res = 0;
                                                                 g = 1;
                                                                 l = 0;
                                                                 e = 0;
                                                             end

                                                             else if( rega < regb ) begin
                                                                res = 0;
                                                                g = 0;
                                                                e = 0;
                                                                l = 1;
                                                             end

                                                             else begin
                                                                res = 0;
                                                                g = 0;
                                                                e = 1;
                                                                l = 0;
                                                             end
                                                         end
                                                         else begin
                                                             err = 1;
                                                             res = 0;
                                                             g   = 0;
                                                             e   = 0;
                                                             l   = 0;
                                                         end
                                                      end

                                            SPECIAL1: begin
                                                      if( inp_valid == 2'b11 )begin
                                                           res   = ( rega + 1 ) * ( regb + 1 );
                                                           oflow = (res == 0 )? 1 : 0 ;
                                                      end
                                                       else begin
                                                          err = 1;
                                                          res = 0;
                                                       end
                                                      end

                                            SPECIAL2: begin
                                                          if( inp_valid != 0 )begin
                                                          res = ( rega << 1 ) * ( regb );
                                                          end
                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                            SPECIAL3: begin
                                                      if( inp_valid != 0 )begin
                                                                                
                                                        res = $signed(rega) + $signed(regb);
                                                        e = ($signed(rega) == $signed(regb) )? 1 : 0 ;
                                                        g = ($signed(rega) > $signed(regb) )? 1 : 0;
                                                        l = ($signed(rega) < $signed(regb) )? 1 : 0;
                                                                               cout = res[ data_width - 1 ] ? 1 : 0;
                                                        oflow = ( ( rega[ data_width - 1] == 0 ) && ( regb[ data_width -1 ] == 0 ) &&
                                                                  ( res[ data_width - 1 ] == 1 ) || ( rega[ data_width - 1] == 1 ) &&
                                                                  ( regb[ data_width - 1 ] == 1 ) && ( res[ data_width - 1 ] == 0 ) ) ? 1 : 0;
                                                        end


                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                          g   = 0;
                                                          l   = 0;
                                                          e   = 0;
                                                      end
                                                      end

                                            SPECIAL4: begin
                                                      if( inp_valid != 0 )begin
                                                           res = $signed(rega) - $signed(regb);
                                                           e = ($signed(rega) == $signed(regb) )? 1 : 0 ;
                                                           g = ($signed(rega) > $signed(regb) )? 1 : 0;
                                                           l = ($signed(rega) < $signed(regb) )? 1 : 0;
                                                           cout = ( (rega[data_width - 1] != regb[data_width - 1]) && (res[data_width - 1] !=
                                                                     rega[data_width - 1]) ) ? 1 : 0 ;
                                                           oflow = ( ( rega[ data_width - 1] == 0 ) && ( regb[ data_width - 1 ] == 1 ) &&
                                                                     ( res[ data_width - 1 ] == 1 ) || ( rega[ data_width - 1] == 1 ) &&
                                                                     ( regb[ data_width - 1 ] == 0 ) && ( res[ data_width - 1 ] == 0 ) ) ? 1 : 0;
                                                           end

                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                          g   = 0;
                                                          l   = 0;
                                                          e   = 0;
                                                      end
                                                      end

                                              default: begin
                                                         res     <= 0 ;
                                                         oflow   <= 0 ;
                                                         cout    <= 0 ;
                                                         g       <= 0 ;
                                                         l       <= 0 ;
                                                         e       <= 0 ;
                                                         err     <= 1 ;
                                                         //delay   <= 0 ;
                                                        // res     <= 0 ;
                                                       end
                                           endcase
                                       end


                                       else begin
                                            {cout,e,g,l,oflow,err} = 6'b0;
                                             res = 16'b0000000000000000;
                                            case(cmd)

                                             AND:    begin
                                                      if( inp_valid != 0 )begin
                                                          res= {{data_width{1'b0}}, rega & regb} ;
                                                          end
                                                      else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                             NAND:   begin
                                                     if( inp_valid != 0 )begin
                                                         res = {{data_width{1'b0}}, (~( rega & regb ))} ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             OR:     begin
                                                     if( inp_valid != 0 )begin
                                                         res = {{data_width{1'b0}},rega | regb};
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             NOR:    begin
                                                     if( inp_valid != 0 )begin
                                                         res =  {{data_width{1'b0}},( ~( rega | regb ))} ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             XOR:    begin
                                                     if( inp_valid != 0 )begin
                                                         res = {{data_width{1'b0}}, rega ^ regb} ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             XNOR:   begin
                                                     if( inp_valid != 0 )begin
                                                         res = {{data_width{1'b0}},( ~( rega ^ regb ))} ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             NOT_A:  begin
                                                     if( inp_valid == 2'b01 )begin
                                                         res = {{data_width{1'b0}}, ~rega}  ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             NOT_B:  begin
                                                     if( inp_valid == 2'b10)begin
                                                         res = {{data_width{1'b0}}, ~regb };
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                             SHR1_A: begin
                                                     if( inp_valid == 2'b01 )begin
                                                         res = {{data_width{1'b0}}, rega >> 1} ;
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                      end
                                                      end

                                             SHL1_A: begin
                                                     if( inp_valid == 2'b01 )begin
                                                         res =  {{data_width{1'b0}},rega << 1 };
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             SHR1_B: begin
                                                     if( inp_valid == 2'b10 )begin
                                                         res ={{data_width{1'b0}}, regb >> 1 };
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             SHL1_B: begin
                                                     if( inp_valid == 2'b10 )begin
                                                         res =  { {data_width{1'b0}} , regb << 1 };
                                                         end
                                                     else begin
                                                          err = 1;
                                                          res = 0;
                                                     end
                                                     end

                                             ROL_A_B: begin
                                                      if(inp_valid !=0)begin
                                                           shift_amt = regb[ $clog2(data_width) - 1 : 0];
                                                           res = { {data_width{1'b0}}, rega >> (data_width - shift_amt) | rega << shift_amt };
                                                           err = ( regb >> ( $clog2(data_width) + 1 ) | { data_width{1'b0}}) > 0 ? 1 : 0;
                                                      end
                                                      else begin
                                                           err =  1;
                                                           res =  0;
                                                      end
                                                      end

                                             ROR_A_B:  begin
                                                       if(inp_valid !=0)begin
                                                           shift_amt = regb[ $clog2(data_width) - 1 : 0];
                                                           res = { {data_width{1'b0}} , rega >> shift_amt | rega << ( data_width - shift_amt ) };
                                                           err = ( regb >> ( $clog2(data_width) + 1 ) | { data_width{1'b0}}) > 0 ? 1 : 0;
                                                       end
                                                       else begin
                                                           err =  1;
                                                           res =  0;
                                                       end
                                                       end


                                             default: begin
                      				        res       <= 0 ;
                           				oflow     <= 0 ;
                           				cout      <= 0 ;
                           				g         <= 0 ;
                           				l         <= 0 ;
                           				e         <= 0 ;
                           				err       <= 1 ;
                           				shift_amt <= 0 ;
                           				//res     <= 0 ;
                         			      end
                			endcase
           			end

                        end

                        else begin
                        res       <= res ;
                        oflow     <= oflow ;
                        cout      <= cout ;
                        g         <= g ;
                        l         <= l ;
                        e         <= e ;
                        err       <= err ;
                        rega      <= rega ;
                        regb      <= regb ;
                        //delay   <= delay ;
                        shift_amt <= shift_amt ;
                        //res     <= res;
                 end
              end
              //else
              //begin
              // rega = rega;
              // regb = regb;
              //end
            // end
           end
endmodule
