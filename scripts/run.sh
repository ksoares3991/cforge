#!/bin/bash

if [ ! -x build/executavel ]; then
	echo 'erro: executável não encontrado; execute ./cbuild build' >&2
	exit 1
fi

./build/executavel