This folder contains useful files and tools for the generation of maskers. The generation is done in two steps: 1) generation of config .JSON files (text files), 2) creation of wavefiles based on the information contained in the config files (note: better if done 'on the fly' during expe by Matlab, implemented in NEL). 

Config files and creation of wavefiles
-------------------

* `config.json`  in the main stimuli folder contains the general audio parameters required to create the WAV files. Ex:

    ```json 
    {
      "fs": 48828,
      "duration_s": 3,
      "filter_order": 64,
      "filter_order_mult":2
    }
    ```

    filter order is `filter_order x filter_order_mult` (cascade of Butterworth filters),  [x2 (band-pass filter)]

* The stimuli config files contain the other parameters required to generate the signals. Ex: 

    ```json
    {
      "type":"noise-bands",
      "n_bands":2,
      "name":"stim_ex",
      "bands":[
        {"amplitude":0.1, "fc_low":200, "fc_high":400},
        {"amplitude":1, "fc_low":4000, "fc_high":4500}
      ]
    }
    ```

    Note: wav files saturate at 1, it is advised to use amplitudes <1, but the values should not be too small neither (e.g. -20 dB for max spectral amplitude). 

* A config struct. can also have a field `extra_atten_dB` for extra attenuation (applied to every band).

* When a wave file is created with `create_signals.m` , info on the generation (basically the general audio config) is added to the stim json file (generally not needed because wavefiles can be generated during expe with NEL).  Ex: 

    ```json
    {
        "type":"noise-bands",
        "n_bands":2, 
        "name":"stim_ex",
        "bands":[
            {
                "amplitude":0.1, 
                "fc_low":200, 
                "fc_high":400
            }, 
            {
                "amplitude":1, 
                "fc_low":4000, 
                "fc_high":4500
            }
        ], 
        "wavefiles":[
            {
                "fs":48828, 
                "duration_s":3, 
                "filter_order":64, 
                "filter_order_mult":2, 
                "filename":"stim_ex_48828_128_3.wav"
            }
        ]
}
    ```
    
    

Creation of stim config files
----------------------------------------

- A small GUI `noiseBandMaskerDesigner.m` can be used to create the config files for the stimuli. The GUI defines mutiple bands (up to 8) ant their amplitude.
- Most of the application is self explanatory. The `Name` field at the bottom of the application will be the name of the stimulus and the file will be created as `stim_{name}`. The name can contains variables that depend on the parameters of the defined stimulus in brackets (see table below for band 1). These variables will be replaced by the real values.

| Variable                        | Value                                                        |
| ------------------------------- | ------------------------------------------------------------ |
| {fl1}, {fr1}                    | left (or right) cut-off frequency                            |
| {fc1}, {f_c1}                   | central frequency (fl+fr)/2                                  |
| {Df1}, {delta_f1}, {df1}, {bw1} | bandwidth  (fr-fl)                                           |
| {amp1}, {dB1}                   | amplitude in dB (with 'dB')                                  |
| {atten1}, {attn1}               | attenuation in dB  (with 'dB')                               |
| {pic}, {npic}                   | 'picture number'  <br />(counter that increments each time a stim. config file is created)  <br />note: choosing a new folder reinits npic |