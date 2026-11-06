# esdc-emu-frontend

This is a design for the UPC course "Electronic System design for Communications" lab to simulate 
a simple protocol controller defined in the course for serial communication between two nodes.

This code is to be used in the Fall semester of 2026.

There are two independent components, with each one emulating the response of the remote node:

* *emu_rx_mode* is used when designing the reception (RX) mode controller. The design emulates the response 
of a remote node sending a frame: An STX byte is sent, then a succession of bytes ending in an
EOT byte. The RX controller must reply with ACK after STX and EOT, and store the values
(including EOT) in a queue.
* *emu_tx_mode* is used when designing the TX controller. This code emulates the response of a remote node
receiving the frame: ACK messages are sent by the remote node after it receives STX and EOT bytes sent by the controller.

Each directory contains the different components to emulate the system: emulated transceiver (transmitter and receiver), 
emulated queue, timer and error counter. It also contains a VHDL testbench for simple verification of the emulator code, 
and a Makefile for simulation with [ghdl](https://github.com/ghdl/ghdl) and 
[GTKwave](https://github.com/gtkwave/gtkwave), an open source VHDL simulator and wave viewer.
