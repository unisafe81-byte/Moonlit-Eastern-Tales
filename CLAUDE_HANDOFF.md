# Claude Code Handoff

## 프로젝트 개요

- **채널명**: Moonlit Eastern Tales (수면 유튜브 채널)
- **주요 파일**: `index.html` — 단일 파일 웹앱 (10,000줄+, 인라인 JS/CSS 포함)
- **로컬 서버 URL**: `http://127.0.0.1:5173` (`node preview-server.js`)
- **Supertonic TTS 서버**: `http://127.0.0.1:7788`
- **Git 브랜치**: `main`
- **언어**: 모든 대화는 **한국어**로 진행

---

## 서버 시작 명령

```powershell
# 로컬 앱 서버
node preview-server.js

# Supertonic TTS 서버 (필요 시)
& "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\supertonic.exe" serve --host 127.0.0.1 --port 7788
```

---

## JS 문법 검사 명령 (수정 후 반드시 실행)

```powershell
node -e "const fs=require('fs'); const html=fs.readFileSync('index.html','utf8'); const scripts=[...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map(m=>m[1]).filter(s=>s.trim()); scripts.forEach(s=>new Function(s)); console.log('inline scripts ok:', scripts.length);"
```

---

## 앱 구조

### 탭 구성 (data-tab 값)
- `keyword` — Step 0: 키워드 생성
- `step1` — Step 1: 리서치 입력 빌더
- `episode` — Step 2~7: 에피소드 대본 생성
- `tts` — Step 8: TTS 대본 생성
- `packaging` — Step 9: YouTube 패키징
- `koreanReview` — Step 10: 한국어 리뷰
- `longformVisual` — Step 11: Longform Visual Cut Plan
- `shortsMoment` — Step 12: Shorts Moment Extractor
- `shortsScript` — Step 13: Shorts Script Generator
- `shortsPackaging` — Step 14: Shorts Packaging Generator
- `supertone` — Step 15: Supertonic 로컬 TTS 생성
- `operationA` — 운영보조 A: 최종 품질 검수
- `operationB` — 운영보조 B: 제작 에셋 체크
- `operationC` — 운영보조 C: 썸네일 시각 검수
- `operationD` — 운영보조 D: 제작 기록 및 학습

### 파이프라인 데이터 저장 구조
각 Step의 AI 결과는 localStorage에 저장됨:
```javascript
loadPipelineResult(n)                          // Step N 결과 로드 (문자열)
savePipelineResult(n, value)                   // Step N 결과 저장
importPipelineResultToField(n, field, label)   // async: localStorage → textarea
getPipelineResultFilePrefix()                  // 선택된 폴더명 반환 (에피소드 식별자)
```

JSON 내보내기 형식: `{ type, step, savedAt, result }`

---

## 이번 세션에서 완료한 작업

### Step 11 — Longform Visual Cut Plan (tabLongformVisual)

**추가된 버튼:**
- `extractTitleFromStep9Btn` → `extractTitleFromStep9()` → `longformVisualVideoTitle` 자동 채움
- `generateTimestampsFromWavBtn` + `generateTimestampsFromWavFile` → WAV 파일 선택 → Web Audio API로 구간별 타임스탬프 생성 → `longformVisualTimestamps`

**Step 9 제목 추출 로직:**
```javascript
const sectionMatch = step9.match(/최종\s*추천\s*제목\s*\n/i);
const sectionText = step9.slice(sectionMatch.index + sectionMatch[0].length, sectionMatch.index + sectionMatch[0].length + 600);
const titleMatch = sectionText.match(/업로드용\s*영어\s*제목[^\n]*\n\s*([^\n]+)/i);
```

---

### Step 12 — Shorts Moment Extractor (tabShortsMoment)

**추가된 버튼:**
| 버튼 ID | 동작 | 채워지는 필드 |
|---------|------|--------------|
| `importStep8ToShortsMomentBtn` | Step 8 결과 가져오기 | `shortsMomentEpisodeScript` |
| `extractStep12TitleBtn` | Step 9에서 제목 추출 | `shortsMomentEpisodeTitle` |
| `extractStep12KeywordBtn` | Step 1에서 키워드 추출 | `shortsMomentCoreKeyword` |
| `extractStep12ConceptBtn` | Step 1에서 콘셉트 추출 | `shortsMomentLongformConcept` |

**파이프라인 결과 저장 섹션 추가:**
- `pipelineResultStep12` textarea (AI 결과 붙여넣기)
- `clearPipelineResultStep12Btn`, `exportPipelineResultStep12Btn`, `importPipelineResultStep12Btn`

---

### Step 13 — Shorts Script Generator (tabShortsScript)

**추가된 버튼:**
| 버튼 ID | 동작 | 채워지는 필드 |
|---------|------|--------------|
| `importStep12ToShortsScriptBtn` | Step 12 결과 가져오기 | `shortsScriptFullStep12Result` |
| `importAndExtractStep12Btn` | Step 12 로드 + 추천 1순위 자동 추출 | `shortsScriptSelectedMoment` |
| `extractStep13TitleBtn` | Step 9에서 제목 추출 | `shortsScriptEpisodeTitle` |
| `extractStep13KeywordBtn` | Step 1에서 키워드 추출 | `shortsScriptCoreKeyword` |
| `extractStep13ConceptBtn` | Step 1에서 콘셉트 추출 | `shortsScriptLongformConcept` |

**파이프라인 결과 저장 섹션 추가:**
- `pipelineResultStep13` textarea
- clear/export/import 버튼

