#' MDAL Version
#'
#' Returns the version string of the linked MDAL library.
#'
#' @return Character string with MDAL version
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
#' @return Integer status code (0 = OK)
#' @export
mdal_last_status <- function() {
  mdal_last_status_()
}

#' List MDAL Drivers
#'
#' Returns a data frame of available MDAL drivers and their capabilities.
#'
#' @return Data frame with columns: name, long_name, can_read_mesh,
#'   can_write_datasets, can_save_mesh, filters
#' @export
#' @examples
#' mdal_drivers()
mdal_drivers <- function() {
  out <- mdal_drivers_()
  as.data.frame(out, stringsAsFactors = FALSE)
}
