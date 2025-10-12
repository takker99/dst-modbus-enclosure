# OpenSCAD Makefile for dts-modbus-enclosure
# Build STL files from SCAD sources

# Variables
OPENSCAD = openscad
OPENSCAD_FLAGS = --backend=manifold --enable=lazy-union --enable=roof
RENDER_DIR = renders
SOURCE_FILES = dts-modbus-enclosure.scad modbus-board.scad
TARGET_FILES = $(patsubst %.scad,$(RENDER_DIR)/%.stl,$(SOURCE_FILES))

# Default target
all: $(TARGET_FILES)

# Create renders directory if it doesn't exist
$(RENDER_DIR):
	mkdir -p $(RENDER_DIR)

# Build STL files from SCAD sources
$(RENDER_DIR)/%.stl: %.scad | $(RENDER_DIR)
	$(OPENSCAD) $(OPENSCAD_FLAGS) -o $@ $<

# Clean generated files
clean:
	rm -rf $(RENDER_DIR)

# Force rebuild
rebuild: clean all

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build STL files (default)"
	@echo "  clean   - Remove generated files"
	@echo "  rebuild - Clean and build"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Current source files: $(SOURCE_FILES)"
	@echo "Target files: $(TARGET_FILES)"

# Declare phony targets
.PHONY: all clean rebuild help