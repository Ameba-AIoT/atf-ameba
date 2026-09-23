# sp_min.mk looks for sp_min-${PLAT}.mk (PLAT=amebasmart) but the platform file
# is named sp_min-ameba.mk, so forward to it instead of duplicating the sources.
include ${PLAT_DIR}/sp_min/sp_min-ameba.mk
