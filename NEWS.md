# rmdal 0.1.0

Initial development release with core MDAL bindings.

### New features

* `mdal_mesh_vertices()` returns all vertex coordinates as an Nx3 matrix.

* `mdal_mesh_faces()` returns face definitions as a list of vertex index vectors.
  Supports varying face sizes (triangles, quads, n-gons).

* `mdal_mesh_edges()` returns 1D edge elements as an Nx2 matrix of vertex indices.

* `mdal_as_mesh3d()
` converts MDAL meshes to rgl-compatible mesh3d objects:
  

  - `type = "wire"` (default) creates wireframe from face boundaries. Works for 
    any topology including mixed faces and n-gons.
  - `type = "solid"` creates filled mesh for pure triangle or quad meshes.
  - No rgl dependency required - creates the list structure directly.

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

### Test data

* Package includes minimal MDAL test files (~25 KB) covering:
  - Mixed triangle/quad meshes, pure 1D edges, hexagonal faces
  - Multiple drivers: 2DM, Mike21, PLY, UGRID, ESRI TIN
  - Directory-based formats (ESRI TIN)
  - Files with CRS and multiple dataset groups

### Infrastructure

* Package uses cpp11 for C++ bindings to the MDAL C API.

* Configure script automatically finds MDAL via pkg-config or standard 
  system locations.

* Mesh handles are managed via external pointers with release callbacks,
  ensuring proper cleanup when garbage collected.
