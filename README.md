
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

Currently this has only been run on Linux (ubuntu, 24.04).

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

rmdal requires the MDAL library to be installed.

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
#> [1] "1.3.1"

# List available drivers
mdal_drivers()[, c("name", "long_name", "can_read_mesh")]
#>          name                    long_name can_read_mesh
#> 1         2DM                2DM Mesh File          TRUE
#> 2     XMS_TIN            XMS Tin Mesh File          TRUE
#> 3     SELAFIN                 Selafin File          TRUE
#> 4    ESRI_TIN                     Esri TIN          TRUE
#> 5         PLY Stanford PLY Ascii Mesh File          TRUE
#> 6       FLO2D                        Flo2D          TRUE
#> 7       HEC2D                   HEC-RAS 2D          TRUE
#> 8    TUFLOWFV                    TUFLOW FV          TRUE
#> 9         SWW                        AnuGA          TRUE
#> 10      Ugrid                        UGRID          TRUE
#> 11        3Di                  3Di Results          TRUE
#> 12     NETCDF                  GDAL NetCDF          TRUE
#> 13       GRIB                    GDAL Grib          TRUE
#> 14        H2I                H2i Mesh File          TRUE
#> 15  ASCII_DAT                          DAT         FALSE
#> 16 BINARY_DAT                   Binary DAT         FALSE
#> 17       XMDF                  TUFLOW XMDF          TRUE
#> 18       XDMF                         XDMF         FALSE
#> 19     Mike21             Mike21 Mesh File          TRUE

# Load a mesh (mixed triangles and quads)
f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
                 package = "rmdal", mustWork = TRUE)
mesh <- mdal_load(f)

# Query mesh properties
mdal_mesh_vertex_count(mesh)
#> [1] 5
mdal_mesh_face_count(mesh)
#> [1] 2
mdal_mesh_driver_name(mesh)
#> [1] "2DM"

# Extract geometry
v <- mdal_mesh_vertices(mesh)
head(v)
#>      [,1] [,2] [,3]
#> [1,] 1000 2000   20
#> [2,] 2000 2000   30
#> [3,] 3000 2000   40
#> [4,] 2000 3000   50
#> [5,] 1000 3000   10

faces <- mdal_mesh_faces(mesh)
lengths(faces)  # Mixed: 4 vertices (quad) + 3 vertices (triangle)
#> [1] 4 3

# Convert to rgl-compatible mesh3d (wireframe)
m3d <- mdal_as_mesh3d(mesh, type = "wire")
class(m3d)
#> [1] "mesh3d"  "shape3d"
dim(m3d$vb)  # 4 x n vertices (homogeneous coords)
#> [1] 4 5
dim(m3d$is)  # 2 x n segments
#> [1] 2 7
```

``` r
# 1D mesh with edges (lines, no faces)
f_1d <- system.file("extdata/MDAL/tests/data/2dm/lines.2dm",
                    package = "rmdal", mustWork = TRUE)
mesh_1d <- mdal_load(f_1d)
mdal_mesh_edge_count(mesh_1d)
#> [1] 3
mdal_mesh_face_count(mesh_1d)
#> [1] 0
```

``` r
# Mesh with CRS
f_crs <- system.file("extdata/MDAL/tests/data/mike21/small.mesh",
                     package = "rmdal", mustWork = TRUE)
mesh_crs <- mdal_load(f_crs)
mdal_mesh_projection(mesh_crs)
#> [1] "LONG/LAT"
```

## Roadmap

rmdal is under active development.

### Implemented

- [x] Vertex, face, and edge geometry extraction
- [x] Conversion to rgl mesh3d format (wireframe and solid)
- [x] Dataset group and dataset access (temporal data):
  `mdal_mesh_dataset_group_count()`, `mdal_dataset_group_name()`,
  `mdal_dataset_group_location()`, `mdal_dataset_group_is_scalar()`,
  `mdal_dataset_group_dataset_count()`, `mdal_dataset_time()`,
  `mdal_dataset_values()` (`mdal_dataset_group_is_scalar()` needs the
  native-routine registration fix in PR #1)

### Planned

- [ ] Dataset values to mesh3d colors
- [ ] S7 classes for mesh objects
- [ ] Integration with wk for geometry interchange
- [ ] Mesh creation and writing

## Data Model

MDAL provides access to unstructured mesh data with the following
hierarchy:

    Mesh
    |-- Vertices (x, y, z coordinates)
    |-- Faces (polygons defined by vertex indices)
    |-- Edges (1D elements for network meshes)
    `-- Dataset Groups (e.g., "Depth", "Velocity")
        `-- Datasets (values at specific times)
            `-- Values (scalar or vector, on vertices/faces/volumes)

Fidelity note: MDAL’s data model is richer than what simple features
(sf) can represent. Converting to sf necessarily loses information like
temporal datasets, 3D volumes, and the vertex-index topology. rmdal aims
to preserve MDAL’s native model internally and provide targeted
conversions for interoperability.

## Known limitations

These come from MDAL itself and were found joining MDAL topology to GDAL
multidimensional arrays on UGRID files:

- For 2D UGRID meshes MDAL loads no edges (`mdal_mesh_edge_count()` is
  0 even when the file stores `edge_node_connectivity`), so arrays on
  the edge dimension have no topology to bind to. Read the edge
  connectivity from the file directly when you need it.
- When no mesh driver claims a netCDF file, MDAL can fall back to the
  GDAL netCDF raster driver and return a grid that is not the file's
  mesh. Check `mdal_mesh_driver_name()`.

## Related Projects

- [MDAL](https://www.mdal.xyz/) - The underlying C++ library
- [QGIS](https://qgis.org/) - Uses MDAL for mesh layer support
- [Crayfish](https://plugins.qgis.org/plugins/crayfish/) - QGIS plugin
  for mesh visualization
- [anglr](https://github.com/hypertidy/anglr/) - R package for mesh
  creation and topology
- [rgl](https://github.com/dmurdoch/rgl/) - R package for 3D
  visualization (mesh3d format)

## License

MIT © Michael Sumner

rmdal includes bindings to MDAL which is MIT licensed. Copyright © Lutra
Consulting.
