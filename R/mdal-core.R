
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
