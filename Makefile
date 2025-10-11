# OpenSCAD Makefile for dts-modbus-enclosure
# Build STL files from SCAD sources

# Variables
OPENSCAD = openscad-nightly
OPENSCAD_FLAGS = --backend=manifold --enable=lazy-union --enable=roof
RENDER_DIR = renders
SOURCE_FILE = dts-modbus-enclosure.scad
TARGET_FILE = $(RENDER_DIR)/dts-modbus-enclosure.stl

# Default target
all: $(TARGET_FILE)

# Create renders directory if it doesn't exist
$(RENDER_DIR):
	mkdir -p $(RENDER_DIR)

# Build STL file from SCAD source
$(TARGET_FILE): $(SOURCE_FILE) | $(RENDER_DIR)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $(TARGET_FILE) $(SOURCE_FILE)

# Clean generated files
clean:
	rm -rf $(RENDER_DIR)

# Force rebuild
rebuild: clean all

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build STL file (default)"
	@echo "  clean   - Remove generated files"
	@echo "  rebuild - Clean and build"
	@echo "  help    - Show this help message"

# Declare phony targets
.PHONY: all clean rebuild help