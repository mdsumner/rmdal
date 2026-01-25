# rmdal (development version)

## rmdal 0.0.0.9000

Initial development release with core MDAL bindings.

### New features

* `mdal_version()` returns the version of the linked MDAL library.

* `mdal_drivers()` lists all available MDAL drivers and their capabilities
  (read mesh, write datasets, save mesh).

* `mdal_load()` loads a mesh file and returns an external pointer to the 
  MDAL mesh handle. Supports driver hints via URI syntax (e.g., 

  `'Ugrid:"file.nc":mesh2d'`).

* `mdal_mesh_vertex_count()` returns the number of vertices in a mesh.

* `mdal_mesh_face_count()` returns the number of faces in a mesh.

* `mdal_mesh_edge_count()` returns the number of edges (1D elements) in a mesh.

* `mdal_mesh_projection()` returns the CRS/projection string for a mesh.

* `mdal_mesh_driver_name()` returns the name of the driver used to load the mesh.

* `mdal_mesh_extent()` returns the bounding box (xmin, xmax, ymin, ymax) of the mesh.

* `mdal_mesh_dataset_group_count()` returns the number of dataset groups in a mesh.

* `mdal_last_status()` returns the status code from the last MDAL operation.

### Infrastructure

* Package uses cpp11 for C++ bindings to the MDAL C API.

* Configure script automatically finds MDAL via pkg-config or standard 
  system locations.

* Mesh handles are managed via external pointers with release callbacks,
  ensuring proper cleanup when garbage collected.
