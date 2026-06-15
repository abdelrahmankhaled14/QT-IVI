# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appIVIAutomotive_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appIVIAutomotive_autogen.dir/ParseCache.txt"
  "appIVIAutomotive_autogen"
  )
endif()
