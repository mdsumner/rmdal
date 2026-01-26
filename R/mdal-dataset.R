#' Get Dataset Group Name
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @return Character string with group name.
#' @export
mdal_dataset_group_name <- function(mesh, group = 0L) {

  mdal_dataset_group_name_(mesh, as.integer(group))
}

#' Get Dataset Count in Group
#'
#' Returns the number of datasets (timesteps) in a dataset group.
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @return Integer count of datasets.
#' @export
mdal_dataset_group_dataset_count <- function(mesh, group = 0L) {
  mdal_dataset_group_dataset_count_(mesh, as.integer(group))
}

#' Get Dataset Group Data Location
#'
#' Returns where the data values are located: on vertices, faces, edges, or volumes.
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @return Character: "vertices", "faces", "edges", "volumes", or "unknown".
#' @export
mdal_dataset_group_location <- function(mesh, group = 0L) {
  mdal_dataset_group_location_(mesh, as.integer(group))
}

#' Check if Dataset Group is Scalar
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @return Logical: TRUE for scalar data, FALSE for vector (x,y components).
#' @export
mdal_dataset_group_is_scalar <- function(mesh, group = 0L) {
  mdal_dataset_group_is_scalar_(mesh, as.integer(group))
}

#' Get Dataset Values
#'
#' Extracts the data values from a specific dataset (timestep) within a group.
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @param dataset Zero-based index of the dataset within the group.
#' @return Numeric vector of values. Length matches vertex/face/edge count
#'   depending on the group's data location.
#' @export
#' @examples
#' \dontrun{
#' mesh <- mdal_load('NETCDF:"file.nc":varname')
#' mdal_dataset_group_name(mesh, 0)
#' vals <- mdal_dataset_values(mesh, group = 0, dataset = 0)
#' }
mdal_dataset_values <- function(mesh, group = 0L, dataset = 0L) {
  mdal_dataset_values_(mesh, as.integer(group), as.integer(dataset))
}

#' Get Dataset Time
#'
#' Returns the time value for a specific dataset within a group.
#'
#' @param mesh External pointer to MDAL mesh.
#' @param group Zero-based index of the dataset group.
#' @param dataset Zero-based index of the dataset within the group.
#' @return Numeric time value, or NA if not available.
#' @export
mdal_dataset_time <- function(mesh, group = 0L, dataset = 0L) {
  mdal_dataset_time_(mesh, as.integer(group), as.integer(dataset))
}
