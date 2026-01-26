

#' Load a Mesh File
#'
#' Loads a mesh file using MDAL. The returned object is an external pointer
#' to the MDAL mesh handle, which will be automatically closed when garbage
#' collected.
#'
#' @param uri Path to mesh file, or a URI with driver hint in the format
#'   `DriverName:"path"` or `DriverName:"path":meshname`. Examples:
#'   \itemize{
#'     \item `"path/to/mesh.2dm"` (auto-detect driver)
#'     \item `'Ugrid:"mesh.nc"'` (force UGRID driver)
#'     \item `'Ugrid:"mesh.nc":mesh2d'` (specific mesh within file)
#'   }
#'
#' @return An external pointer to the MDAL mesh handle. Use accessor functions
#'   like [mdal_mesh_vertex_count()], [mdal_mesh_face_count()], and
#'   [mdal_mesh_projection()] to query the mesh.
#'
#' @export
#' @examples
#' # Load a mesh with mixed triangles and quads
#' f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_vertex_count(mesh)
#' mdal_mesh_face_count(mesh)
mdal_load <- function(uri) {
  ## classic gotcha
  if (file.exists(uri)) {
    uri <- normalizePath(uri, mustWork = TRUE)
  }
  mdal_load_(uri)
}

#' Get Mesh Vertex Count
#'
#' Returns the number of vertices in a loaded mesh.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Integer count of vertices.
#' @export
#' @seealso [mdal_load()], [mdal_mesh_face_count()], [mdal_mesh_edge_count()]
#' @examples
#' f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_vertex_count(mesh)
mdal_mesh_vertex_count <- function(mesh) {
  mdal_mesh_vertex_count_(mesh)
}

#' Get Mesh Face Count
#'
#' Returns the number of faces in a loaded mesh.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Integer count of faces.
#' @export
#' @seealso [mdal_load()], [mdal_mesh_vertex_count()], [mdal_mesh_edge_count()]
#' @examples
#' f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_face_count(mesh)
mdal_mesh_face_count <- function(mesh) {
  mdal_mesh_face_count_(mesh)
}

#' Get Mesh Projection
#'
#' Returns the coordinate reference system (projection) string for a mesh,
#' if defined.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Character string with projection definition (e.g., WKT, PROJ string),
#'   or empty string `""` if undefined.
#' @export
#' @seealso [mdal_load()]
#' @examples
#' # Mike21 mesh has CRS defined
#' f <- system.file("extdata/MDAL/tests/data/mike21/small.mesh",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_projection(mesh)
mdal_mesh_projection <- function(mesh) {
  mdal_mesh_projection_(mesh)
}

#' Get Mesh Edge Count
#'
#' Returns the number of edges in a loaded mesh. Edges are used for 1D mesh
#' elements (e.g., river networks).
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Integer count of edges.
#' @export
#' @seealso [mdal_load()], [mdal_mesh_vertex_count()], [mdal_mesh_face_count()]
#' @examples
#' # Load a pure 1D mesh (lines only, no faces)
#' f <- system.file("extdata/MDAL/tests/data/2dm/lines.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_edge_count(mesh)
#' mdal_mesh_face_count(mesh)  # No faces in 1D mesh
mdal_mesh_edge_count <- function(mesh) {
  mdal_mesh_edge_count_(mesh)
}

#' Get Mesh Driver Name
#'
#' Returns the name of the MDAL driver used to load the mesh.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Character string with driver name (e.g., "2DM", "UGRID", "Selafin").
#' @export
#' @seealso [mdal_load()], [mdal_drivers()]
#' @examples
#' f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_driver_name(mesh)
mdal_mesh_driver_name <- function(mesh) {
  mdal_mesh_driver_name_(mesh)
}

#' Get Mesh Extent
#'
#' Returns the bounding box extent of the mesh in its native projection.
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return A named list with elements `xmin`, `xmax`, `ymin`, `ymax`.
#'   Values may be `NaN` if extent cannot be determined.
#' @export
#' @seealso [mdal_load()], [mdal_mesh_projection()]
#' @examples
#' f <- system.file("extdata/MDAL/tests/data/2dm/quad_and_triangle.2dm",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_extent(mesh)
mdal_mesh_extent <- function(mesh) {
  mdal_mesh_extent_(mesh)
}

#' Get Dataset Group Count
#'
#' Returns the number of dataset groups in a mesh. Dataset groups contain
#' temporal or thematic data (e.g., "Depth", "Velocity").
#'
#' @param mesh External pointer to MDAL mesh, as returned by [mdal_load()].
#'
#' @return Integer count of dataset groups.
#' @export
#' @seealso [mdal_load()]
#' @examples
#' # PLY file with multiple dataset groups
#' f <- system.file("extdata/MDAL/tests/data/ply/all_features.ply",
#'                  package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(f)
#' mdal_mesh_dataset_group_count(mesh)
mdal_mesh_dataset_group_count <- function(mesh) {
  mdal_mesh_dataset_group_count_(mesh)
}
