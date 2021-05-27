# A VHDL implementation of the bitonic sort

This bitonic sort is based on the description given in:

* John Mellor-Crummy. Bitonic Sort. Rice University: [wiki.rice.edu](https://wiki.rice.edu/confluence/download/attachments/4435861/comp322-s12-lec28-slides-JMC.pdf?version=1&modificationDate=1333163955158)
* https://en.wikipedia.org/wiki/Bitonic_sorter
* https://www.cs.rutgers.edu/~venugopa/parallel_summer2012/bitonic_overview.html

The software implements the sorter using recursively generated entities using VHDL-2008. Because it targets FPGAs that allow initializing values, no reset is implemented. In other cases, a reset signal may be desired.

Note, there is also an HLS bitonic sort implementation in https://github.com/mmxsrup/bitonic-sort.