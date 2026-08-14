#!/usr/bin/env bash
set -euo pipefail

keys_file="keys/node.keys"
if [[ ! -f "$keys_file" ]]; then
  echo "Missing key list: $keys_file" >&2
  exit 1
fi

gnupg_home="$(mktemp -d)"
cleanup() {
  rm -rf "$gnupg_home"
}
trap cleanup EXIT

export GNUPGHOME="$gnupg_home"

now_epoch="$(date +%s)"
had_failure=0

while IFS= read -r raw_key || [[ -n "$raw_key" ]]; do
  key="${raw_key%%#*}"
  key="${key//[[:space:]]/}"

  [[ -z "$key" ]] && continue

  if ! (
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" >/dev/null 2>&1 ||
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" >/dev/null 2>&1
  ); then
    printf 'key=%s | name=%s | email=%s | expiry date=%s\n' "$key [INVALID]" "" "" ""
    had_failure=1
    continue
  fi

  key_info="$(gpg --batch --with-colons --list-keys "$key" 2>/dev/null || true)"
  pub_line="$(awk -F: '$1=="pub"{print; exit}' <<<"$key_info")"
  fpr="$(awk -F: '$1=="fpr"{print $10; exit}' <<<"$key_info")"
  uid="$(awk -F: '$1=="uid"{print $10; exit}' <<<"$key_info")"

  if [[ -z "$pub_line" || -z "$fpr" ]]; then
    printf 'key=%s | name=%s | email=%s | expiry date=%s\n' "$key [INVALID]" "" "" ""
    had_failure=1
    continue
  fi

  validity="$(awk -F: '{print $2}' <<<"$pub_line")"
  expiry_epoch="$(awk -F: '{print $7}' <<<"$pub_line")"

  name="$uid"
  email=""
  if grep -q '<[^<>]\+>' <<<"$uid"; then
    name="$(sed -E 's/[[:space:]]*<[^<>]+>$//' <<<"$uid")"
    email="$(sed -nE 's/^.*<([^<>]+)>$/\1/p' <<<"$uid")"
  fi

  if [[ -z "$expiry_epoch" || "$expiry_epoch" == "0" ]]; then
    expiry_display="[NEVER]"
    is_expired=0
  else
    expiry_display="$(date -u -d "@$expiry_epoch" +%F)"
    if (( expiry_epoch < now_epoch )); then
      expiry_display+=" [EXPIRED]"
      is_expired=1
    else
      is_expired=0
    fi
  fi

  key_display="$fpr"
  if [[ "$validity" == *r* || "$validity" == *i* ]]; then
    key_display+=" [INVALID]"
    had_failure=1
  fi

  if (( is_expired == 1 )); then
    had_failure=1
  fi

  printf 'key=%s | name=%s | email=%s | expiry date=%s\n' "$key_display" "$name" "$email" "$expiry_display"
done < "$keys_file"

if (( had_failure == 1 )); then
  echo "One or more keys are invalid or expired." >&2
  exit 1
fi
