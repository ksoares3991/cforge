#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SECONDS=0
SOURCE_DIR=""
GERAR_RELATORIO=0

for arg in "$@"; do
    case "$arg" in
        --report) GERAR_RELATORIO=1 ;;
        --verbose) VERBOSE=1 ;;
        --debug) DEBUG=1 ;;
        --*) echo "erro: opção inválida: $arg" >&2; exit 1 ;;
        *) [ -z "$SOURCE_DIR" ] && SOURCE_DIR="$arg" ;;
    esac
done

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
SOURCE_DIR="${SOURCE_DIR%/}"

INDISPONIVEL="indisponível"
LOG_FILE="$SOURCE_DIR/logs/cbuild.log"
EXEC_FILE="$SOURCE_DIR/build/$EXEC_NAME"

erro() {
	local mensagem="$1"
	local codigo="$2"
	echo "$mensagem" >&2
	log "info" "$SECONDS" "$codigo" "$mensagem"
	exit "$codigo"
}

listar_fontes() {
	local extensao="$1"
	find "$SOURCE_DIR" \
		\( -path "$SOURCE_DIR/build" -o -path "$SOURCE_DIR/logs" \) -prune -o \
		-type f -name "*.$extensao" -print
}

contar_loc() {
    local total=0 f n
    for f in "$@"; do
        n=$(grep -cve '^[[:space:]]*$' "$f" 2>/dev/null)
        n=${n:-0}
        total=$((total + n))
    done
    echo "$total"
}

data_ultima_operacao() {
	local procurado="$1"
	local data horario comando duracao codigo mensagem
	local resultado="$INDISPONIVEL"

	if [ ! -r "$LOG_FILE" ]; then
		echo "$resultado"
		return
	fi

	while IFS='|' read -r data horario comando duracao codigo mensagem; do
		if [ "$comando" = "$procurado" ] && [ "$codigo" = "0" ]; then
			resultado="$data $horario"
		fi
	done < "$LOG_FILE"

	echo "$resultado"
}

if [ ! -d "$SOURCE_DIR" ]; then
	echo "ERRO: diretório do projeto não encontrado $SOURCE_DIR" >&2
	exit 1
fi

if [ ! -r "$SOURCE_DIR" ] || [ ! -x "$SOURCE_DIR" ]; then
	erro "ERRO: permissões insuficientes para ler o diretório $SOURCE_DIR" 1
fi

arquivos_c=()
while IFS= read -r arquivo; do
	arquivos_c+=("$arquivo")
done < <(listar_fontes c)

arquivos_h=()
while IFS= read -r arquivo; do
	arquivos_h+=("$arquivo")
done < <(listar_fontes h)

total_arquivos=$(( ${#arquivos_c[@]} + ${#arquivos_h[@]} ))
total_linhas=$(contar_loc "${arquivos_c[@]}" "${arquivos_h[@]}")

if [ -f "$EXEC_FILE" ]; then
	if [ -r "$EXEC_FILE" ]; then
		tamanho_executavel="$(wc -c < "$EXEC_FILE") bytes"
	else
		erro "ERRO: permissões insuficientes para ler o executável $EXEC_FILE" 1
	fi
else
	tamanho_executavel="$INDISPONIVEL"
fi

ultima_compilacao=$(data_ultima_operacao "build")
ultima_execucao=$(data_ultima_operacao "run")

echo "Projeto: $SOURCE_DIR"
echo "Arquivos .c: ${#arquivos_c[@]}"
echo "Arquivos .h: ${#arquivos_h[@]}"
echo "Total de arquivos fonte: $total_arquivos"
echo "Linhas de código: $total_linhas"
echo "Executável: $EXEC_FILE"
echo "Tamanho do executável: $tamanho_executavel"
echo "Última compilação: $ultima_compilacao"
echo "Última execução: $ultima_execucao"

if [ "$GERAR_RELATORIO" -eq 1 ]; then
    mkdir -p "$SOURCE_DIR/relatorios" 2>/dev/null
    relatorio="$SOURCE_DIR/relatorios/relatorio.html"
    cat > "$relatorio" <<EOF
<!DOCTYPE html>
<html lang="pt-br">
<head><meta charset="utf-8"><title>Relatório cbuild</title></head>
<body>
<h1>Relatório do projeto</h1>
<p>Gerado em: $(date '+%Y-%m-%d %H:%M:%S')</p>
<ul>
  <li>Arquivos .c: ${#arquivos_c[@]}</li>
  <li>Arquivos .h: ${#arquivos_h[@]}</li>
  <li>Linhas de código: $total_linhas</li>
  <li>Tamanho do executável: $tamanho_executavel</li>
  <li>Última compilação: $ultima_compilacao</li>
  <li>Última execução: $ultima_execucao</li>
</ul>
</body>
</html>
EOF
    echo "relatório gerado em: $relatorio"
fi

log "info" "$SECONDS" 0 ""
exit 0
