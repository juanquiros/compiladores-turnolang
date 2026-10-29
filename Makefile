CC      = gcc
FLEX    = flex
BISON   = bison

CPPFLAGS ?= -Ibuild -Isrc
CFLAGS   ?= -std=c11 -Wall -Wextra -Wpedantic
LDFLAGS  ?=
LDLIBS   ?=

BUILD_DIR := build
BIN_DIR   := bin
SRC_DIR   := src

ifeq ($(OS),Windows_NT)
EXEEXT := .exe
else
EXEEXT :=
endif

TARGET       := $(BIN_DIR)/turnolang$(EXEEXT)
PARSER_C     := $(BUILD_DIR)/parser.c
PARSER_H     := $(BUILD_DIR)/parser.h
LEXER_C      := $(BUILD_DIR)/lexer.c
MAIN_OBJ     := $(BUILD_DIR)/main.o
PARSER_OBJ   := $(BUILD_DIR)/parser.o
LEXER_OBJ    := $(BUILD_DIR)/lexer.o
AST_OBJ      := $(BUILD_DIR)/ast.o
AGENDA_OBJ   := $(BUILD_DIR)/agenda.o
SEMANTICA_OBJ := $(BUILD_DIR)/semantica.o
OBJECTS      := $(MAIN_OBJ) $(PARSER_OBJ) $(LEXER_OBJ) $(AST_OBJ) \
                $(AGENDA_OBJ) $(SEMANTICA_OBJ)

.DEFAULT_GOAL := all

.PHONY: all test clean

all: $(TARGET)

$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

$(PARSER_C) $(PARSER_H) &: $(SRC_DIR)/parser.y | $(BUILD_DIR)
	$(BISON) --warnings=all --defines=$(PARSER_H) --output=$(PARSER_C) $<

$(LEXER_C): $(SRC_DIR)/lexer.l $(PARSER_H) | $(BUILD_DIR)
	$(FLEX) --outfile=$@ $<

$(MAIN_OBJ): $(SRC_DIR)/main.c $(PARSER_H) $(SRC_DIR)/ast.h \
             $(SRC_DIR)/semantica.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(PARSER_OBJ): $(PARSER_C) $(PARSER_H) $(SRC_DIR)/ast.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(PARSER_C) -o $@

$(LEXER_OBJ): $(LEXER_C) $(PARSER_H) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(LEXER_C) -o $@

$(AST_OBJ): $(SRC_DIR)/ast.c $(SRC_DIR)/ast.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(AGENDA_OBJ): $(SRC_DIR)/agenda.c $(SRC_DIR)/agenda.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(SEMANTICA_OBJ): $(SRC_DIR)/semantica.c $(SRC_DIR)/semantica.h \
                  $(SRC_DIR)/ast.h $(SRC_DIR)/agenda.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LDLIBS) -o $@

test: $(TARGET)
	bash scripts/test_smoke.sh
	bash scripts/test_frontend.sh
	bash scripts/test_semantica.sh

clean:
	rm -rf -- $(BUILD_DIR) $(BIN_DIR)
