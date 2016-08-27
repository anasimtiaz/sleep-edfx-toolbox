Sleep EDFx Toolbox
==================

A toolbox to download, extract, load and view signals from the PhysioNet Sleep EDF Expanded Database.

This work is part of the research performed at the [Rodriguez-Villegas Lab, Imperial College London, UK](http://www.imperial.ac.uk/rodriguez-villegas-lab).

##Citations##

Please cite the following publication when using this toolbox:

For this toolbox:

*Imtiaz, S.A.; Rodriguez-Villegas, E., "An Open-source Toolbox For Standardized Use Of PhysioNet Sleep EDF Expanded Database," in Engineering in Medicine and Biology Society (EMBC), 2015 37th Annual International Conference of the IEEE, 2015*

Standard PhysioNet citation:

*Goldberger AL, Amaral LAN, Glass L, Hausdorff JM, Ivanov PCh, Mark RG, Mietus JE, Moody GB, Peng C-K, Stanley HE. PhysioBank, PhysioToolkit, and PhysioNet: Components of a New Research Resource for Complex Physiologic Signals. Circulation 101(23):e215-e220 [Circulation Electronic Pages; http://circ.ahajournals.org/cgi/content/full/101/23/e215]; 2000* 

BioSig citation for EDF files conversion:

*Vidaurre, Carmen, Tilmann H. Sander, and Alois Schlögl. "BioSig: the free and open source software library for biomedical signal processing." Computational intelligence and neuroscience 2011 (2011).*


##Features##

* Download the complete set of 61 recordings 
* Extract the EDF files and convert them to Matlab signals
* Get Matlab-compatible hypnogram from the annotations
* Extract overnight sleep data and hypnogram from consistent start and end times
* View signals between any time along with its hypnogram
* Compute performance results
* Use RK or AASM classification



## Installation
* Download or clone the repository and add it to your path
* **IMPORTANT**: For EDF to Matlab conversion, [BioSig Toolbox](http://biosig.sourceforge.net/download.html) is required and its installation must be on the search path. Just download the MATLAB version and run the installer.



##Usage##

### All-in-one: download EDF files, annotations, extract data and process hypnograms

This is the simplest method to get started with the PhysioNet Sleep EDF Expanded database. 

```matlab
initialSetupEDFx(destination_directory)
```

* `destination_directory` is an optional argument to specify location for download

This function is needed only for the first time to get all the needed data and set up your working area with all the tests arranged in separate folders from where they can be loaded. Each test will be in a sub-directory inside the `destination_directory` and each newly created `test_directory` will have the source edf file, `matlab` folder with signals in .m files and an `info` folder with sampling frequency, list of channels and other annotations.

### Loading a test

```matlab
[data, f_samp, number_of_epochs, hypnogram, times] = loadEDFx(test_dir, classification_mode)
```

* Specify the top level `test_dir` of the test to be loaded. For example, `C:\Full_Path\ST7120`
* `classification_mode` to use can be either `'RK'` or `'AASM'`

The function returns the following:

* `data` is a container (dictionary) with all channels/signals in the test.
* Use `data.keys` to get a list of all available channels.
* To work with a particular channel's data, for example, fpz-cz you can load it as `data('eeg_fpz')`
* `f_samp` is the sampling frequency
* `number_of_epochs` is the number of 30-second epochs in the test (for overnight sleep)
* `hypnogram` is the corresponding hypnogram for each 30-s epoch in the loaded data
* `times` is a vector containing the start and end times of the test recording

Please refer to the following publication on how the starting and end times are calculated which in turn influence the total number of epochs. The publication also details the hypnogram conversion from RK to AASM.

**Recommendations for performance assessment of automatic sleep staging algorithms**, *SA Imtiaz and E Rodriguez-Villegas*, Engineering in Medicine and Biology Society (EMBC), 2014 36th Annual International Conference of the IEEE.


### Viewing signals for a test

```matlab
viewEDFxSignals(signal, times, start_time, end_time, f_samp, hypnogram)
```

* `signal` is any signal from the `data` container above. Only one signal can be passed here
* `times` is the reference obtained from above to determine original start and end times
* `start_time` is the time in hh:mm:ss format from where the signal is to be plotted
* `end_time` is the time in hh:mm:ss format up to which the signal is to be plotted
* `f_samp` is the sampling frequency
* `hypnogram` as obtained from `loadEDFx` function


### Compute performance metrics

```matlab
computeEDFxPerformance(test_hypnogram, ref_hypnogram, classification_mode)
```

* `test_hypnogram` is a Matlab vector with labels for each 30-s epoch
* `ref_hypnogram` is the reference obtained from `loadEDFx` function
* `classification_mode` can be either `'AASM'` or `'RK'`
* The `test_hypnogram` must conform to the same format as `ref_hypnogram` and use a single character to describe a sleep stage for each epoch. There are 'W','R','1','2','3' for AASM and includes 'M' and '4' for RK classification mode. An additional 'X' may be used for unknown stages.


### Other functions

The following functions are bundled in the `initialSetupEDFx()` function but can be called upon separately if needed.

##### Downloading EDF files for all tests

```matlab
[saved_file, status] = downloadEDFxData( )
[saved_file, status] = downloadEDFxData(destination_directory)
```

* `saved_file` is the full path of the downloaded EDF file 
* `status` corresponds to the success/failure of each file (it's download status)
* `destination_directory` is an optional argument to specify location for download


##### Downloading annotations for all tests

```matlab
downloadEDFxAnnotations( )
downloadEDFxAnnotations(destination_directory)
```

* `destination_directory` is an optional argument to specify location for download


##### Convert EDF files to Matlab

```matlab
convertEDFxToMat(saved_file, status)
```

* `saved_file` is the full path of the downloaded EDF file 
* `status` corresponds to the success/failure of each file (it's download status) and should not be 0 which indicates a failed download when used in the workflow
* The converted files are stored within the test directory
* This function requires the presence of [BioSig Toolbox](http://biosig.sourceforge.net/) toolbox available on the search path


##### Process hypnogram annotations

```matlab
hypnogram = processEDFxHypnogram(hyp_file)
```

* `hyp_file` is the annotations file with all sleep stages and their corresponding duration obtained from PhysioNet
* `hypnogram` contains a Matlab vector for labels corresponding to sleep stages for each 30-second epoch


## Issues

For any issues or bug reports please use GitHub Issues


## Contribute

Submit pull requests


## Contact

* Visit our research group website to know more about our work: [http://www.imperial.ac.uk/rodriguez-villegas-lab](http://www.imperial.ac.uk/rodriguez-villegas-lab)
* Contact me at [anas.imtiaz@imperial.ac.uk](mailto:anas.imtiaz@imperial.ac.uk)

## License

&copy; Syed Anas Imtiaz | 2015 | MIT License – [http://opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)

