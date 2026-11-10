#!/bin/bash

set -e

VCF="snps_dalata_annotated.vcf.gz"
OUT="analise_exploratoria"
SUMMARY="${OUT}_resumo_estatistico.txt"

# ------------------------------------------------------------------
# Verificação inicial
# ------------------------------------------------------------------

if [[ ! -f "$VCF" ]]; then
    echo "ERRO: arquivo VCF não encontrado: $VCF"
    exit 1
fi

echo "=============================================="
echo " ANÁLISE EXPLORATÓRIA DO VCF"
echo "=============================================="
echo "VCF: $VCF"
echo "Saída: $OUT"
echo ""

# ------------------------------------------------------------------
# Frequências alélicas
# ------------------------------------------------------------------

echo "[1/7] Calculando frequências alélicas..."

vcftools \
    --gzvcf "$VCF" \
    --freq2 \
    --out "$OUT"

# ------------------------------------------------------------------
# Profundidade por indivíduo
# ------------------------------------------------------------------

echo "[2/7] Calculando profundidade por indivíduo..."

vcftools \
    --gzvcf "$VCF" \
    --depth \
    --out "$OUT"

# ------------------------------------------------------------------
# Profundidade média por site
# ------------------------------------------------------------------

echo "[3/7] Calculando profundidade média por site..."

vcftools \
    --gzvcf "$VCF" \
    --site-mean-depth \
    --out "$OUT"

# ------------------------------------------------------------------
# Qualidade por site
# ------------------------------------------------------------------

echo "[4/7] Calculando qualidade por site..."

vcftools \
    --gzvcf "$VCF" \
    --site-quality \
    --out "$OUT"

# ------------------------------------------------------------------
# Missing data por indivíduo
# ------------------------------------------------------------------

echo "[5/7] Calculando missing data por indivíduo..."

vcftools \
    --gzvcf "$VCF" \
    --missing-indv \
    --out "$OUT"

# ------------------------------------------------------------------
# Missing data por site
# ------------------------------------------------------------------

echo "[6/7] Calculando missing data por site..."

vcftools \
    --gzvcf "$VCF" \
    --missing-site \
    --out "$OUT"

# ------------------------------------------------------------------
# Heterozigosidade
# ------------------------------------------------------------------

echo "[7/7] Calculando heterozigosidade..."

vcftools \
    --gzvcf "$VCF" \
    --het \
    --out "$OUT"

# ------------------------------------------------------------------
# Função para calcular:
# N, Min, Max, Média, Mediana e SD
# ------------------------------------------------------------------

resumo_estatistico() {

    local arquivo="$1"
    local coluna="$2"
    local nome="$3"
    local saida="$4"

    if [[ ! -f "$arquivo" ]]; then

        printf "%-40s %s\n" \
            "$nome" \
            "arquivo não encontrado ($arquivo)" >> "$saida"

        return

    fi

    local valores

    valores=$(awk -v col="$coluna" '
        NR > 1 &&
        $col != "nan" &&
        $col != "-nan" &&
        $col != "NA" &&
        $col != "." &&
        $col != "" {
            print $col
        }
    ' "$arquivo" | sort -n)

    local n

    n=$(echo "$valores" | grep -c '[0-9]' || true)

    if [[ "$n" -eq 0 ]]; then

        printf "%-40s %s\n" \
            "$nome" \
            "sem dados válidos" >> "$saida"

        return

    fi

    # --------------------------------------------------------------
    # Min, Max, Média e SD
    # --------------------------------------------------------------

    read min max media sd <<< "$(echo "$valores" | awk '

        {
            if (NR == 1 || $1 < min)
                min = $1

            if (NR == 1 || $1 > max)
                max = $1

            soma += $1
            soma_sq += $1 * $1
            n++
        }

        END {

            media = soma / n

            if (n > 1) {

                variancia = \
                    (soma_sq - (soma * soma) / n) / (n - 1)

                if (variancia < 0)
                    variancia = 0

                sd = sqrt(variancia)

            } else {

                sd = 0

            }

            printf "%.6f %.6f %.6f %.6f",
                   min, max, media, sd
        }

    ')"

    # --------------------------------------------------------------
    # Mediana
    # --------------------------------------------------------------

    local mediana

    mediana=$(echo "$valores" | awk '

        {
            a[NR] = $1
        }

        END {

            if (NR % 2 == 1) {

                print a[(NR + 1) / 2]

            } else {

                print (a[NR / 2] + a[NR / 2 + 1]) / 2

            }
        }

    ')

    # --------------------------------------------------------------
    # Escrever resultado
    # --------------------------------------------------------------

    printf "%-40s %8d %10.4f %10.4f %10.4f %10.4f %10.4f\n" \
        "$nome" \
        "$n" \
        "$min" \
        "$max" \
        "$media" \
        "$mediana" \
        "$sd" >> "$saida"
}

# ------------------------------------------------------------------
# Criar arquivo de resumo
# ------------------------------------------------------------------

echo ""
echo "Calculando estatísticas resumidas..."

{
    echo "Resumo estatístico das análises exploratórias"
    echo "Arquivo: $VCF"
    echo "Data: $(date)"
    echo ""

    printf "%-40s %8s %10s %10s %10s %10s %10s\n" \
        "Métrica" \
        "N" \
        "Min" \
        "Max" \
        "Média" \
        "Mediana" \
        "SD"

    printf '%.0s-' {1..108}

    echo ""

} > "$SUMMARY"

# ------------------------------------------------------------------
# Estatísticas
# ------------------------------------------------------------------

resumo_estatistico \
    "${OUT}.frq" \
    6 \
    "Frequência alélica (FA)" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.idepth" \
    3 \
    "Profundidade (DP) - por indivíduo" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.ldepth.mean" \
    3 \
    "Profundidade (DP) - por site" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.lqual" \
    3 \
    "Qualidade (QUAL)" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.imiss" \
    5 \
    "Missing data - por indivíduo" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.lmiss" \
    6 \
    "Missing data - por site" \
    "$SUMMARY"

resumo_estatistico \
    "${OUT}.het" \
    5 \
    "Heterozigosidade (F)" \
    "$SUMMARY"

# ------------------------------------------------------------------
# Finalização
# ------------------------------------------------------------------

echo ""
echo "=============================================="
echo " ANÁLISE FINALIZADA"
echo "=============================================="
echo ""
echo "Resumo estatístico:"
echo "$SUMMARY"
echo ""

cat "$SUMMARY"

echo ""
echo "Arquivos gerados:"
ls -lh ${OUT}*
