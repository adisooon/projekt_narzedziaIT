#!/bin/bash

# Sprawdza, czy podano poprawną liczbę argumentów
if [[ $# -ne 2 ]]; then
  echo "Sposób użycia: $0 pathFile1.x pathFile2.y"
  exit 1
fi

input_file=$1
output_file=$2

# Sprawdza rozszerzenie pliku wejściowego
ext="${input_file##*.}"
ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

# Konwersja danych XML
if [[ $ext_lower == "xml" ]]; then
  if [[ $output_file == *.json ]]; then
    # Konwersja XML do JSON
    xmlstarlet fo -t "$input_file" | xmlstarlet sel -t -c '.' | jq '.' > "$output_file"
  elif [[ $output_file == *.yml ]]; then
    # Konwersja XML do YAML
    xmlstarlet fo -t "$input_file" | xmlstarlet sel -t -c '.' | yq eval '.' -o yaml > "$output_file"
  else
    echo "Niewłaściwe rozszerzenie pliku wyjściowego"
    exit 1
  fi

# Konwersja danych JSON
elif [[ $ext_lower == "json" ]]; then
  if [[ $output_file == *.xml ]]; then
    # Konwersja JSON do XML
    jq -r '.' "$input_file" | xmlstarlet fo -R -o > "$output_file"
  elif [[ $output_file == *.yml ]]; then
    # Konwersja JSON do YAML
    jq -r '.' "$input_file" | yq eval '.' -o yaml > "$output_file"
  else
    echo "Niewłaściwe rozszerzenie pliku wyjściowego"
    exit 1
  fi

# Konwersja danych YAML
elif [[ $ext_lower == "yml" ]]; then
  if [[ $output_file == *.xml ]]; then
    # Konwersja YAML do XML
    yq eval 'select(diag("YAML to XML conversion"))' "$input_file" | xmlstarlet fo -R -o > "$output_file"
  elif [[ $output_file == *.json ]]; then
    # Konwersja YAML do JSON
    yq eval '.' "$input_file" | jq '.' > "$output_file"
  else
    echo "Niewłaściwe rozszerzenie pliku wyjściowego"
    exit 1
  fi

else
  echo "Niewłaściwe rozszerzenie pliku wejściowego"
  exit 1
fi

echo "Konwersja zakończona pomyślnie."
