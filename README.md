# MarinVibrator
Analyse sound recordings fom SpawnSeis Marine Vibrator experiment

Sound measurements was made with 4 naxys hydrophones in the bay of the telemetry study in the SpawnSeis project at Austevoll. In 2022 the source was a marine vibrator. 

The csv-files describes the hydrophones, the deployments and the sound treatments. The path to the data is given in the deployment file.

MVHydrophoneData calibrates and sorts data.
MVTreatmentData adds the wav-files (files with 23 second recording with 1 second brake between each file.). It makes one mat-file with the data for each 3 hour long exposure.

MVAnalyzeTreatment.m estimates the SEL for 1 hour (compensating for missing data), and for the whole 3 hour exposure without compenasating for the missing data (1/24 seconds).  It also estimates SEL and peak for every 10 seconds, with 9 seconds overlap. THe data is filtered with a butterworth filter from 5 - 10000 Hz. THis also removes the DC-component (vertical shift). It makes a mat-file for each exposure with the SEL and the peak values, and time for start and stop of the exposure.

compareTreatments reads the mat-files with SEL or peak and compares the sound in the 2 or 3 treatments for each of the blocks.

FrekvensanalyseSnuttar manually selects three 10 second periods for the max, min and medium sound level measured for block 1 at the outer part of the bay. The frequency distribution of the signal is investigated. 
