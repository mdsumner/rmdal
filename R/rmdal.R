
#' MDAL Version
#'
#' Returns the version string of the linked MDAL library.
#'
#' @return Character string with MDAL version.
#' @export
#' @examples
#' mdal_version()
mdal_version <- function() {
  mdal_version_()
}

#' MDAL Last Status
#'
#' Returns the status code from the last MDAL operation.
#'
#' @return Integer status code. 0 indicates success (None), other values
#'   indicate errors or warnings. See MDAL documentation for status codes.
#' @export
#' @examples
#' mdal_last_status()
mdal_last_status <- function() {
  mdal_last_status_()
}

#' List MDAL Drivers
#'
#' Returns a data frame of available MDAL drivers and their capabilities.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{name}{Short driver name (e.g., "2DM", "UGRID", "Selafin")}
#'     \item{long_name}{Descriptive driver name}
#'     \item{can_read_mesh}{Logical; can this driver load mesh geometry?}
#'     \item{can_write_datasets}{Logical; can this driver write dataset values?}
#'     \item{can_save_mesh}{Logical; can this driver save mesh geometry?}
#'     \item{filters}{File extension filters (e.g., "*.nc", "*.2dm")}
#'   }
#' @export
#' @examples
#' mdal_drivers()
#'
#' # Find drivers that can write datasets
#' drv <- mdal_drivers()
#' drv[drv$can_write_datasets, ]
mdal_drivers <- function() {
  out <- mdal_drivers_()
  as.data.frame(out, stringsAsFactors = FALSE)
}

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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
#' mdal_mesh_vertex_count(mesh)
#' mdal_mesh_face_count(mesh)
#' mdal_mesh_projection(mesh)

mdal_load <- function(uri) {
  uri <- normalizePath(uri, mustWork = TRUE)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
#' mdal_mesh_edge_count(mesh)

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
#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
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

#' mfile <- system.file("extdata/dem_with_holes/tnz.adf", package = "rmdal", mustWork = TRUE)
#' mesh <- mdal_load(mfile)
#' mdal_mesh_dataset_group_count(mesh)

mdal_mesh_dataset_group_count <- function(mesh) {
  mdal_mesh_dataset_group_count_(mesh)
}
