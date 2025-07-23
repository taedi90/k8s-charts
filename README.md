# 쿠버네티스 플러그인 helm 차트 모음

이 리포지토리는 Helmfile을 사용하여 쿠버네티스 클러스터에 필요한 다양한 플러그인 애플리케이션을 관리합니다.

## 테스트 환경
- Kubernetes V1.32.6

## 사전 요구사항

- helmfile
- kubectl
- helm
- helm-diff
- gomplate
- yq

```bash
# macOS (Homebrew) 기준 설치 명령어
brew install helmfile kubernetes-cli helm gomplate yq
helm plugin install https://github.com/databus23/helm-diff
```

## 폴더 구조 예시
```bash
.
├── addons # BGP 설정과 같이 환경에 따라 적용되는 추가적인 Kubernetes 리소스 템플릿
│   ├── bgp-advertisement.yaml.gotmpl
│   ├── bgp-cluster-config.yaml.gotmpl
│   ├── bgp-config.yaml.gotmpl
│   └── bgp-peer-config.yaml.gotmpl
├── chart
│   └── ... # 이 프로젝트에서 직접 관리하는 로컬 Helm 차트
├── environments
│   └── kdev
│       ├── addons.yaml # addons 템플릿에 전달할 변수 정의
│       └── values.yaml # Helm 차트의 values.yaml을 오버라이드하기 위한 파일
└── helmfile.yaml # Helmfile 메인 설정 파일
```

- addons: BGP 설정과 같이 환경에 따라 적용되는 추가적인 Kubernetes 리소스 템플릿을 관리합니다. 
- chart: 이 프로젝트에서 직접 관리하는 로컬 Helm 차트가 위치합니다. 
- environments: 각 환경(예: kdev, prod)별 설정 파일을 관리합니다.
- values.yaml: Helm 차트의 values.yaml을 오버라이드하기 위한 파일입니다.
- addons.yaml: addons 디렉토리의 템플릿에 전달할 변수를 정의합니다. 
- helmfile.yaml: Helmfile의 메인 설정 파일로, 어떤 Helm 차트를 어떤 설정으로 배포할지 정의합니다.

## 사용 방법 
./run.sh는 대화형 스크립트로, 터미널 안내에 따라 숫자만 입력하면 쉽게 애플리케이션을 관리할 수 있습니다. 

### 실행 절차 

1. 디렉토리 선택: 스크립트가 관리할 수 있는 Helmfile 프로젝트 디렉토리 목록이 나타납니다. 원하는 디렉토리를 번호로 선택합니다. 
2. 환경 선택: 선택한 프로젝트에 적용할 수 있는 환경(kdev 등) 목록이 나타납니다. 배포할 환경을 번호로 선택합니다. 
3. 작업 선택: 아래와 같은 작업 목록이 나타나면, 원하는 작업을 번호로 선택하여 실행합니다.

- `1) Install or Update`: 애플리케이션 설치 및 업데이트 (helmfile sync)
- `4) Delete`: 애플리케이션 삭제 (helmfile destroy)
- `5) Show Diff`: 변경사항 미리보기 (helmfile diff)

## 알려진 이슈 (TODO)
- `cilium` 설치 오류: addon manifest 를 설치하기 전 cilium 이 정상적으로 배포 되어 CRD 가 설치되어야하지만 현재 기능에 포함되지 않음
  - 임시 해결: 설치를 두 번 진행하면 됨

## 라이선스

본 프로젝트는 Apache License 2.0 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

### 서드파티 컴포넌트 라이선스

- **Apache License 2.0**: Harbor, Cilium, cert-manager, PostgreSQL, RabbitMQ 등
- **Elastic License 2.0**: Elastic Operator (상업적 사용 제한)

각 컴포넌트별 라이선스 정보는 [NOTICE](NOTICE) 파일에서 확인할 수 있습니다.