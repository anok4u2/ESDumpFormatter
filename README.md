# ESDumpFormatter
Basic Dump formatter to Post Process Dumps from Micro Focus Enterprise Server

It will run a format on the Dump and Auxiliary Trace files. Some post formatting will be done:

- Dumps will be split into files with date/time that dump was taken
- Memory map of Server Control blocks appended to dump
- Basic Checks for memory corruption

Use an Enterprise Developer/Visual COBOL command prompt to build and run cbllink esdumpsplitter to create an exe and put it on the path.

There is a bat file to perform the formatting.





