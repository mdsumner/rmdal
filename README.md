
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rmdal

<!-- badges: start -->

<!-- badges: end -->

rmdal provides R bindings to the [MDAL (Mesh Data Abstraction
Library)](https://www.mdal.xyz/), enabling R users to read and write
unstructured mesh data from numerous formats used in hydrology,
meteorology, and numerical modelling.

MDAL is an [OSGeo Community
Project](https://www.osgeo.org/projects/mdal/) developed by [Lutra
Consulting](https://www.lutraconsulting.co.uk/) and provides the mesh
layer functionality in QGIS.

## Supported Formats

rmdal supports all formats provided by MDAL, including:

- **2DM** - SMS/TUFLOW mesh files
- **UGRID** - NetCDF unstructured grid (CF conventions)
- **Selafin** - TELEMAC hydrodynamic output
- **HEC-RAS 2D** - HEC-RAS hydraulic modelling
- **FLO-2D** - FLO-2D flood modelling
- **GRIB** - Meteorological data
- **NetCDF** - Generic scientific data
- **XMDF** - TUFLOW results
- And many more…

Use `mdal_drivers()` to see all available drivers and their
capabilities.

## Installation

rmdal requires the MDAL library to be installed on your system.

### Install MDAL

**Via conda (recommended):**

``` bash
conda install -c conda-forge mdal
```

**From source:**

``` bash
git clone https://github.com/lutraconsulting/MDAL.git
cd MDAL && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make && sudo make install
```

### Install rmdal

``` r
# Install from GitHub
# install.packages("pak")
pak::pak("mdsumner/rmdal")
```

## Usage

``` r
library(rmdal)

# Check MDAL version
mdal_version()

# List available drivers
mdal_drivers()

# Load a mesh
mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
mesh <- mdal_load(mfile)

# Query mesh properties
mdal_mesh_vertex_count(mesh)
mdal_mesh_face_count(mesh)
mdal_mesh_projection(mesh)
```

    #> [1] "1.3.1"

``` r
# Available drivers
mdal_drivers()[, c("name", "long_name", "can_read_mesh")]
#>                          name                  long_name can_read_mesh
#> 1                       *.2dm                      *.2dm          TRUE
#> 2                        \036                      *.tin          TRUE
#> 3  *.slf;;*.ser;;*.geo;;*.res *.slf;;*.ser;;*.geo;;*.res          TRUE
#> 4                       *.adf                      *.adf          TRUE
#> 5                       *.ply                      *.ply          TRUE
#> 6          *.nc;;*.DAT;;*.OUT         *.nc;;*.DAT;;*.OUT          TRUE
#> 7                       *.hdf                      *.hdf          TRUE
#> 8                        *.nc                       *.nc          TRUE
#> 9                       *.sww                      *.sww          TRUE
#> 10                       *.nc                       *.nc          TRUE
#> 11             results_3di.nc             results_3di.nc          TRUE
#> 12                       *.nc                       *.nc          TRUE
#> 13              \021FR\u0088U              \021FR\u0088U          TRUE
#> 14                     *.json                     *.json          TRUE
#> 15                      *.dat                      *.dat         FALSE
#> 16                      *.dat                      *.dat         FALSE
#> 17               *.xmdf;;*.h5               *.xmdf;;*.h5          TRUE
#> 18              *.xdmf;;*.xmf              *.xdmf;;*.xmf         FALSE
#> 19                     *.mesh                     *.mesh          TRUE
```

## Roadmap

rmdal is under active development. Planned features include:

- [ ] Vertex, face, and edge geometry extraction
- [ ] Dataset group and dataset access (temporal data)
- [ ] S7 classes for mesh objects
- [ ] Integration with wk for geometry interchange
- [ ] Integration with rgl for 3D visualization
- [ ] Mesh creation and writing

## Data Model

MDAL provides access to unstructured mesh data with the following
hierarchy:

    Mesh
    ├── Vertices (x, y, z coordinates)
    ├── Faces (polygons defined by vertex indices)
    ├── Edges (1D elements for network meshes)
    └── Dataset Groups (e.g., "Depth", "Velocity")
        └── Datasets (values at specific times)
            └── Values (scalar or vector, on vertices/faces/volumes)

Fidelity note: MDAL’s data model is richer than what simple features
(sf) can represent. Converting to sf necessarily loses information like
temporal datasets, 3D volumes, and the vertex-index topology. rmdal aims
to preserve MDAL’s native model internally and provide targeted
conversions for interoperability.

## Related Projects

- [MDAL](https://www.mdal.xyz/) - The underlying C++ library
- [QGIS](https://qgis.org/) - Uses MDAL for mesh layer support
- [Crayfish](https://plugins.qgis.org/plugins/crayfish/) - QGIS plugin
  for mesh visualization
- [anglr](https://github.com/hypertidy/anglr/) - R package Mesh creation
  and topology for spatial data
- [rgl](https://github.com/dmurdoch/rgl/) - R package 3D visualization
  system based on OpenGL.

## License

MIT © Michael Sumner

rmdal includes bindings to MDAL which is MIT licensed. Copyright © Lutra
Consulting.
