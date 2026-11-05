# Nom de l'entitat principal del Testbench (no el fitxer .vhd)
TB_ENTITY = tb_emu_rx

# Arxiu VCD de sortida per a GTKWave
VCD_FILE = simulacio.vcd
GHW_FILE = simulacio.ghw
SAVE_FILE = waves.gtkw

# Estàndard VHDL (93, 00, 08). Canvia a 08 si fas servir VHDL-2008
# Afegir $(VHDL_STD) a la comanda si cal un estandar especial
VHDL_STD = --std=08

# Tots els fitxers VHDL font en l'ordre de dependència correcte (de baix a dalt)
SOURCES = \
	error_counter.vhd \
	mock_tx_module_rx.vhd \
	mock_rx_module_rx.vhd \
	mock_r_queue.vhd \
	timer.vhd \
	emu_rx.vhd \
	tb_emu_rx.vhd

# Regla per defecte quan s'executa 'make'
all: sim

# 1. Analitzar i elaborar tots els fitxers
build: $(SOURCES)
	ghdl -a $(VHDL_STD) $(SOURCES)
	ghdl -e $(VHDL_STD) $(TB_ENTITY)

# 2. Executar la simulació i generar l'arxiu VCD
sim: build
	ghdl -r $(VHDL_STD) $(TB_ENTITY) --wave=$(GHW_FILE)

# 3. Obrir la simulació a GTKWave
view: sim
	@if [ -f $(SAVE_FILE) ]; then \
		gtkwave $(GHW_FILE) $(SAVE_FILE); \
	else \
		gtkwave $(GHW_FILE); \
	fi

# Netejar els fitxers generats per GHDL i GTKWave
clean:
	ghdl --remove
	rm -f *.o $(TB_ENTITY) $(VCD_FILE) $(GHW_FILE) $(SAVE_FILE) work-obj*.cf

.PHONY: all build sim view clean
