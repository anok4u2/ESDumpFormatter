      $set sourceformat"variable"
       identification division.
       program-id. ESDumpSplitter.

       environment division.
       configuration section.
       file-control.
           select inputdump  assign to ws-infile
           organization line sequential
           file status is fs-stat.
       
           select outputdump assign to ws-outfile
           organization line sequential
           file status is fs-stat.

       data division.
       file section.
       fd  inputdump.
       01  in-dump-rec               pic x(255).

       fd  outputdump.
       01  out-dump-rec              pic x(255).

       working-storage section.
       78  78-table-max            value 2000000.
       01  wf-corruption-flag        pic 9.
           88  not-corrupt                 value 0.
           88  corruption-detected         value 1.
       01  ws-rename-filename      pic x(300).    
       01  ws-base                 pic x(255).
       01  ws-text1                pic x(30).
       01  ws-text2                pic x(30).
       01  ws-text3                pic x(30).
       01  ws-text4                pic x(30).
       01  ws-text5                pic x(30).
       01  ws-text6                pic x(30).
       01  ws-text7                pic x(30).
       01  ws-text8                pic x(30).
       01  ws-text9                pic x(30).
       01  ws-text10               pic x(30).
       01  ws-no-of-dumps          binary-long value 0.
       01  fs-stat                 pic xx.
       01  fs-stat2    redefines fs-stat.
           03  fs-char1            pic x.
           03  fs-char2            pic x comp-x.
       01  fs-disp                 pic 999.
       01  ws-infile               pic x(255).
       01  ws-outfile              pic x(255).

       01  ws-end-of-file-flag     pic x   value space.
           88  not-end-of-file             value space.
           88  end-of-file                 value "1".

       01  ws-cnt1                 pic s9(9) comp-5.
       01  ws-cnt2                 pic s9(9) comp-5.
       01  ws-cnt3                 pic s9(9) comp-5.
       01  ws-cnt4                 pic s9(9) comp-5.
       01  ws-control-num          pic s9(9) comp-5 value 0.
       01  ws-control-block-table.
           03  ws-control-block occurs 1 to 78-table-max
                                depending on ws-control-num
                            ascending key is ws-control-addr.
               05  filler          pic x(42).
               04  ws-control-addr pic x(213).
                            


       procedure division.
       
           perform get-inputfilename
       
           open input inputdump
           perform check-status

           perform read-input-dump
           perform process-record until end-of-file
           if ws-no-of-dumps > 0
               if ws-control-num > 0 
                   perform dump-memory-map
               end-if
               close outputdump
               perform check-status
               if corruption-detected
                   perform rename-corrupt-dump
               end-if
           end-if
           close inputdump
           perform check-status
           display "Total Number of Dumps Processed = " ws-no-of-dumps

           goback.
           
       get-inputfilename section.
       
      ***** Get File name from command line 
           accept ws-infile from command-line
           if ws-infile = spaces
               display "Usage : ESDumpSplitter filename"
               display "      For example:-"
               display "        ESDumpSplitter casdumpa.txt"
               display "The input is a text formatted ES Dump."
               stop run
           end-if
           .

       check-status section.

           if fs-stat not = zeros
               if fs-char1 = "9"
                   move fs-char2    to fs-disp
                   display "File Error " fs-char1 "/" fs-disp
               else
                   display "File Error " fs-stat
               end-if
               stop run
           end-if
           .
           
       read-input-dump section.
       
           read inputdump
               at end set end-of-file to true
                      exit section
           end-read
           perform check-status          
           .
           
       
       
       
       
       process-record section.
       
           if in-dump-rec(1:21) = "Start of storage dump"
               set not-corrupt to true                  
               if ws-no-of-dumps not = 0
                   if ws-control-num > 0 
                       perform dump-memory-map
                   end-if
                   close outputdump
                   perform check-status
               end-if
               perform gen-output-name          
           end-if

           if ws-no-of-dumps > 0
               move in-dump-rec to out-dump-rec
               write out-dump-rec
               perform check-status
           end-if 
           
     ****** Check to see if this is a control block
           move 0 to ws-cnt1 ws-cnt2 ws-cnt3
           inspect in-dump-rec
               tallying ws-cnt1 for all "-type "
                        ws-cnt2 for all "Address:"
                        ws-cnt3 for all "Length:"
           if ws-cnt1 > 0 and ws-cnt2 > 0 and ws-cnt3 > 0
               add 1 to ws-control-num
               move in-dump-rec to ws-control-block(ws-control-num)
           end-if
       
           perform read-input-dump
           .
           
       gen-output-name section.
       
           string ws-infile delimited by "."
               into ws-base
           end-string
           unstring in-dump-rec delimited by all spaces
               into ws-text1      
                    ws-text2
                    ws-text3
                    ws-text4
                    ws-text5
                    ws-text6
                    ws-text7
                    ws-text8
                    ws-text9
                    ws-text10
           end-unstring
           inspect ws-text6 replacing all "/" by "-"
           inspect ws-text9 replacing all ":" by "-"
           initialize ws-outfile
           string ws-base     delimited by space
                  "+"         delimited by size
                  ws-text6    delimited by space
                  "+"         delimited by size
                  ws-text9    delimited by space
                  ".txt"      delimited by size
               into ws-outfile
           end-string
           open output outputdump
           perform check-status 
           add 1 to ws-no-of-dumps  
           display "   Writing Dump >> " ws-outfile(1:50)
           .
           
       dump-memory-map section.
       
      ***** We will output a memory map of ES Control Blocks from the process
       
           move "Control Block Map" to out-dump-rec
           write out-dump-rec
           perform check-status

           move "=================" to out-dump-rec
           write out-dump-rec
           perform check-status
           
           write out-dump-rec from " "
           perform check-status

           sort ws-control-block
           perform varying ws-cnt1 from 1 by 1 until ws-cnt1 > ws-control-num
     ****** Check to see if this is possibly a corruption
               move 0 to ws-cnt2 ws-cnt3 ws-cnt4
               inspect ws-control-block(ws-cnt1)
                   tallying ws-cnt2 for all "local-dwe-ENQ-linear-type"
                            ws-cnt3 for all "Invalid-storage-area"
                            ws-cnt4 for all "recbuf-linear-type"
               if ws-cnt2 > 0 or ws-cnt3 > 0 or ws-cnt4
      *            call "CBL_DEBUGBREAK"
                   write out-dump-rec from "     ------- > NEXT BLOCK MAY BE CORRUPTED"
                   perform check-status
                   set corruption-detected to true
               end-if
               move ws-control-block(ws-cnt1) to out-dump-rec  
               write out-dump-rec
               perform check-status
           end-perform                                                                        
           move spaces to ws-control-block-table           
           move 0 to ws-control-num
           
           write out-dump-rec from " "
           perform check-status


           move "End of Control Block Map" to out-dump-rec
           write out-dump-rec
           perform check-status

           move "========================" to out-dump-rec
           write out-dump-rec
           perform check-status


           .

       rename-corrupt-dump section.
      ***** Think there could be Shared Memory Corruption so rename Dump to make it visable.      
           move spaces to ws-rename-filename
           string ws-outfile delimited by ".txt"
                  "-CORRUPTION-DETECTED.txt"
               into ws-rename-filename
           call "CBL_RENAME_FILE" using ws-outfile
                                        ws-rename-filename
           .

           
       end program ESDumpSplitter.