CC      = gcc
FLEX    = flex
BISON   = bison

CPPFLAGS ?= -Ibuild
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
OBJECTS      := $(MAIN_OBJ) $(PARSER_OBJ) $(LEXER_OBJ)

.DEFAULT_GOAL := all

.PHONY: all test clean

all: $(TARGET)

$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

$(PARSER_C) $(PARSER_H) &: $(SRC_DIR)/parser.y | $(BUILD_DIR)
	$(BISON) --warnings=all --defines=$(PARSER_H) --output=$(PARSER_C) $<

$(LEXER_C): $(SRC_DIR)/lexer.l $(PARSER_H) | $(BUILD_DIR)
	$(FLEX) --outfile=$@ $<

$(MAIN_OBJ): $(SRC_DIR)/main.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(PARSER_OBJ): $(PARSER_C) $(PARSER_H) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(PARSER_C) -o $@

$(LEXER_OBJ): $(LEXER_C) $(PARSER_H) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(LEXER_C) -o $@

$(TARGET): $(OBJECTS) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LDLIBS) -o $@

test: $(TARGET)
	bash scripts/test_smoke.sh

clean:
	rm -rf -- $(BUILD_DIR) $(BIN_DIR)
