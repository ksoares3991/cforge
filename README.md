# cforge

Ferramenta de automação em Bash para projetos em C.

## Pré-requisitos

- Linux (ou Git Bash / WSL no Windows)
- Bash 4+
- gcc instalado

## Estrutura esperada do projeto

projeto/
├── src/ # arquivos .c
├── include/ # arquivos .h
├── build/ # gerado pela ferramenta
└── logs/ # gerado pela ferramenta


## Sintaxe

bash cbuild.sh <comando> [opções] [diretório]


## Comandos

| Comando   | Descrição                          |
|-----------|------------------------------------|
| build     | Compila o projeto                  |
| run       | Executa o programa compilado       |
| clean     | Remove artefatos de compilação     |
| rebuild   | Limpa e recompila                  |
| info      | Exibe estatísticas do projeto      |

## Opções

| Opção             | Descrição                              |
|-------------------|----------------------------------------|
| --opt=0\|1\|2     | Nível de otimização (-O0/-O1/-O2)      |
| --no-incremental  | Força recompilar todos os arquivos     |
| --verbose         | Exibe etapas e comandos executados     |
| --debug           | Exibe variáveis internas (stderr)      |
| --report          | Gera relatorios/relatorio.html (info)  |

## Exemplos

```bash
bash cbuild.sh build /meu/projeto
bash cbuild.sh build /meu/projeto --opt=2
bash cbuild.sh build /meu/projeto --verbose
bash cbuild.sh run /meu/projeto
bash cbuild.sh clean /meu/projeto
bash cbuild.sh rebuild /meu/projeto --opt=1
bash cbuild.sh info /meu/projeto
bash cbuild.sh info /meu/projeto --report
```

## Compilação incremental

Arquivos `.c` não modificados desde a última compilação não são recompilados. Use `--no-incremental` para forçar recompilação completa.

## Arquivo de configuração

Crie `cbuild.conf` na raiz do projeto:

EXEC_NAME="meu_programa"


## Logs

Cada execução gera um registro em `logs/cbuild.log` com data, horário, comando, tempo de execução e código de retorno.
