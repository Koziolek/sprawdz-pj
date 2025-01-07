#!/usr/bin/env bash


if [ $# -lt 1 ]; then
  echo "Użycie: $0 <plik>"
  echo "plik w formacie CSV, który nie ma nagłówka, struktura:"
  echo "imię,nazwisko,numer blankietu PJ"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Błąd: Plik $1 nie istnieje."
  exit 1
fi

while IFS= read -r line; do
  processed_line=$(echo "$line" | tr -d ', |')
  processed_line=$(echo "$processed_line" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null)
  processed_line=$(echo "$processed_line" | tr '[:lower:]' '[:upper:]')
  md5_hash=$(echo -n "$processed_line" | md5sum | awk '{print $1}' |  tr '[:lower:]' '[:upper:]')
  response=$(curl -s "https://moj.gov.pl/nforms/api/UprawnieniaKierowcow/2.0.10/data/driver-permissions?hashDanychWyszukiwania=${md5_hash}")
  doc_status=$(echo "$response" | jq -r '.dokumentPotwierdzajacyUprawnienia.stanDokumentu.stanDokumentu.wartosc')

  echo "${processed_line}, ${doc_status}"
done < "$1"

