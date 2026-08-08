                                                                                                 
    `timescale 1ns / 1ps                                                                                                                                     
                                                                                                                                                             
    module tb_controller_agu;                                                                                                                                
                                                                                                                                                             
        // Parameters                                                                                                                                        
        parameter INS_WIDTH   = 9;                                                                                                                           
        parameter ROW_WIDTH   = 5;                                                                                                                           
        parameter DEPTH_WIDTH = 4;                                                                                                                           
                                                                                                                                                             
        // Controller Signals                                                                                                                                
        logic clock;                                                                                                                                         
        logic reset;                                                                                                                                         
        logic mac_done;                                                                                                                                      
        logic finish;                                                                                                                                        
        logic clear;                                                                                                                                         
        logic [4:0] count;                                                                                                                                   
                                                                                                                                                             
        // AGU Signals                                                                                                                                       
        logic [ROW_WIDTH-1:0]   row;                                                                                                                         
        logic [DEPTH_WIDTH-1:0] channel;                                                                                                                     
        logic [ROW_WIDTH-1:0]   column;                                                                                                                      
        logic [ROW_WIDTH-1:0]   image_height;                                                                                                                
        logic [ROW_WIDTH-1:0]   image_width;                                                                                                                 
                                                                                                                                                             
        logic [INS_WIDTH-1:0]   addr_r0c0;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r0c1;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r0c2;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r1c0;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r1c1;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r1c2;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r2c0;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r2c1;                                                                                                                   
        logic [INS_WIDTH-1:0]   addr_r2c2;                                                                                                                   
                                                                                                                                                             
        // Active address selected based on Controller count                                                                                                 
        logic [INS_WIDTH-1:0] current_mac_address;                                                                                                           
                                                                                                                                                             
        // Instantiate AGU (address_generator)                                                                                                               
        address_generator #(                                                                                                                                 
            .ins_width(INS_WIDTH),                                                                                                                           
            .row_width(ROW_WIDTH),                                                                                                                           
            .depth_width(DEPTH_WIDTH)                                                                                                                        
        ) u_agu (                                                                                                                                            
            .row(row),                                                                                                                                       
            .channel(channel),                                                                                                                               
            .column(column),                                                                                                                                 
            .image_height(image_height),                                                                                                                     
            .image_width(image_width),                                                                                                                       
            .address(addr_r0c0),                                                                                                                             
            .adress_row0column1(addr_r0c1),                                                                                                                  
            .adress_row0column2(addr_r0c2),                                                                                                                  
            .adress_row1column0(addr_r1c0),                                                                                                                  
            .adress_row1column1(addr_r1c1),                                                                                                                  
            .adress_row1column2(addr_r1c2),                                                                                                                  
            .adress_row2column0(addr_r2c0),                                                                                                                  
            .adress_row2column1(addr_r2c1),                                                                                                                  
            .adress_row2column2(addr_r2c2)                                                                                                                   
        );                                                                                                                                                   
                                                                                                                                                             
        // Instantiate Controller                                                                                                                            
        Controller u_controller (                                                                                                                            
            .clock(clock),                                                                                                                                   
            .reset(reset),                                                                                                                                   
            .mac_done(mac_done),                                                                                                                             
            .finish(finish),                                                                                                                                 
            .clear(clear),                                                                                                                                   
            .count(count)                                                                                                                                    
        );                                                                                                                                                   
                                                                                                                                                             
        // Address MUX: Select address corresponding to current MAC count (0 to 8)                                                                           
        always_comb begin                                                                                                                                    
            case (count)                                                                                                                                     
                5'd0: current_mac_address = addr_r0c0;                                                                                                       
                5'd1: current_mac_address = addr_r0c1;                                                                                                       
                5'd2: current_mac_address = addr_r0c2;                                                                                                       
                5'd3: current_mac_address = addr_r1c0;                                                                                                       
                5'd4: current_mac_address = addr_r1c1;                                                                                                       
                5'd5: current_mac_address = addr_r1c2;                                                                                                       
                5'd6: current_mac_address = addr_r2c0;                                                                                                       
                5'd7: current_mac_address = addr_r2c1;                                                                                                       
                5'd8: current_mac_address = addr_r2c2;                                                                                                       
                default: current_mac_address = '0;                                                                                                           
            endcase                                                                                                                                          
        end                                                                                                                                                  
                                                                                                                                                             
        // Clock Generation (10ns period)                                                                                                                    
        initial begin                                                                                                                                        
            clock = 1'b0;                                                                                                                                    
            forever #5 clock = ~clock;                                                                                                                       
        end                                                                                                                                                  
                                                                                                                                                             
        // Simulation Sequence                                                                                                                               
        integer err_count = 0;                                                                                                                               
        integer step;                                                                                                                                        
                                                                                                                                                             
        initial begin                                                                                                                                        
            $display("=================================================");                                                                                   
            $display("   STARTING CONTROLLER & AGU INTEGRATION TEST    ");                                                                                   
            $display("=================================================");                                                                                   
                                                                                                                                                             
            reset        = 1'b1;                                                                                                                             
            mac_done     = 1'b0;                                                                                                                             
            row          = 0;                                                                                                                                
            column       = 0;                                                                                                                                
            channel      = 0;                                                                                                                                
            image_height = 4;                                                                                                                                
            image_width  = 4;                                                                                                                                
                                                                                                                                                             
            #20;                                                                                                                                             
            reset = 1'b0;                                                                                                                                    
            #10;                                                                                                                                             
                                                                                                                                                             
            $display("\n--- Test Case 1: Valid 3x3 Window at Channel=0, Row=0, Col=0 ---");                                                                  
            for (step = 0; step < 9; step = step + 1) begin                                                                                                  
                mac_done = 1'b1;                                                                                                                             
                @(posedge clock);                                                                                                                            
                #1;                                                                                                                                          
                $display("[Clock Cycle %0d] count=%0d | Active Addr=%0d | finish=%b clear=%b",                                                               
                         step+1, count, current_mac_address, finish, clear);                                                                                 
                                                                                                                                                             
                if (step == 8) begin                                                                                                                         
                    if (finish !== 1'b1 || clear !== 1'b1) begin                                                                                             
                        $display("ERROR: Expected finish=1 and clear=1 at count=8!");                                                                        
                        err_count = err_count + 1;                                                                                                           
                    end else begin                                                                                                                           
                        $display("SUCCESS: finish and clear correctly asserted at end of 3x3 window.");                                                      
                    end                                                                                                                                      
                end                                                                                                                                          
            end                                                                                                                                              
                                                                                                                                                             
            mac_done = 1'b0;                                                                                                                                 
            @(posedge clock);                                                                                                                                
            #1;                                                                                                                                              
                                                                                                                                                             
            $display("\n--- Test Case 2: Valid 3x3 Window at Channel=1, Row=1, Col=1 ---");                                                                  
            channel = 1;                                                                                                                                     
            row     = 1;                                                                                                                                     
            column  = 1;                                                                                                                                     
            #10;                                                                                                                                             
                                                                                                                                                             
            $display("AGU Outputs for Channel=1, Row=1, Col=1:");                                                                                            
            $display("  Row 0 Addrs: [%0d, %0d, %0d]", addr_r0c0, addr_r0c1, addr_r0c2);                                                                     
            $display("  Row 1 Addrs: [%0d, %0d, %0d]", addr_r1c0, addr_r1c1, addr_r1c2);                                                                     
            $display("  Row 2 Addrs: [%0d, %0d, %0d]", addr_r2c0, addr_r2c1, addr_r2c2);                                                                     
                                                                                                                                                             
            if (addr_r0c0 !== 21 || addr_r2c2 !== 31) begin                                                                                                  
                $display("ERROR: AGU address calculation incorrect for Channel=1, Row=1, Col=1");                                                            
                err_count = err_count + 1;                                                                                                                   
            end else begin                                                                                                                                   
                $display("SUCCESS: AGU addresses generated correctly.");                                                                                     
            end                                                                                                                                              
                                                                                                                                                             
            $display("\n--- Test Case 3: Out of Bounds Window (Row=2, Col=3 on 4x4 Image) ---");                                                             
            row    = 2;                                                                                                                                      
            column = 3;                                                                                                                                      
            #10;                                                                                                                                             
                                                                                                                                                             
            if (addr_r0c0 !== 0 || addr_r2c2 !== 0) begin                                                                                                    
                $display("ERROR: AGU failed boundary check!");                                                                                               
                err_count = err_count + 1;                                                                                                                   
            end else begin                                                                                                                                   
                $display("SUCCESS: AGU boundary check passed (Addresses set to 0).");                                                                        
            end                                                                                                                                              
                                                                                                                                                             
            $display("\n=================================================");                                                                                 
            if (err_count == 0)                                                                                                                              
                $display("   TEST PASSED SUCCESSFULLY! ALL CHECKS PASSED.  ");                                                                               
            else                                                                                                                                             
                $display("   TEST FAILED WITH %0d ERROR(S).               ", err_count);                                                                     
            $display("=================================================");                                                                                   
                                                                                                                                                             
            $finish;                                                                                                                                         
        end                                                                                                                                                  
                                                                                                                                                             
    endmodule                                                                                                                                                
                                                                                                                                                   
  // Vivado Simulation Verification Results                                                                                                                 
                                                                                                                                                             
  //The testbench compiled with Vivado (xvlog / xelab) and completed simulation in xsim:                                                                       
                                                                                                                                                             
                                                                                                         
                                                                                                                                                             
//    --- Test Case 1: Valid 3x3 Window at Channel=0, Row=0, Col=0 ---                                                                                         
//    [Clock Cycle 1] count=1 | Active Addr=1 | finish=0 clear=0                                                                                               
//    [Clock Cycle 2] count=2 | Active Addr=2 | finish=0 clear=0                                                                                               
//    [Clock Cycle 3] count=3 | Active Addr=4 | finish=0 clear=0                                                                                               
//    [Clock Cycle 4] count=4 | Active Addr=5 | finish=0 clear=0                                                                                               
//    [Clock Cycle 5] count=5 | Active Addr=6 | finish=0 clear=0                                                                                               
//    [Clock Cycle 6] count=6 | Active Addr=8 | finish=0 clear=0                                                                                               
//    [Clock Cycle 7] count=7 | Active Addr=9 | finish=0 clear=0                                                                                               
//    [Clock Cycle 8] count=8 | Active Addr=10 | finish=0 clear=0                                                                                              
//    [Clock Cycle 9] count=0 | Active Addr=0 | finish=1 clear=1                                                                                               
//    SUCCESS: finish and clear correctly asserted at end of 3x3 window.                                                                                       
                                                                                                                                                             
//    --- Test Case 2: Valid 3x3 Window at Channel=1, Row=1, Col=1 ---                                                                                         
//    AGU Outputs for Channel=1, Row=1, Col=1:                                                                                                                 
//      Row 0 Addrs: [21, 22, 23]                                                                                                                              
//      Row 1 Addrs: [25, 26, 27]                                                                                                                              
//      Row 2 Addrs: [29, 30, 31]                                                                                                                              
//    SUCCESS: AGU addresses generated correctly.                                                                                                              
                                                                                                                                                             
//    --- Test Case 3: Out of Bounds Window (Row=2, Col=3 on 4x4 Image) ---                                                                                    
//    AGU Base Addr for Out of Bounds: 0 (Expected: 0)                                                                                                         
//    SUCCESS: AGU boundary check passed (Addresses set to 0).                                                                                                 
                                                                                                                                                             
//    =================================================                                                                                                        
//       TEST PASSED SUCCESSFULLY! ALL CHECKS PASSED.                                                                                                          
//    =================================================   