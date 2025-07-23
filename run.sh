#!/bin/bash

# 스크립트가 위치한 경로
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  matching_dirs=()

  for dir in "$SCRIPT_DIR"/*/; do
    folder="$(basename "$dir")"
    if [[ -f "$dir/helmfile" || -f "$dir/helmfile.yaml" || -f "$dir/helmfile.yml" ]] \
       && [[ -d "$dir/environments" ]] \
       && [[ -d "$dir/chart" ]]; then
      matching_dirs+=("$folder")
    fi
  done

  if [[ ${#matching_dirs[@]} -eq 0 ]]; then
    echo -e "\n[ERROR] 일치하는 helm 디렉토리를 찾을 수 없습니다.\n"
    exit 1
  fi

  IFS=$'\n' sorted=($(sort <<<"${matching_dirs[*]}"))
  unset IFS

  echo -e "\n사용 가능한 Helm 디렉토리"
  echo "─────────────────────────────"
  for i in "${!sorted[@]}"; do
    index=$((i + 1))
    printf "  %2d) %s\n" "$index" "${sorted[$i]}"
  done
  printf "   0) 종료\n"
  echo "─────────────────────────────"

  read -p "디렉토리 번호를 선택하세요: " selection

  if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
    echo -e "\n[WARNING] 잘못된 입력입니다. 숫자를 입력해주세요.\n"
    continue
  fi

  if (( selection == 0 )); then
    echo -e "\n종료합니다.\n"
    exit 0
  fi

  if (( selection < 1 || selection > ${#sorted[@]} )); then
    echo -e "\n[WARNING] 잘못된 선택입니다.\n"
    continue
  fi

  # 선택된 디렉토리
  chosen_dir="${sorted[$((selection - 1))]}"
  chosen_path="$SCRIPT_DIR/$chosen_dir"
  echo -e "\n선택됨: \033[1m$chosen_dir\033[0m ($chosen_path)"

  # environments 하위 유효한 값 찾기
  env_dir="$chosen_path/environments"
  env_options=()
  for subdir in "$env_dir"/*/; do
    [[ -d "$subdir" ]] || continue
    if [[ -f "$subdir/values.yaml" || -f "$subdir/values.yml" ]]; then
      env_options+=("$(basename "$subdir")")
    fi
  done

  if [[ ${#env_options[@]} -eq 0 ]]; then
    echo -e "\n[ERROR] '$chosen_dir/environments' 하위에 values.yaml/yml 파일이 있는 환경 디렉토리가 없습니다."
    echo -e "디렉토리 선택으로 돌아갑니다...\n"
    continue
  fi

  while true; do
    echo -e "\n'$chosen_dir'의 사용 가능한 환경"
    echo "─────────────────────────────"
    for i in "${!env_options[@]}"; do
      printf "  %2d) %s\n" "$((i + 1))" "${env_options[$i]}"
    done
    echo "   0) 뒤로"
    echo "─────────────────────────────"
    read -p "환경을 선택하세요: " env_sel

    if ! [[ "$env_sel" =~ ^[0-9]+$ ]]; then
      echo -e "\n[WARNING] 잘못된 입력입니다. 숫자를 입력해주세요.\n"
      continue
    fi

    if (( env_sel == 0 )); then
      echo -e "\n디렉토리 선택으로 돌아갑니다...\n"
      break
    fi

    if (( env_sel < 1 || env_sel > ${#env_options[@]} )); then
      echo -e "\n[WARNING] 잘못된 선택입니다.\n"
      continue
    fi

    selected_env="${env_options[$((env_sel - 1))]}"
    echo -e "\n선택된 환경: \033[1m$selected_env\033[0m"

    # 작업 메뉴
    while true; do
      echo -e "\n'$chosen_dir' ($selected_env)의 사용 가능한 작업"
      echo "────────────────────────────────────────────"
      echo "  1) 설치 또는 업데이트"
      echo "  2) 사전 설치 플러그인 설정 (준비 중)"
      echo "  3) 사후 설치 플러그인 설정 (준비 중)"
      echo "  4) 삭제"
      echo "  5) 차이점 보기"
      echo "  0) 뒤로"
      echo "────────────────────────────────────────────"
      read -p "작업을 선택하세요: " action

      case "$action" in
        0)
          echo -e "\n환경 선택으로 돌아갑니다..."
          break
          ;;
        1)
          echo -e "\n'$chosen_dir'의 Helm 차트를 '$selected_env' 환경으로 설치 또는 업데이트 중..."
          cd "$SCRIPT_DIR/$chosen_dir" || exit
          HELMFILE_COMMAND=sync helmfile -e "$selected_env" -f "$chosen_path/helmfile.yaml" sync
          ;;
        2)
          echo -e "\n[INFO] '$chosen_dir'의 '$selected_env' 환경에 대한 사전 설치 플러그인 설정..."
          echo "[INFO] 이 기능은 현재 개발 중입니다. 곧 제공될 예정입니다."
          ;;
        3)
          echo -e "\n[INFO] '$chosen_dir'의 '$selected_env' 환경에 대한 사후 설치 플러그인 설정..."
          echo "[INFO] 이 기능은 현재 개발 중입니다. 곧 제공될 예정입니다."
          ;;
        4)
          echo -e "\n'$chosen_dir'의 Helm 릴리스를 삭제 중..."
          cd "$SCRIPT_DIR/$chosen_dir" || exit
          HELMFILE_COMMAND=destroy helmfile -e "$selected_env" -f "$chosen_path/helmfile.yaml" destroy
          ;;
        5)
          echo -e "\n'$chosen_dir'의 차이점을 표시 중..."
          cd "$SCRIPT_DIR/$chosen_dir" || exit
          HELMFILE_COMMAND=diff helmfile -e "$selected_env" -f "$chosen_path/helmfile.yaml" diff
          ;;
        *)
          echo -e "\n[WARNING] 잘못된 작업입니다. 0부터 5까지의 숫자를 선택해주세요.\n"
          ;;
      esac
    done
  done
done
