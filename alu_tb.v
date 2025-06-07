`timescale 1ns/1ps
`include "alu.v"
`define PASS 1'b1
`define FAIL 1'b0
`define no_of_testcase 88


module test_bench_alu();
  reg [56:0] curr_test_case = 57'b0;
  reg [56:0] stimulus_mem [0:`no_of_testcase-1];
  reg [79:0] response_packet;

//Decl for giving the Stimulus
  integer i,j;
  reg CLK,REST,CE; //inputs
  event fetch_stimulus;
  reg [7:0]OPA,OPB; //inputs
  reg [3:0]CMD; //inputs
  reg MODE,CIN; //inputs
  reg [7:0] Feature_ID;
  reg [1:0] INP_VALID;
  reg [2:0] Comparison_EGL;  //expected output
  reg [15:0] Expected_RES; //expected output data
  reg err,cout,ov;
  reg [1:0] res1;

//Decl to Cop UP the DUT OPERATION
  wire  [15:0] RES;
  wire ERR,OFLOW,COUT;
  wire [2:0]EGL;
  wire [22:0] expected_data;
  reg [22:0]exact_data;

//READ DATA FROM THE TEXT VECTOR FILE
        task read_stimulus();
                begin
                #10 $readmemb ("stimulus.txt",stimulus_mem);
               end
        endtask

   alu inst_dut (.opa(OPA),.opb(OPB),.cin(CIN),.clk(CLK),.cmd(CMD),.ce(CE),.inp_valid(INP_VALID),.mode(MODE),.cout(COUT),.oflow(OFLOW),.res(RES),.g(EGL[1]),.e(EGL[2]),.l(EGL[0]),.err(ERR),.rst(REST));

//STIMULUS GENERATOR

integer stim_mem_ptr = 0,stim_stimulus_mem_ptr = 0,fid =0 , pointer =0 ;

        always@(fetch_stimulus)
                begin
                        curr_test_case=stimulus_mem[stim_mem_ptr];
                        $display ("stimulus_mem data = %0b \n",stimulus_mem[stim_mem_ptr]);
                        $display ("packet data = %0b \n",curr_test_case);
                        stim_mem_ptr=stim_mem_ptr+1;
                end

//INITIALIZING CLOCK
        initial
                begin CLK=0;
                        forever #10 CLK=~CLK;
                end

//DRIVER MODULE
        task driver ();
                begin
                  ->fetch_stimulus;
                  @(posedge CLK);
                  Feature_ID    =curr_test_case[56:49];
                  res1          =curr_test_case[48:47];
                  OPA           =curr_test_case[46:39];
                  OPB           =curr_test_case[38:31];
                  CMD           =curr_test_case[30:27];
                  INP_VALID     =curr_test_case[26:25];
                  CIN           =curr_test_case[24];
                  CE            =curr_test_case[23];
                  MODE          =curr_test_case[22];
                  Expected_RES  =curr_test_case[21:6];
                  cout =curr_test_case[5];
                  Comparison_EGL=curr_test_case[4:2];
                  ov =curr_test_case[1];
                  err           =curr_test_case[0];
                 $display("At time (%0t), Feature_ID = %8d, Reserved_bit = %2b, OPA = %8b, OPB = %8b,Inp_valid = %2b;  CMD = %4b, CIN = %1b, CE = %1b, MODE = %1b, expected_result = %b, cout = %1b, Comparison_EGL = %3b, ov = %1b, err = %1b",$time,Feature_ID,res1,OPA,OPB,INP_VALID,CMD,CIN,CE,MODE,Expected_RES,cout,Comparison_EGL,ov,err);
                end
        endtask

//GLOBAL DUT RESET
    task dut_reset ();
    begin
            
    #10 REST=1;
    #20 REST=0;
    #10 REST=1;
    #20 REST = 0;
    end
    endtask

//GLOBAL INITIALIZATION
        task global_init ();
                begin
                curr_test_case=57'b0;
                response_packet=80'b0;
                stim_mem_ptr=0;
                end
        endtask


//MONITOR PROGRAM


task monitor ();
                begin
                repeat(3)@(posedge CLK);
                #10 response_packet[56:0]=curr_test_case;
                response_packet[57]     =ERR;
                response_packet[58]     =OFLOW;
                response_packet[61:59]  ={EGL};
                response_packet[62]     =COUT;
                response_packet[78:63]  =RES;
                response_packet[79]     =0; // Reserved Bit
                $display("Monitor: At time (%0t), RES = %b, COUT = %1b, EGL = %3b, OFLOW = %1b, ERR = %1b",$time,RES,COUT,{EGL},OFLOW,ERR);
                exact_data ={RES,COUT,{EGL},OFLOW,ERR};
                end
        endtask

assign expected_data = {Expected_RES,cout,Comparison_EGL,ov,err};

//SCORE BOARD PROGRAM TO CHECK THE DUT OP WITH EXPECTD OP

reg [49:0] scb_stimulus_mem [0:`no_of_testcase-1];

task score_board();
   reg [15:0] expected_res;
   reg [7:0] feature_id;
   reg [22:0] response_data;
       begin
                #5;
                feature_id = curr_test_case[56:49];//8
                expected_res = curr_test_case[21:6];//9
                response_data = response_packet[79:57];//16
                                                       // total 33
                $display("expected result = %b ,response data = %b",expected_data,exact_data);
                 if(expected_data === exact_data)
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id, expected_res,response_data, 1'b0,`PASS};
                 else
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id, expected_res,response_data, 1'b0,`FAIL};
          stim_stimulus_mem_ptr = stim_stimulus_mem_ptr + 1;
        end
endtask


//Generating the report `no_of_testcase-1
task gen_report;
integer file_id,pointer;
reg [49:0] status;
                begin
                   file_id = $fopen("results.txt", "w");
                   for(pointer = 0; pointer <= `no_of_testcase-1 ; pointer = pointer+1 )
                   begin
                     status = scb_stimulus_mem[pointer];
                     if(status[0])
                       $fdisplay(file_id, "Feature ID %8d : PASS", status[48:41]);
                     else
                       $fdisplay(file_id, "Feature ID %8d : FAIL", status[48:41]);
                   end
                end
endtask


initial
               begin
                #10;
                global_init();
                dut_reset();
                read_stimulus();
                for(j=0;j<=`no_of_testcase-1;j=j+1)
                begin
                          fork
                          driver();
                          monitor();
                          join
                          score_board();
               end

               gen_report();
               $fclose(fid);
               #300 $finish();
               end
endmodule

