# NEL1_2
NEL2 code with RP2 on top rack and RX8 after 4 PA5s. Based on NEL1 codes using 4 RP2s and 4 PA5s. Previously, NEL2 was based on a single RX8 and no RP2s. 

To-Do list: 
(1) Add SFR in TDT pink noise functionality from RX8-based NEL2
(2) Confirm intensity calc for (f1, f2) in DPOAE is working - saw weird intensities at some frequencies. But likely because of steep calibration using syringe. For animals (smooth calib), should be okay. But confirm. 
(3) Turn as many scripts as possible to functions - really difficult to track all the variables not knowing what variables are passed onto scripts. 
(4) rename RP1,2,3,4 in CAP codes to something tdt_stim_module, tdt_bitset_module, tdt_dac_module for better readability. Because RP3 can be RX8. Can becomes difficult to understand code flow and reasons behind such hack for someone new without knowing NEL history.
(5) Bit selection parts from CAP_left.rcx can be moved to to CAP_bitset.rcx (or we probably don't need) CAP_bitset.rcx, just move everything into CAP_left.rcx and rename it to CAP_stimGen_bitSet.rcx 
(6) All .rco files should be renamed to .rcx files 
(7) Remove nel.m from SP_NEL_GUI folder. It causes a lot of problem.
(8) ABR blackbox and ABR NEL GUI under SP_NEL_GUI use different codes. Try to keep the outer scripts separate, but the private scripts the same (lile concat_noise)
(9) ABR codes do not work for the fixed phase option 

NEL1 code

Starting on Apr 29 2019, to upgrade NEL1 from XP to W7
XP: NEL 1_1
W7: NEL 1_2 (started by copying just code of NEL1_1; then will upgrade to W7/MATLAB/NI, using Mark's version as a reference, but going from our code so we know ALL changes).
