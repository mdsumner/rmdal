#include <cpp11.hpp>
#include <mdal.h>

using namespace cpp11;

[[cpp11::register]]
std::string mdal_version_() {

  return std::string(MDAL_Version());
}

[[cpp11::register]]
int mdal_last_status_() {
  return static_cast<int>(MDAL_LastStatus());
}

[[cpp11::register]]
int mdal_driver_count_() {
  return MDAL_driverCount();
}

[[cpp11::register]]
list mdal_drivers_() {
  int n = MDAL_driverCount();

  writable::strings names(n);
  writable::strings long_names(n);
  writable::logicals can_read_mesh(n);
  writable::logicals can_write_datasets(n);
  writable::logicals can_save_mesh(n);
  writable::strings filters(n);


  for (int i = 0; i < n; i++) {
    MDAL_DriverH drv = MDAL_driverFromIndex(i);

    const char* name = MDAL_DR_name(drv);
    const char* long_name = MDAL_DR_longName(drv);
    const char* flt = MDAL_DR_filters(drv);

    // Copy immediately before next MDAL call overwrites buffer
    names[i] = MDAL_DR_name(drv) ? MDAL_DR_name(drv) : "";
    long_names[i] = MDAL_DR_longName(drv) ? MDAL_DR_longName(drv) : "";
    filters[i] = MDAL_DR_filters(drv) ? MDAL_DR_filters(drv) : "";

    can_read_mesh[i] = MDAL_DR_meshLoadCapability(drv);
    can_write_datasets[i] = MDAL_DR_writeDatasetsCapability(drv, MDAL_DataLocation::DataOnVertices) ||
                            MDAL_DR_writeDatasetsCapability(drv, MDAL_DataLocation::DataOnFaces);
    can_save_mesh[i] = MDAL_DR_saveMeshCapability(drv);
  }

  writable::list out({
    "name"_nm = names,
    "long_name"_nm = long_names,
    "can_read_mesh"_nm = can_read_mesh,
    "can_write_datasets"_nm = can_write_datasets,
    "can_save_mesh"_nm = can_save_mesh,
    "filters"_nm = filters
  });

  return out;
}
