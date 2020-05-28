## CHEME-3130 Summer 2020 GitHub site
Example notebooks used in lecture are contained in the ``notebooks`` folder.

### How do I run the examples?
The examples presented in the CHEME 3130 lectures are available as [Jupyter notebooks](http://jupyter.org)
encoded in the [Julia](https://julialang.org) programming language. [Jupyter notebooks](http://jupyter.org)
require [Python](https://www.python.org). All of these technologies are platform independent and open source,
and can be easily installed on your local machine.

* See [here](http://jupyter.org/install.html) to install [Jupyter notebooks](http://jupyter.org) on your local machine.
[Jupyter notebooks](http://jupyter.org) require a working [Python](https://www.python.org) installation.
We __highly__ recommend the [Anaconda distribution](https://www.anaconda.com/download/#macos) implementation.
Once you have [Jupyter notebooks](http://jupyter.org) installed, see [here](https://jupyter.readthedocs.io/en/latest/running.html#running) for help running a notebook.

* See [here](https://julialang.org/downloads/) to install [Julia](https://julialang.org) locally.
However, for an easy all in one installation, please consider downloading/installing [JuliaPro](https://juliacomputing.com/products/juliapro); it comes with many common packages, and is integrated with the [Juno integrated development environment](https://junolab.org).

Once [Julia](https://julialang.org) has been installed, you'll need to add the [IJulia](https://github.com/JuliaLang/IJulia.jl) package to run [Julia](https://julialang.org) code in a [Jupyter notebook](http://jupyter.org).
To install [IJulia](https://github.com/JuliaLang/IJulia.jl), first [start Julia](https://docs.julialang.org/en/stable/manual/getting-started/) and then issue the command at the REPL prompt:

```
  julia> using Pkg; Pkg.add("IJulia")
```
### I don't want to do all that. Can I just look at the examples?
Sure! We have linked the GitHub code to [NBViewer](https://nbviewer.jupyter.org) which allows you to see the examples (but you can't change anything).

* [Expansion in an evacuated vessel](https://nbviewer.jupyter.org/github/varnerlab/CHEME-3130-SU2020/blob/master/notebooks/first_law_closed/EvacuatedVessel.ipynb)
* [Does N2 behave like an ideal gas?](https://nbviewer.jupyter.org/github/varnerlab/CHEME-3130-SU2020/blob/master/notebooks/heat_capacity_ideal/HeatCapacity-IdealGas.ipynb)
* [First and second law analysis of the Stirling cycle]()