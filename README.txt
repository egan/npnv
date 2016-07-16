To run NION's Presidential NGram Viewer, type
	ngram
at MATLAB's command prompt while in the appropriate directory.

To search with up to three regular expressions, enter them into the respective text input boxes and be sure to enable at least one.
Set the case sensitivity, as phrase, and literal string toggles as desired.
If you want to search for more than three regular expressions, you may load a well-formed plaintext file, with one regular expression per line.
We have included a sample regular expression list file, regexlist.dat.

To plot data or save data press "Plot" or "Save" respectively.
By default, it will search the speeches of all presidents, but you can change filters in the lower portion of the GUI.
Filtering can be done manually or by file input for either presidential indices or years.
If you elect to filter by file, be sure to load a well-formed plaintext file, with one index or year per line.
We have included some sample filter files, preslist1.dat, preslist2.dat, and yearlist.dat.

Each plot is displayed in a new figure window, and all the normal figure functionality is maintained, including the ability to zoom and save.
If only data is requested, you will be prompted to save a MATLAB *.mat file.

For more information, please refer to the writeup, main.pdf.