---

### Step 14 — Shorts Packaging Generator (tabShortsPackaging)

**추가된 버튼:**
| 버튼 ID | 동작 | 채워지는 필드 |
|---------|------|--------------|
| `importStep13ToShortsPackagingBtn` | Step 13 결과 가져오기 | `shortsPackagingFullStep13Result` |
| `importAndExtractStep13ForPackagingBtn` | Step 13 로드 + 추천 쇼츠 대본 자동 추출 | `shortsPackagingFinalScript` |
| `importStep12ToShortsPackagingBtn` | Step 12 결과 가져오기 | `shortsPackagingFullStep12Result` |
| `importAndExtractStep12ForPackagingBtn` | Step 12 로드 + 쇼츠 모멘트 자동 추출 | `shortsPackagingSelectedMoment` |
| `extractStep14TitleBtn` | Step 9에서 제목 추출 | `shortsPackagingEpisodeTitle` |
| `extractStep14KeywordBtn` | Step 1에서 키워드 추출 | `shortsPackagingCoreKeyword` |

**파이프라인 결과 저장 섹션 추가:**
- `pipelineResultStep14` textarea
- clear/export/import 버튼

---

### 운영보조 A-D — 에피소드 기본 정보 자동 입력

4개 탭(A/B/C/D) 각각의 "에피소드 기본 정보" 섹션에 버튼 추가.
패턴: `fillOperationX...Btn` (X = A/B/C/D)

| 버튼 | 탭 | 출처 | 채워지는 필드 |
|------|-----|------|--------------|
| `fillOperationXEpisodeNumberBtn` | A,B,C,D | `getPipelineResultFilePrefix()` (폴더명) | `operationXEpisodeNumber` |
| `extractOperationXTitleBtn` | A,B,C,D | Step 9 최종 추천 제목 | `operationXFinalTitle` |
| `extractOperationXKeywordBtn` | A,B,C,D | Step 1 Main keyword | `operationXCoreKeyword` |
| `extractOperationXConceptBtn` | A,C,D | Step 1 Source category + Brief background notes | `operationXShortConcept` |
| `fillOperationDTodayBtn` | D만 | `new Date().toISOString().slice(0,10)` | `operationDProductionDate` |

**Episode Number 주의사항**: `getPipelineResultFilePrefix()`가 `"Keyword"` fallback을 반환하면 (폴더 미선택) 에러 메시지 표시.

---

## 핵심 추출 함수 (재사용 패턴)

```javascript
// Step 1 키워드 추출
const match = step1.match(/\*?\*?Main keyword[:\*]*\*?\*?\s*\n+\s*([^\n(]+)/i);

// Step 1 콘셉트 추출 (Source category + Brief background notes)
const categoryMatch = step1.match(/Source category[:\s]*([^\n]+)/i);
const notesMatch = step1.match(/Brief background notes[^*]*\*?\*?\s*\n+([\s\S]+?)(?:\n\n---)/i);

// Step 9 제목 추출 (2-step: 섹션 범위 한정 후 타이틀 추출)
const sectionMatch = step9.match(/최종\s*추천\s*제목\s*\n/i);
const sectionText = step9.slice(sectionMatch.index + sectionMatch[0].length, sectionMatch.index + sectionMatch[0].length + 600);
const titleMatch = sectionText.match(/업로드용\s*영어\s*제목[^\n]*\n\s*([^\n]+)/i);
```

**기존 자동 추출 함수:**
- `extractRecommendedShortsMomentBlock()` — Step 12 결과 → 추천 1순위 영어 블록
- `extractRecommendedShortsPackagingScript()` — Step 13 결과 → 추천 쇼츠 대본
- `extractShortsPackagingMomentBlock()` — Step 12 결과 → 쇼츠 모멘트 블록

---

## 현재 남은 작업 (Pending)

### Step 15 검증 (구현 완료, 브라우저 검증 미완)
Step 15 (`tabSupertone`)의 `Step 8 JSON 파일 불러와 추출` 버튼 흐름:
1. 버튼 클릭 → 파일 피커 열림 확인
2. `존슨보관/존슨보관-step-8-result.json` 선택
3. `importSupertoneStep8Json()` 함수 호출 확인
4. `payload.result`에서 `## TTS-READY SCRIPT` ~ `## ADAPTATION LOG` 구간 추출
5. `supertoneTtsText.value` 필드에 약 45,010자 채워지는지 확인

### 추가 검토 가능한 작업
- 운영보조 A-D 각 탭에 **결과 저장/내보내기/불러오기** 섹션 추가 (현재 없음)
- 각 스텝 자동입력 버튼 브라우저에서 실제 동작 확인

---

## 에피소드 데이터 폴더

`존슨보관/` 폴더에 각 스텝 결과 JSON 파일이 있음:
- `존슨보관-step-1-result.json` — Main keyword, Source category, Brief background notes 포함
- `존슨보관-step-8-result.json` — TTS-READY SCRIPT 섹션 포함 (~45,010자)
- `존슨보관-step-9-result.json` — 최종 추천 제목 섹션의 업로드용 영어 제목 포함

---

## 주의사항

- `preview-server.js`는 `.gitignore`에 의해 무시됨 (로컬에만 존재)
- API 키 없음 — 모든 자동 입력은 localStorage 또는 브라우저 네이티브 기능 사용
- WAV 타임스탬프 생성: Supertonic은 오디오를 브라우저 메모리에 저장하므로, 사용자가 WAV 파일을 직접 선택해야 함
