#!/usr/bin/env bash
set -euo pipefail

# Simple Ansible controller setup script (Debian/Ubuntu)
# - Installs: python3, venv, pip, ssh, sshpass, rsync, git
# - Creates:  ~/.venv/ansible virtualenv
# - Installs: ansible-core via pip (new enough for Python 3.12)

# Detect sudo
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "### [1/5] 패키지 매니저 확인 중..."
if ! command -v apt-get >/dev/null 2>&1; then
  echo "이 스크립트는 Debian/Ubuntu (apt-get) 전용입니다."
  exit 1
fi

echo "### [2/5] 기존 Ansible 패키지 제거 (있다면)..."
$SUDO apt-get update -y
# ansible / ansible-core 를 패키지로 설치해둔 경우, 버전 충돌 방지용
if dpkg -l | grep -E '^ii\s+ansible(\s|-core)' >/dev/null 2>&1; then
  $SUDO apt-get remove -y ansible ansible-core || true
fi

echo "### [3/5] 필수 패키지 설치 (python3, venv, pip, ssh, sshpass, rsync, git)..."
$SUDO apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  openssh-client \
  sshpass \
  rsync \
  git

echo "### [4/5] Python 가상환경 생성 및 Ansible 설치..."
VENV_DIR="${HOME}/.venv/ansible"

if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

# pip 최신화
pip install --upgrade pip

# ansible-core 설치 (Python 3.12 대응 버전권장)
pip install "ansible-core>=2.17,<2.19"

echo "### [5/5] ansible-galaxy 기본 컬렉션(선택) 설치..."
# 필요시 주석 해제해서 사용
# ansible-galaxy collection install community.general

echo
echo "======================================================"
echo " Ansible 컨트롤 노드 설정 완료 🎉"
echo
echo " - 가상환경: ${VENV_DIR}"
echo " - Ansible 버전:"
ansible --version || true
echo
echo " 앞으로 Ansible 쓸 때는 아래처럼 사용하면 됩니다:"
echo "   source ${VENV_DIR}/bin/activate"
echo "   ansible --version"
echo "   ansible-playbook site.yml"
echo "======================================================"